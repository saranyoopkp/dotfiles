import { closeSync, existsSync, mkdirSync, openSync, readFileSync, readSync, renameSync, statSync, writeFileSync } from "node:fs"
import { createHash, randomBytes } from "node:crypto"
import { execFileSync, spawn } from "node:child_process"
import { homedir } from "node:os"
import { dirname, isAbsolute, join, relative, resolve } from "node:path"
import { tool } from "@opencode-ai/plugin"

const MAX_LOG_BYTES = 256 * 1024
const PROCESS_NAME = /^[a-zA-Z0-9][a-zA-Z0-9._-]{0,63}$/

function projectRoot(context) {
  if (context.worktree) return resolve(context.worktree)
  try {
    return execFileSync("git", ["rev-parse", "--show-toplevel"], {
      cwd: context.directory,
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    }).trim()
  } catch {
    return resolve(context.directory)
  }
}

function isInside(root, candidate) {
  const rel = relative(root, candidate)
  return rel === "" || (!rel.startsWith("..") && !isAbsolute(rel))
}

function workingDirectory(context, requested) {
  const root = projectRoot(context)
  const cwd = resolve(requested || root)
  if (!isInside(root, cwd)) throw new Error(`cwd must stay inside the current worktree: ${root}`)
  return { root, cwd }
}

function stateFor(root) {
  const base = process.env.XDG_STATE_HOME || join(homedir(), ".local", "state")
  const projectId = createHash("sha256").update(root).digest("hex").slice(0, 16)
  const dir = join(base, "opencode", "background", projectId)
  mkdirSync(join(dir, "logs"), { recursive: true })
  return { dir, registry: join(dir, "registry.json"), logs: join(dir, "logs") }
}

function loadEntries(state) {
  if (!existsSync(state.registry)) return []
  try {
    const value = JSON.parse(readFileSync(state.registry, "utf8"))
    return Array.isArray(value) ? value : []
  } catch {
    return []
  }
}

function saveEntries(state, entries) {
  const temp = `${state.registry}.tmp-${process.pid}`
  writeFileSync(temp, JSON.stringify(entries, null, 2) + "\n", "utf8")
  renameSync(temp, state.registry)
}

function alive(pid) {
  try {
    process.kill(process.platform === "win32" ? pid : -pid, 0)
    return true
  } catch {
    try {
      process.kill(pid, 0)
      return true
    } catch {
      return false
    }
  }
}

function startToken(pid) {
  if (process.platform === "win32") return null
  try {
    const stat = readFileSync(`/proc/${pid}/stat`, "utf8")
    const end = stat.lastIndexOf(")")
    const fields = stat.slice(end + 2).split(" ")
    return fields[19] || null
  } catch {
    return null
  }
}

function ownsProcess(entry) {
  if (!alive(entry.pid)) return false
  if (!entry.startToken) return true
  const current = startToken(entry.pid)
  return current !== null && current === entry.startToken
}

function refresh(entries) {
  const now = new Date().toISOString()
  for (const entry of entries) {
    if (entry.status === "running" && !ownsProcess(entry)) {
      entry.status = "exited"
      entry.endedAt = now
    }
  }
  return entries
}

function tail(path, lines) {
  if (!existsSync(path)) return ""
  const size = statSync(path).size
  const start = Math.max(0, size - MAX_LOG_BYTES)
  const handle = openSync(path, "r")
  const buffer = Buffer.alloc(size - start)
  try {
    readSync(handle, buffer, 0, buffer.length, start)
  } finally {
    closeSync(handle)
  }
  return buffer.toString("utf8").split(/\r?\n/).slice(-(Math.max(1, Math.min(lines || 100, 5000)))).join("\n")
}

function shellSpec(command) {
  if (process.platform === "win32") return { file: "powershell.exe", args: ["-NoProfile", "-Command", command] }
  return { file: process.env.SHELL || "/bin/bash", args: ["-lc", command] }
}

function writeEntryUpdate(state, id, update) {
  const entries = refresh(loadEntries(state))
  const entry = entries.find((item) => item.id === id)
  if (!entry) return
  Object.assign(entry, update)
  saveEntries(state, entries)
}

export const start = tool({
  description: "Start a project-scoped shell command in the background. Returns an id, PID, cwd, and log path. The command is detached and should stay in the foreground; use background_list, background_logs, and background_stop to manage it.",
  args: {
    command: tool.schema.string().describe("Shell command to run in the background"),
    name: tool.schema.string().optional().describe("Short label for the process, letters/numbers/dot/underscore/hyphen only"),
    cwd: tool.schema.string().optional().describe("Working directory inside the current worktree; defaults to the worktree root"),
  },
  async execute(args, context) {
    if (!args.command.trim()) throw new Error("command must not be empty")
    const { root, cwd } = workingDirectory(context, args.cwd)
    if (args.name && !PROCESS_NAME.test(args.name)) throw new Error("name must be 1-64 characters: letters, numbers, dot, underscore, hyphen")
    const state = stateFor(root)
    const entries = refresh(loadEntries(state))
    saveEntries(state, entries)
    const id = `${Date.now().toString(36)}-${randomBytes(4).toString("hex")}`
    const log = join(state.logs, `${id}.log`)
    const fd = openSync(log, "a")
    const shell = shellSpec(args.command)
    let child
    try {
      child = spawn(shell.file, shell.args, {
        cwd,
        detached: true,
        stdio: ["ignore", fd, fd],
        env: process.env,
      })
    } finally {
      closeSync(fd)
    }
    if (!child.pid) throw new Error("background process did not return a PID")
    const entry = {
      id,
      name: args.name || id,
      command: args.command,
      cwd,
      pid: child.pid,
      startToken: startToken(child.pid),
      log,
      status: "running",
      startedAt: new Date().toISOString(),
    }
    entries.push(entry)
    saveEntries(state, entries)
    child.unref()
    child.on("error", (error) => writeEntryUpdate(state, id, { status: "failed", error: String(error), endedAt: new Date().toISOString() }))
    child.on("exit", (code, signal) => writeEntryUpdate(state, id, { status: "exited", exitCode: code, signal, endedAt: new Date().toISOString() }))
    return JSON.stringify({ started: true, ...entry }, null, 2)
  },
})

export const list = tool({
  description: "List background processes started by these tools for the current project. By default returns running processes; includeStopped=true includes completed and stopped entries.",
  args: {
    includeStopped: tool.schema.boolean().optional().describe("Include exited, failed, and stopped entries"),
  },
  async execute(args, context) {
    const root = projectRoot(context)
    const state = stateFor(root)
    const entries = refresh(loadEntries(state))
    saveEntries(state, entries)
    const visible = args.includeStopped === true ? entries : entries.filter((entry) => entry.status === "running")
    return JSON.stringify({ root, running: entries.filter((entry) => entry.status === "running").length, processes: visible }, null, 2)
  },
})

export const logs = tool({
  description: "Read the latest output from one background process log. Use background_list first to identify the id.",
  args: {
    id: tool.schema.string().describe("Background process id"),
    lines: tool.schema.number().optional().describe("Number of last lines, default 100, maximum 5000"),
  },
  async execute(args, context) {
    const root = projectRoot(context)
    const state = stateFor(root)
    const entries = refresh(loadEntries(state))
    const entry = entries.find((item) => item.id === args.id)
    if (!entry) return JSON.stringify({ found: false, id: args.id })
    saveEntries(state, entries)
    return JSON.stringify({ id: entry.id, name: entry.name, status: entry.status, log: entry.log, output: tail(entry.log, args.lines || 100) }, null, 2)
  },
})

export const stop = tool({
  description: "Stop one background process started by these tools. It verifies the recorded PID belongs to the original process, sends a graceful signal, then force-stops the process group if needed.",
  args: {
    id: tool.schema.string().describe("Background process id from background_start or background_list"),
    force: tool.schema.boolean().optional().describe("Skip graceful termination and force-stop immediately"),
  },
  async execute(args, context) {
    const root = projectRoot(context)
    const state = stateFor(root)
    const entries = refresh(loadEntries(state))
    const entry = entries.find((item) => item.id === args.id)
    if (!entry) return JSON.stringify({ stopped: false, found: false, id: args.id })
    if (entry.status !== "running") {
      saveEntries(state, entries)
      return JSON.stringify({ stopped: false, id: entry.id, status: entry.status, message: "process is not running" })
    }
    if (!ownsProcess(entry)) {
      entry.status = "stale"
      entry.endedAt = new Date().toISOString()
      saveEntries(state, entries)
      return JSON.stringify({ stopped: false, id: entry.id, status: "stale", message: "recorded PID no longer belongs to the original process; nothing was killed" })
    }
    if (process.platform === "win32") {
      execFileSync("taskkill.exe", ["/PID", String(entry.pid), "/T", "/F"], { stdio: "ignore" })
    } else {
      process.kill(-entry.pid, args.force === true ? "SIGKILL" : "SIGTERM")
      if (args.force !== true) {
        await new Promise((resolveWait) => setTimeout(resolveWait, 1000))
        if (ownsProcess(entry)) process.kill(-entry.pid, "SIGKILL")
      }
    }
    entry.status = "stopped"
    entry.endedAt = new Date().toISOString()
    saveEntries(state, entries)
    return JSON.stringify({ stopped: true, id: entry.id, pid: entry.pid, name: entry.name, log: entry.log }, null, 2)
  },
})

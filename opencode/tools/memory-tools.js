import { existsSync, mkdirSync, readdirSync, readFileSync, renameSync, writeFileSync } from "node:fs"
import { join, resolve } from "node:path"
import { execFileSync } from "node:child_process"
import { tool } from "@opencode-ai/plugin"

const FACT_NAME = /^[a-z0-9]+(?:-[a-z0-9]+)*$/

function projectRoot(directory, worktree) {
  if (worktree) return resolve(worktree)
  try {
    return execFileSync("git", ["rev-parse", "--show-toplevel"], {
      cwd: directory,
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    }).trim()
  } catch {
    return resolve(directory)
  }
}

function memoryRoot(root) {
  return join(root, "memory")
}

function factPath(root, name) {
  const clean = name.endsWith(".md") ? name.slice(0, -3) : name
  if (!FACT_NAME.test(clean)) throw new Error("name must be lowercase kebab-case")
  const path = resolve(memoryRoot(root), `${clean}.md`)
  if (!path.startsWith(`${resolve(memoryRoot(root))}/`) && !path.startsWith(`${resolve(memoryRoot(root))}\\`)) {
    throw new Error("memory path escaped project memory/")
  }
  return path
}

function markdownFiles(dir) {
  if (!existsSync(dir)) return []
  const output = []
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    const path = join(dir, entry.name)
    if (entry.isDirectory()) output.push(...markdownFiles(path))
    else if (entry.isFile() && entry.name.endsWith(".md") && !["README.md", "_fact.template.md", "MEMORY.md"].includes(entry.name)) output.push(path)
  }
  return output
}

function frontmatter(text) {
  const match = text.match(/^---\s*\n([\s\S]*?)\n---\s*\n?/)
  const fields = {}
  if (match) {
    for (const line of match[1].split(/\r?\n/)) {
      const field = line.match(/^([a-zA-Z][\w-]*):\s*(.*)$/)
      if (field) fields[field[1]] = field[2].trim()
    }
  }
  return { fields, body: match ? text.slice(match[0].length) : text }
}

function factRecord(path) {
  const text = readFileSync(path, "utf8")
  const parsed = frontmatter(text)
  const name = parsed.fields.name || path.split(/[\\/]/).pop().replace(/\.md$/, "")
  const description = parsed.fields.description || ""
  const typeMatch = text.match(/^\s+type:\s*(.+)$/m)
  const body = parsed.body.replace(/^#+\s*/gm, "").replace(/\s+/g, " ").trim()
  return {
    name,
    description,
    type: parsed.fields.type || (typeMatch ? typeMatch[1].trim() : "unknown"),
    path,
    excerpt: `${description}${description && body ? " — " : ""}${body}`.slice(0, 500),
  }
}

function indexPath(root) {
  return join(memoryRoot(root), "MEMORY.md")
}

function indexLine(record) {
  return `- [${record.description || record.name}](${record.name}.md) — ${record.description || record.excerpt}`
}

function indexSection(type) {
  if (type === "user" || type === "feedback") return "Feedback"
  if (type === "reference") return "References"
  return "Project quirks"
}

function syncIndex(root, record) {
  const path = indexPath(root)
  let text = existsSync(path) ? readFileSync(path, "utf8") : "# Memory Index\n"
  const escapedName = record.name.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")
  const pointer = new RegExp(`^- \\[[^\\n]*\\]\\(${escapedName}\\.md\\).*\\n?`, "m")
  const line = indexLine(record)
  if (pointer.test(text)) text = text.replace(pointer, `${line}\n`)
  else {
    const heading = `## ${indexSection(record.type)}`
    if (text.includes(heading)) text = `${text.trimEnd()}\n${line}\n`
    else text = `${text.trimEnd()}\n\n${heading}\n${line}\n`
  }
  writeFileSync(path, text, "utf8")
}

function atomicWrite(path, text) {
  const temp = `${path}.opencode-tmp-${process.pid}`
  writeFileSync(temp, text, "utf8")
  renameSync(temp, path)
}

function listRecords(root) {
  return markdownFiles(memoryRoot(root)).map(factRecord)
}

function contextRoot(context) {
  return projectRoot(context.directory, context.worktree)
}

export const search = tool({
        description: "Search durable project memory facts by keyword. Use before making a decision that may depend on prior project quirks, preferences, or decisions.",
        args: {
          query: tool.schema.string().describe("Keyword or short phrase to search"),
          limit: tool.schema.number().optional().describe("Maximum results, default 8"),
        },
        async execute(args, context) {
          const root = contextRoot(context)
          const tokens = args.query.toLowerCase().split(/\s+/).filter(Boolean)
          const scored = listRecords(root).map((record) => {
            const haystack = `${record.name} ${record.description} ${record.excerpt}`.toLowerCase()
            const score = tokens.reduce((total, token) => total + (haystack.includes(token) ? 1 : 0), 0)
            return { ...record, score }
          }).filter((record) => record.score > 0).sort((a, b) => b.score - a.score || a.name.localeCompare(b.name))
          return JSON.stringify({ root: memoryRoot(root), query: args.query, results: scored.slice(0, args.limit || 8) }, null, 2)
        },
      })
export const read = tool({
  description: "Read one exact durable project memory fact after memory_search identifies its name.",
  args: {
    name: tool.schema.string().describe("Fact filename or lowercase kebab-case name"),
  },
  async execute(args, context) {
    const root = contextRoot(context)
    const path = factPath(root, args.name)
    if (!existsSync(path)) return JSON.stringify({ found: false, name: args.name })
    return readFileSync(path, "utf8")
  },
})
export const save = tool({
  description: "Save one durable project fact as memory/<name>.md and update memory/MEMORY.md. Use only for stable, evidence-backed facts, preferences, decisions, or reusable quirks; do not store transient task state or secrets.",
  args: {
    name: tool.schema.string().describe("New or existing lowercase kebab-case fact name"),
    description: tool.schema.string().describe("One-line summary used for future recall"),
    type: tool.schema.enum(["user", "feedback", "project", "reference"]).describe("Fact category"),
    fact: tool.schema.string().describe("The concise durable fact"),
    why: tool.schema.string().optional().describe("Evidence or reason this fact matters"),
    howToApply: tool.schema.string().optional().describe("Practical application"),
    related: tool.schema.string().optional().describe("Comma-separated related fact names"),
    overwrite: tool.schema.boolean().optional().describe("Must be true to replace an existing fact"),
  },
  async execute(args, context) {
    const root = contextRoot(context)
    const dir = memoryRoot(root)
    mkdirSync(dir, { recursive: true })
    const path = factPath(root, args.name)
    if (existsSync(path) && args.overwrite !== true) return JSON.stringify({ saved: false, reason: "exists; pass overwrite=true to replace", path })
    const related = args.related ? `\n\nRelated: ${args.related.split(",").map((name) => `[[${name.trim()}]]`).join(", ")}` : ""
    const text = [
      "---",
      `name: ${args.name}`,
      `description: ${args.description}`,
      "metadata:",
      `  type: ${args.type}`,
      "---",
      "",
      args.fact,
      args.why ? `\n\n**Why:** ${args.why}` : "",
      args.howToApply ? `\n**How to apply:** ${args.howToApply}` : "",
      related,
      "",
    ].join("\n")
    atomicWrite(path, text)
    const record = factRecord(path)
    syncIndex(root, record)
    return JSON.stringify({ saved: true, path, index: indexPath(root), record }, null, 2)
  },
})
export const index = tool({
  description: "Audit the project memory directory against MEMORY.md and report missing or orphaned index entries. This is read-only unless repair=true.",
  args: {
    repair: tool.schema.boolean().optional().describe("Add missing index entries; never deletes stale entries"),
  },
  async execute(args, context) {
    const root = contextRoot(context)
    const records = listRecords(root)
    const index = existsSync(indexPath(root)) ? readFileSync(indexPath(root), "utf8") : ""
    const missing = records.filter((record) => !index.includes(`](${record.name}.md)`))
    const orphaned = [...index.matchAll(/\]\(([^)]+)\.md\)/g)].map((match) => match[1]).filter((name) => !records.some((record) => record.name === name))
    if (args.repair === true) for (const record of missing) syncIndex(root, record)
    return JSON.stringify({ root: memoryRoot(root), facts: records.length, missing: missing.map((record) => record.name), orphaned, repaired: args.repair === true ? missing.map((record) => record.name) : [] }, null, 2)
  },
})

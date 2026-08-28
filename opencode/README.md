# OpenCode adapter

This projects the Claude Code dotfiles into OpenCode while keeping the Claude source
tree and Claude installation compatible.
It keeps the Claude source tree unchanged and generates OpenCode-compatible files:

- `~/.config/opencode/AGENTS.md` from `claude/rules/`
- `~/.config/opencode/agents/` from `claude/agents/`
- `~/.config/opencode/skills/` and `commands/` from `claude/skills/`
- optional OpenCode-native memory tools from `opencode/tools/memory-tools.js`

The skill projection changes grouped Claude ids such as `api-design:mutations` to
OpenCode-compatible ids such as `api-design-mutations`. The source files under
`claude/` are not modified.

## Install into the WSL distro

From PowerShell in this repository:

```powershell
& .\opencode\install-full.ps1 -WslHome '\\wsl.localhost\debian-private\home\debian'
```

The installer does not modify `~/.claude` or the existing OpenCode JSON config. Any
colliding generated file is backed up as `.bak-pre-dotfiles-full`.

Then start OpenCode inside the Debian WSL distro and try the generated `scc`, `scout`,
`acv`, command aliases, and skill ids. Re-run the installer after changing the source files.

This adapter intentionally does not install Claude plugins, hooks, `.claude/settings.json`,
or lifecycle scripts. The Claude-specific routing regression tests still need a separate
OpenCode runner.

## Memory tools

Install the OpenCode-native memory tools separately:

```powershell
& .\opencode\install-memory-tools.ps1 -WslHome '\\wsl.localhost\debian-private\home\debian'
```

This installs native OpenCode custom tools, not a Claude plugin or Claude hook. OpenCode loads
them from `~/.config/opencode/tools/`. The tools are:

- `memory_search` — search `memory/`
- `memory_read` — read one fact
- `memory_save` — write one fact and update `MEMORY.md`
- `memory_index` — audit or repair missing index entries

The tools are project-scoped and do not create a separate hidden memory database.

## Background process tools

Install the OpenCode-native process tools separately:

```powershell
& .\opencode\install-background-tools.ps1 -WslHome '\\wsl.localhost\debian-private\home\debian'
```

They keep a registry and logs per Git worktree under the WSL state directory:

- `background_start` — detach a command and return its id/PID/log path
- `background_list` — list running processes owned by this tool
- `background_logs` — read the latest output
- `background_stop` — stop the verified process group

The working directory must be inside the current Git worktree. The tool verifies the
recorded process start token before killing a process, so a reused PID is treated as stale.

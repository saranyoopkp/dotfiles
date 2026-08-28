# Agent routing regression

Runs fresh SCC sessions and reads actual `Agent` tool-use from stream-json. It protects both sides of
optional Scout delegation: broad bounded discovery should invoke Scout, while routine searches should
stay with SCC.

```bash
bash test/agent-routing/run.sh
```

This proves only the declared scenarios. It does not prove that every broad search will delegate or that
Scout's conclusions are correct; SCC must still verify primary evidence before using the result.
It also does not assert platform topology selection for forks, agent teams, background sessions, or
worktrees; those mechanisms have different runtime surfaces and are documented separately in
`references/agent-orchestration.md`.

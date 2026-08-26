# Simple-task friction regression

This fresh-session smoke test checks whether the primary agent can complete tightly specified, self-contained tasks
without tool calls, clarification questions, or process narration large enough to exceed a small output budget.
It complements routing tests; it does not prove performance on repository work or high-risk tasks.

Run after changing always-on rules or the primary agent:

```bash
bash test/friction/run.sh
```

Each TSV row defines an expected answer fragment and maximum final-output characters. The evaluator also requires
zero tool calls and no question mark. These cases are intentionally boring and deterministic; add a case only when
its correct answer and no-tool boundary are unambiguous.

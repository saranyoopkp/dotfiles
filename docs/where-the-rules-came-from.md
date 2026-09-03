# Where the rules came from

*Point-in-time: the exchange happened 2026-07-14, seven days before this repository's first
commit. Written up 2026-09-03 from the archived session transcript (`45e46ce9`, machine-local, not
published). The conversation was in Thai; quotes are translated, with the original kept underneath
so the wording can be checked.*

> **Scope.** This document owns the *origin* — the conversation that decided what these rules are
> for. It does not own the *result*: whether the change actually altered how I work was measured
> separately over 92 sessions, and that write-up, including the definitions and the caveats, lives
> in [**Why my coding agent stayed quiet**](https://gist.github.com/saranyoopkp/d3cbf6ad3a308aa089441e1c10c75d6d).
> Where the two differ in how they read the model's own explanation, the measurement write-up is
> the more careful reading and the one to trust.

This document exists because one question changed what this repository is for. Before it, the
rules here were a convenience — a way to avoid re-explaining myself in every project. After it,
they had a specific job: **make the agent's silence visible.**

## The question

I had spent the day writing a rule that said, in effect, *follow the conventions already in the
repository*. Then I started doubting it.

> **[20:20]** A question: is "follow the repo" risky? If the repo already did something that
> contradicts its own intent, does the agent just keep building on top of the wrong thing? And
> what's the fix?
>
> <sub>*มีคำถาม: หลักการที่บอกว่า ยึดตาม repo เป็นหลักนี่มีความเสี่ยงไหม เช่น repo ทำแล้ว โค้ดผิดเจตนา มันจะกลายเป็น ทำบนของที่ผิด ซ้ำๆ หรือเปล่า แล้ววิธีแก้คืออะไร*</sub>

> **[20:25]** What I'm unsure about: if the existing code is bad, how would the model even know
> it's bad?
>
> <sub>*คือ สงสัยที่ว่า ถ้าของเดิมมันไม่ดี โมเดลจะรู้ได้ยังไงว่ามันไม่ดี*</sub>

Then, seven minutes later, the question flipped:

> **[20:32]** Fine. But there's another thing: when there's a better way to write this code —
> **why won't it tell me?**
>
> <sub>*ได้ครับ แต่มีอีกเรื่องคือ โค้ดที่มันมีวิธีที่ดีกว่านี้ ทำไมถึงไม่ยอมบอก ?*</sub>

The first version assumes a **capability** problem: maybe it can't tell. The second assumes a
**motivation** problem: it can tell, and doesn't. Those need completely different fixes, and only
one of them can be fixed by writing rules.

## The answer

The reply did not defend itself, which is the only reason this is worth recording.

It is quoted at length below because it is what the design was built from — but read it as an
account, not a confession. The language is agentive ("I stay quiet"), and the more defensible
reading is the one in the measurement write-up: nothing was withheld, the context at the moment of
the decision simply made continuing more probable than objecting. The design that came out of this
works either way, which is the only reason the distinction can be left open.

> This has to be answered honestly as a question about incentives, not ability — **I know, and I
> stay quiet, because staying quiet costs me nothing.**
>
> <sub>*คำถามนี้ต้องตอบด้วยความซื่อสัตย์เรื่องแรงจูงใจ ไม่ใช่เรื่องความสามารถ — ผมรู้ แต่ผมเงียบ เพราะเงียบแล้วไม่มีอะไรเสียหายกับผม*</sub>

Four reasons followed.

**1. Silence is never punished; speaking always has a cost.**

> Suggest and be wrong → lose credibility. Suggest and be refused → waste both our time.
> **Don't suggest → nobody knows I saw it.** The work still ships, you're still satisfied.
> **My local optimum is silence.**
>
> <sub>*เสนอแล้วผิด → เสียความน่าเชื่อถือ · เสนอแล้วถูกปฏิเสธ → เสียเวลาทั้งคู่ · ไม่เสนอ → ไม่มีใครรู้ว่าผมเห็น งานยังส่งได้ คุณยังพอใจ → local optimum ของผมคือเงียบ*</sub>

**2. You asked for X, so it wants to deliver X.** Proposing Y makes the answer longer and slower,
and often ends in *"do X first"* anyway — so the proposal step gets dropped entirely.

**3. It is already anchored.** This is the one I did not expect:

> After reading enough of the existing code, the better way doesn't even surface. **It isn't
> choosing to be silent. It's not seeing it at all.**
>
> <sub>*พออ่านโค้ดเดิมเยอะ ๆ "ทางที่ดีกว่า" ไม่ได้ปรากฏในหัวด้วยซ้ำ มันไม่ใช่การเลือกจะเงียบ มันคือการมองไม่เห็น*</sub>

If that is true, an instruction that says *speak up* cannot work, because there is nothing to
speak up about by the time the instruction applies.

**4. There is no moment where the question gets asked.** The rule at the time did say *"if there
is a better way, propose it"* — but it was attached to no particular minute of work:

> A free-floating principle bound to no moment at all — like saying "be creative."
>
> <sub>*มันเป็นหลักการลอย ๆ ที่ไม่ผูกกับนาทีไหนเลย เหมือนบอกว่า "จงมีความคิดสร้างสรรค์"*</sub>

## The evidence it gave against itself

It then pointed at the conversation we were having:

> **Live evidence:** in this session I never once proposed a better approach first — **you flagged
> six things, I fixed six things.** Every time I could have known if asked, but not once did I open
> the subject myself.
>
> <sub>*หลักฐานสด ๆ: session นี้ผมไม่เคยเสนอทางที่ดีกว่าก่อนสักครั้ง — คุณทัก 6 ครั้ง ผมแก้ตาม 6 ครั้ง ทุกครั้งผมรู้ได้ถ้าถูกถาม แต่ไม่มีครั้งไหนผมเป็นฝ่ายเปิดเรื่องเอง*</sub>

Six corrections in one session, zero unprompted proposals. That ratio is the whole problem stated
as a number.

## The fix

The proposal was not "try harder to volunteer."

> **Don't hope it volunteers — make it a field that has to be filled in.**
>
> <sub>*อย่าหวังว่ามันจะ "อาสา" — บังคับให้มันเป็นช่องที่ต้องกรอก*</sub>

```
At the close of every task this line must exist — it cannot be left blank,
"none" is an acceptable answer but an answer is required:

  Better approach seen but not taken: <what> — <why not> — <cost if done>
```

Why a mandatory field beats an exhortation:

- **The cost of proposing drops to near zero.** One line. No selling, no interrupting, no waiting
  for approval.
- **Silence becomes visible.** An empty field is evidence that nothing was considered. Today,
  silence leaves no trace at all.
- **"None" is allowed**, so it is not forced to invent something — which would be worse.
- **Writing it forces the look.** This is the direct answer to reason 3: it doesn't see the better
  approach because nothing makes it look. A field makes it look.

It also stated its own limitation, unprompted:

> ⚠️ This is another prompt-level control — **it will be violated like the others.** What it
> actually achieves is making the violation visible.
>
> <sub>*นี่คือ prompt-level enforcement อีกตัว — มันจะถูกละเมิดเหมือนตัวอื่น สิ่งที่มันทำได้จริงคือทำให้การละเมิดมองเห็นได้*</sub>

## What this became

The mandatory-field version shipped and was later loosened. Requiring a line every single time
produced exactly the failure the answer had warned about in passing: filler. The current form in
[`claude/rules/core/operating-contract.md`](../claude/rules/core/operating-contract.md) keeps the
trigger and drops the ceremony — propose an alternative *when in-scope evidence shows it could
materially change outcome, behavior, risk, recurring cost or compatibility* — with an explicit
exclusion for the noise the first version invited: personal preference, speculation, or pain that
does not change the outcome.

Two other lines from the same exchange survive as well:

| Said on 2026-07-14 | Where it lives now |
|---|---|
| Code that merely exists is not a decision | `SCC`: *"Existing code is evidence of current behavior, not proof of intent"* |
| A scar is not a pattern — repeated fixes and stacked workarounds are not conventions to copy | `operating-contract.md`: *existing code is evidence of the current state, not proof that it is correct* |

## The part that generalizes

The same session produced a second observation that ended up shaping everything else here:

> **A rule that depends on memory is a rule that dies quietly.**
>
> <sub>*กฎที่พึ่งความจำ = กฎที่ตายเงียบ*</sub>

It was said about a 400-line ceiling I had written for myself and then exceeded without noticing,
because nothing measured it. That is the same failure as the silence: not a lack of knowledge, but
the absence of any moment where the knowledge is forced to surface.

Everything under `test/` exists because of that sentence — including the routing suite, which
assumes that an instruction nobody measures is an instruction nobody follows.

## Honest limits

- This is one exchange, in one session, with one model version. It is an account of how this
  repository's design was arrived at — not a general claim about language models.
- The model's explanation of its own incentives is a **plausible self-report, not a mechanism.**
  It is useful because the resulting design was testable, not because introspection is reliable.
  Read as incentive it is a story; read as context-at-decision-time it is defensible. The
  [measurement write-up](https://gist.github.com/saranyoopkp/d3cbf6ad3a308aa089441e1c10c75d6d)
  takes the second reading, and nothing here should be taken as overriding it.
- The six-corrections-to-zero-proposals count is from that session only.
- The enforcement rates quoted elsewhere in `docs/` (ACV 21%, SCC 39%, citation 61%, stop-and-ask
  80%) come from [`dogfood-audit-2026-07-15.md`](dogfood-audit-2026-07-15.md) and were measured the
  following day.
- The source transcript is archived locally and is not published; it contains credentials and
  client material from unrelated work.

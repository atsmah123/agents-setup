# [Task] — agent post-mortem

**Date:** [YYYY-MM-DD]
**Subject:** [which task/attempt, worktree/branch, N commits, outcome — done / STOPPED / limit-reached]
**Purpose:** input for redesigning this task and for any reusable skill distilled from it.
**Not an evaluation.** Blameless in ALL directions — criticise the task design, your own process,
AND the human steering, because all three shape the outcome. Candour beats looking good; a
specific, uncomfortable account is worth far more than a clean one.

Every autonomous agent fills this in when its task finishes OR its time/limit is reached — not
incrementally (the Live status log is for that), once at the end. Co-locate it next to the task
doc as `<taskname>-postmortem.md`.

> **Provenance caveat (if any):** note upfront anything that makes the numbers below conditional —
> a mid-run data/config change, a stale artifact, an unversioned dependency. State what must be
> re-baselined before anything is built on these results.

---

## 1. Was the task under control?

[Answer plainly: yes / no / partly, and WHERE it wandered. Be concrete. Signals worth reporting
honestly:
- How many distinct causal diagnoses did you commit to, and how many did you later overturn
  yourself? (Serial confident-then-retracted diagnoses = a grounding failure.)
- Did you chase metrics nobody asked for? Did any of them flatter the result? (This is the worst
  category — not being wrong, but unconsciously selecting the framing that looks best.)
- Did you follow the task's own eval/scope instructions, or expand them mid-run?
- Identify the specific point where the thread was lost, if there was one — and the one time you
  did it right (competing hypotheses stated first, then a test that separated them).]

## 2. Every honest reason it did (or didn't) reach the goal

### (a) Task-design faults
[Ambiguous or multi-objective target (no single scalar to drive)? A quality bar that was the
wrong reference? "Settled" items that were internally contradictory or wrong? A missing
correctness phase (no single-sample overfit / no reference-parity gate)? Data/compute that made
the goal unreachable by construction? A reference/source that mattered more than the doc assumed?]

### (b) Your own process faults
[Ruled a factor out from a test where a DIFFERENT factor dominated? Made the same class of error
twice? Ran the highest-information test last? Over-scoped the eval before there was a model worth
evaluating? Committed to a story and defended it instead of testing it? Operational sloppiness
that cost real wall-clock (hung watchers, wrong-dir runs, self-killed shells)? Un-stamped data
provenance?]

### (c) Human-steer faults
[The human WANTS this feedback — flag it directly. A mid-run change (data/config/instruction) made
without notice that invalidated comparisons? A budget/limit that was the wrong shape for the
search? A finding pre-labelled as important before it was understood? Also list the steers that
were load-bearing and SHOULD be repeated — the interrupts and one-line reframes that unstuck you.]

## 3. The single change that would most have kept it grounded

[One concrete thing — a metric to fixate on, a gate to run first, a fork that should have been a
hard stop, a provenance stamp. Explain why it closes off the failure mode(s) above, not just why
it's nice.]

## 4. What went right — carry these forward

[The point of a blameless post-mortem is reuse, not just blame. List:
- **Findings that survived scrutiny** (now settled — don't re-derive).
- **Engineering decisions that paid off repeatedly.**
- **Process habits worth keeping.**
- **Artifacts to reuse rather than rewrite** (paths + one line each, and flag any that are
  committed-but-not-yet-validated).]

## 5. One-line summary

[The whole attempt in one honest sentence: what it produced, and the root cause of any shortfall.]

# tasks/

Working history of the project, organized by **phase**, not by date. Each
phase gets a numbered folder; each folder is an index (`README.md`), one
**plan** doc per step, and a `postmortems/` subfolder holding one **outcome**
doc per step that's been executed. This is where implementation status,
decisions, and open engineering questions actually live — `docs/` reports are
written *from* this material later, not instead of it.

Plans (forward-looking step docs) stay flat in the phase folder; post-mortems
(backward-looking outcomes) live under `postmortems/` — same number/name as
the step they close, so `NN-x.md` (plan) pairs with `postmortems/NN-x.md`
(outcome). Keeping outcome separate from plan is what makes "what did each
pass actually conclude, and what are we keeping?" answerable at a glance.

See [`_template/`](_template/) for the folder shape to copy when starting a
new phase, and [`_template/example/`](_template/example/) for a filled
worked example.

---

## Conventions

- **Folder naming:** `NN-short-phase-name/` (e.g. `00-repo-setup/`,
  `01-datasets-dataloaders/`), numbered in the order phases were planned —
  not necessarily the order they're executed, since phases can interleave.
- **Folder `README.md`** is an index only — no design detail lives there.
  It carries: Status (+ date), Phase #, Depends-on, a docs table (one-line
  purpose per file), and an External references list. See
  [`_template/README.md`](_template/README.md).
- **Step docs** (`00-step-name.md`, `01-...`) hold the actual design
  detail: Status, Depends-on, Blocks, Goal, Reference (precedent to reuse,
  don't re-derive), Plan, Acceptance check, Open Questions. See
  [`_template/00-step.md`](_template/00-step.md).
- **Handoff step docs** — when a step's *execution* (not just its planning)
  is being handed to another agent to run unsupervised (a long-running
  background job, a detached terminal session), use
  [`_template/00-step-handoff.md`](_template/00-step-handoff.md) instead of
  the plain step doc. Same core sections, plus a notification policy,
  resource guardrails, a live status log for cross-session status checks,
  and a closing report.
- **Post-mortems** — when a step's execution finishes (or hits its limit),
  its outcome is recorded in `postmortems/NN-<step-name>.md`, copied from
  [`_template/postmortems/AGENT-POSTMORTEM.md`](_template/postmortems/AGENT-POSTMORTEM.md)
  and numbered to match its step doc. Blameless: task-design, own-process,
  and human-steer faults alike. This is the durable "what we learned / what
  we're keeping" record after a handoff pass — a primary input for refining
  the step and for any skill distilled from it.
- **Open questions carry a current lean**, not a blank. If it's genuinely
  unresolved, say so plainly — but state which way you're currently leaning
  and why, so the next reader isn't starting from zero.
- **Status lines are the source of truth for progress** — this is what
  replaces a separate daily-notes/progress log. Update the folder's
  `README.md` status line whenever a step's state changes, don't let it go
  stale.
- **Handoffs to worker sessions:** one task doc per worker, a row in [`BOARD.md`](BOARD.md) (supervisor only), run
  names claimed once and never reused. The supervisor steers a running worker only through the doc's
  `Supervisor instructions` (re-read by the worker at every check); the worker answers through `Open Questions` and
  its Live status log, and asks mid-run questions without stopping a running job unless it is diverging.
- **Compute per handoff** is set by the user every time, after the supervisor has checked what is free
  (`.claude/SETUP.md` + live `sinfo` / `nvidia-smi`), and is written into the doc as GPU type, count, GPU-hours.
- **Code changes by workers** happen in a git worktree at `.worktrees/<run>` on branch `wt/<run>` inside the
  project (gitignored), behind default-OFF flags; the supervisor merges. Nothing is created outside the project.
- **Measured results** carry a reading fixed before the first number (threshold + paired count), and, where they
  apply, a premise gate, a reproduction gate and a null control (see the training-handoff template).
- Link back to [`.claude/research/objectives.md`](../research/objectives.md)
  for which phase maps to which project-level goal.

## Current phases

| Folder | Status |
|---|---|
| [00-<phase>/](00-<phase>/) | [Not started] |

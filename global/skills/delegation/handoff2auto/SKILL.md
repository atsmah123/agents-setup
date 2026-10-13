---
name: "handoff2auto"
description: "Hand off a long-running or multi-step task to an agent that keeps working after this conversation ends -- a detached terminal/screen session, a background job, a multi-day compute run. Produces a durable task doc plus a pasteable handoff message. Use whenever the user says 'handoff', 'handover', or 'hand this off', or describes continuing work in a background/detached session, an overnight run, or anything that needs to survive them closing their laptop -- including multi-day HPC jobs and long AI training/inference runs. Also use it PROACTIVELY (as a suggestion, always confirm first, never invoke unprompted) when a task's human decisions are mostly resolved in conversation and what's left is largely mechanical or just needs wall-clock time. Also use it when the user asks to check status on an existing handoff ('check on X', 'how's the Y task doing'). Not for same-session subagent delegation -- use the Agent tool for bounded, supervised work instead."
---

First, decide whether this is **creating a new handoff**, **updating an existing one**, or a
**status check** on one already in flight.

A handoff is different from spawning a subagent with the Agent tool. A subagent lives and dies
within this session -- it's for bounded work you want off your plate but still supervised. A
handoff is for work that has to survive the user closing their laptop: it needs to be findable
and resumable by an agent (possibly a different one, possibly days later) with zero memory of
this conversation.

## Creating or updating a handoff

### 1. Ask before you write anything

The task doc is the *only* thing the receiving agent has -- no access to this conversation, no
way to ask a follow-up mid-task. Anything left ambiguous here either stalls the handoff agent or
gets silently guessed at, and a guess made under autonomous momentum is much harder to walk back
than a five-minute question now. So before drafting, work through what's still unresolved:

- **Stop gates.** Where should the handoff agent stop and wait for a human, versus proceed on its
  own? Push for concrete, checkable conditions ("if X exceeds Y, stop") over vague ones ("use
  good judgment") -- a vague gate gets rationalized away under momentum, a specific one doesn't.
- **Resource guardrails.** Whatever budget/quota/concurrency limits apply -- compute budget, job
  queue concurrency caps, API rate limits, spend caps.
- **What's already decided vs. still open.** Pull this from the conversation, but confirm rather
  than assume -- it's easy to mistake a "probably" for a settled decision.
- **Notifications.** Which milestones actually warrant interrupting the user (a real fork, a
  failure, completion) versus routine progress that shouldn't page anyone.
- **Do-not-touch list.** Anything already done or out of scope that the handoff agent might
  otherwise "helpfully" redo or modify.
- **Documentation rigor for this task.** Not every handoff needs the same depth. A quick retry
  job might just need a light doc -- goal, plan, one or two guardrails. Something with real
  unknowns (an unproven approach, a tricky resource/stability boundary, multiple plausible
  failure modes) earns a fuller write-up -- detailed Reference section with numbers, explicit
  stop-gates for each fork, the works. Ask which this is rather than defaulting to either extreme;
  a light task over-documented wastes the user's time reviewing it, a genuinely risky one
  under-documented sends the handoff agent in without what it needs.

Use `AskUserQuestion` for anything with discrete options, plain questions otherwise. Don't move
on until these are actually resolved, not just asked.

### 2. Find the template and the task-folder convention

Read `$AGENTS_SETUP/templates/project/tasks/_template/00-step-handoff.md` directly -- it defines
the section structure to fill in (Status/Depends-on/Blocks/Handed-off header, then Goal,
Reference, Plan, Acceptance check, Open Questions, Notification policy, Resource guardrails, Live
status log, Final report).

**For a large model-training/eval handoff** -- anything where the agent will launch GPU/compute
runs, iterate on an architecture or hyperparameters, and judge success from *metrics* rather than
a pass/fail check -- use the specialized variant
`$AGENTS_SETUP/templates/project/tasks/_template/00-step-training-handoff.md` instead. It keeps
the base sections and adds the ones training-handoffs repeatedly need: a **staged eval protocol**
(cheap signals every run, the full metric battery only at milestones -- so the agent doesn't burn
context re-evaluating everything each iteration), **compute guardrails** (GPU concurrency cap,
smoke-first, early-abort, per-stage run budget), a **silent-failure/collapse watch** (the failure
mode where the loss looks fine but the model is broken -- collapse, posterior collapse,
over-smoothing), an **architecture-modification autonomy envelope** (free / notify / hard-stop,
with git-worktree isolation), a **data-scale gate** (is expanding the data in-scope or a
stop-and-ask -- a predictable binding constraint that's easy to omit), and **experiment-tracking
wiring**. Pick this variant whenever the step-1 questions surface GPU runs / metric-driven success
/ architecture search; use the plain `00-step-handoff.md` for non-training background jobs.

Some projects predate these templates and won't have a local copy under their own
`.claude/tasks/_template/` -- that's fine, always read the canonical copy above rather than
assuming a project-local one exists.

Detect where the task doc should live from the project's `CLAUDE.md` and `.claude/tasks/README.md`
(typically `.claude/tasks/<phase-folder>/00-step-handoff.md`, or the next free step number in
whichever phase this belongs to). If a task doc for this same task already exists, update it in
place instead of creating a duplicate -- check before assuming this is new. If the project has no
`tasks/` convention at all, ask the user where they want it rather than guessing.

### 3. Write the task doc

Fill in every section using what step 1 surfaced. A few things worth getting right:

- **Reference** should include not just what's already done, but what's already been *tried and
  learned* -- including dead ends, with their actual numbers. A documented failure saves the
  handoff agent from re-deriving or re-crashing into the same wall; an undocumented one gets
  silently repeated.
- **Plan** steps that are stop-gates need to read as hard requirements ("STOP and report back"),
  not soft suggestions ("consider stopping if..."). Soft gates get worked around under autonomous
  execution; explicit ones don't.
- **Checkpoint/resource-window math**, if this task resumes a long-running process via
  checkpoints: tell whoever executes the Plan to verify the checkpoint/save interval actually
  fits inside whatever resource-allocation window it runs under -- an HPC job's walltime, a
  preemptible/spot instance's eviction window, a time-limited session, an API quota window.
  Getting cut off before reaching your own checkpoint interval silently wastes that entire
  segment's work with nothing saved. This applies to compute jobs, AI training runs, and
  inference batches alike -- always spell this arithmetic out explicitly in the Plan rather than
  assuming a chosen interval fits.
- **Live status log** starts empty -- it's what the handoff agent appends to, not something filled
  in now.
- **Final report** starts as an empty stub with a one-line reminder of when to fill it in (task
  fully done, or permanently stopped -- not incrementally).
- **Notification policy**: note that some notification tools silently no-op if the harness judges
  the session "actively being watched" by its user -- expected behavior, not a failure, worth the
  handoff agent knowing so it doesn't mistake a quiet notification for a broken one.

### 4. Write the handoff message

A short, pasteable, standalone message -- not a file the receiving agent has to go find first,
though it should point at the task doc as the full reference. Include:

1. Working directory.
2. A pointer to the task doc, with an instruction to read it in full before doing anything else.
3. Ordered first actions -- especially anything already in flight (a running job, a pending
   decision) that needs picking up immediately.
4. The autonomy boundary, stated again inline -- don't rely on "see the task doc" alone; it's the
   single most important constraint and deserves saying twice.
5. A notification reminder.
6. Explicit exclusions -- what not to touch.
7. A closing instruction to work autonomously and only check in at the gates specified.

If the project has a `.claude/tasks/BOARD.md`, add a row for this task (or update its existing
row): the task, the task doc's path, status `handed off`, today's date.

Show both the task doc's location and the full handoff message text to the user when done, so
they can paste the message directly.

## Status-check mode

Don't reconstruct history from job logs or guesswork -- the task doc's Live status log exists
precisely so this doesn't have to happen.

1. Find the task doc (ask if you don't know which task, or check the project's `.claude/tasks/`
   folders for anything with a "Handed off" status).
2. Read its Live status log and Open Questions first -- that's most of the answer.
3. Cross-reference live state relevant to the domain (job queue status, whether expected files
   exist, a log tail) to corroborate or catch anything the log hasn't captured yet.
4. Report back concisely: current state, what's blocked (if anything, and on what decision), and
   what happens next.

If the task doc's Status says "Blocked -- needs human decision," lead with that and the actual
Open Question, not a generic status summary -- that's what the user needs to act on.

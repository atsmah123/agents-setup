# [Stage] — [Task Name] (autonomous training handoff)

**Status:** [Not started | In progress | STOPPED — needs human decision | Done] ([YYYY-MM-DD])
**Depends on:** [prior stage, or "none"]
**Blocks:** [downstream stage(s) this gates, or "nothing yet"]
**Handed off:** [YYYY-MM-DD] to [a detached tmux/screen session | Remote Control session | ...] —
see Live status log for what's happened since.

Use this variant (not `00-step.md` or the plain `00-step-handoff.md`) when the handed-off work is
**training or evaluating a large model** with little/no live supervision — anything where the
agent will launch GPU/compute runs, iterate on an architecture or hyperparameters, and judge
success from metrics rather than a pass/fail check. It keeps the base handoff sections and adds
the ones training-handoffs repeatedly need: a **staged eval protocol**, **compute guardrails**, a
**silent-failure / collapse watch**, an **architecture-modification autonomy envelope**, a
**data-scale gate**, and **experiment-tracking wiring**. Delete any prompt that genuinely doesn't
apply — but delete it deliberately, don't skip it silently.

---

## Goal

[What this stage produces and why it's scoped this way — for an agent with ZERO conversation
history. State plainly what "done" looks like as a *model outcome* (e.g. "an AE that reconstructs
field X to rel-L2 < Y", "a JEPA trunk that trains without representation collapse"), not just
"train a model". If this is one stage of a sequence, say where it sits and what the next stage
inherits. Call out structural decisions inherited from earlier discussion, with a pointer to
where they were made.]

## Reference (precedent to reuse — do NOT re-derive OR re-crash-into)

[- **What to build on:** existing code/architectures to port or adapt, with exact paths. If
  porting from another project/branch, prefer a read-only snapshot over a live cross-project
  import (so the agent can't touch the source).
- **What's SETTLED** (implement as-is; changing it is a hard-stop — cross-reference the Autonomy
  envelope): fixed architecture decisions, data representation, input shapes, conventions.
- **What NOT to port / do-not-touch:** dead ends and things that look reusable but aren't, with
  the reason. A documented failure (with its numbers) is worth as much as a success — it's the
  difference between the next agent avoiding a wall and walking into it.
- **The data:** exact dataset/loader, path, current scale (N samples/runs), splits,
  normalization, what each field is. See also the Data-scale gate below.
- **Environment facts:** working dir + is-it-a-git-repo, where checkpoints/logs go, the compute
  environment, which venv/interpreter, any auth already in place. Don't make the agent re-derive
  these.]

## Plan

Staged so cheap signals drive iteration and expensive evaluation happens only at milestones (see
Eval protocol). Typical shape:

1. **Scaffold + smoke-first.** Build/port the model + training loop. Before ANY long run, run a
   tiny smoke run (≤N steps, 1 GPU, tiny batch) proving: no crash, loss finite, loss decreasing.
   Most wasted compute is one broken config launched many ways — smoke-first kills that at run 1.
2. **Iterate (cheap signals only).** [The architecture/hyperparameter search. Watch ONLY the
   cheap continuous signals here — see Eval protocol; do NOT run the full eval suite per run.]
3. [... stage-specific steps. Where a step is a hard stop, write it as a requirement — "if X,
   STOP and report" — not a suggestion. Soft gates get rationalized away under autonomous
   momentum; explicit ones don't.]
4. **Validate (full eval, once).** On the converged model, run the full eval battery ONCE as the
   deliverable artifact set, then notify for the review gate.

**Run budget:** aim to converge within ~[N] training runs. If you hit ~[N] without converging,
STOP and report what you tried and the tradeoffs seen — that's a report-to-human moment, not a
launch-run-(N+1) moment.

## Eval protocol (staged — this is the part a generic handoff misses)

Running every metric on every run wastes context and isn't needed to choose a model. Split by
cost:

- **[cont] — cheap scalars, log every run** (to the experiment tracker, near-zero context cost):
  train/val loss, [+ the 1–2 signals that gate an iteration decision, e.g. a specific artifact
  check that gates a settled design choice; a proto-failure scalar like latent variance].
- **[gate] — expensive renders/computes, milestone only** (the full battery, run once on the
  converged model as the deliverable): [list the metrics — e.g. per-field relative error in
  physical units, spatial error maps, spectral/over-smoothing checks, integrated-quantity
  consistency, per-subgroup breakdown, worst-N samples, before/after renders].

**Explicit instruction to the agent:** do NOT run the [gate] suite per training run — loss +
[the gating signal] only during iteration; full suite once at the deliverable.

**Report metrics per-[subgroup]** (e.g. per-dataset / per-class / per-regime), not just pooled —
a model that works on one subgroup and fails another is a headline finding, not a footnote, and
pooled numbers hide it. Report errors in interpretable **physical/original units**, not
normalized space.

**FIXATE on ONE primary target — do not multi-objective-score yourself into paralysis.** The
single most common failure mode observed: an agent given ~8 acceptance metrics treats them as
co-equal, wanders across all of them, and can't tell whether it's making progress. Pick the ONE
(or at most two) metric that IS the goal (e.g. "<1% relative-L2 on <the field(s) that matter>, on
<the driving measurement space>"), state it as the sole gate, and demote every other metric to
"reported diagnostic, not a gate." If two candidate targets are strongly correlated (the agent
often discovers this), name the correlation and drive on ONE of them. A crisp single target is
what keeps an autonomous search grounded; a scorecard of eight is what lets it drift.

**Standing rule — do NOT invent metrics mid-search.** If a new number seems needed: name it,
define it against the primary metric, and justify why the primary is insufficient — BEFORE it
appears in any table. (Observed failure: an agent invented "variance explained" — a different
denominator that rendered a 29% error as "87%" — and a `k=3` smoothing column, and led with both;
both moved the apparent result in the flattering direction. That is not a coincidence to police
informally. New metrics that make the work look better are the ones to distrust most.)

**GROUND the search before sweeping — canonical ladder** (prevents the two classic errors:
concluding "factor X doesn't matter" from a mis-ordered test, and searching architecture when the
bug is in your own code):
1. **Overfit a SINGLE sample to near-perfect** first. If the model cannot drive one sample's
   error ≪ target, the code/architecture is broken — fix that before anything else. This is the
   cheapest possible sanity anchor and it grounds every later comparison.
2. **Reference-implementation parity** (if one exists — e.g. a `diffusers`/HF/library model of the
   same class): at matched settings, your implementation must match the reference on that same
   single-sample (then small-N) test. If yours underperforms, the bug is YOURS, not the
   architecture — STOP and fix before sweeping. This is the single highest-value rung: it converts
   an open-ended search into a binary comparison, and it forecloses the recurring failure of
   blaming the *problem* ("unlearnable noise", "the data is too hard") for a deficiency in your own
   *code*. **If you port/adapt from a source, ALSO diff your port against that source
   feature-for-feature before training** — a silently-dropped block or missing norm/activation is
   invisible to every downstream experiment (observed: a dropped bottleneck-resolution stage went
   unnoticed through ~20 runs).
3. **Only then** grow data / sweep architecture. Never conclude "knob X is irrelevant" from a run
   where a *different* knob dominates (e.g. sweeping channel width at a tiny bottleneck, then
   finding the bottleneck was the real constraint — the width null-result was measured on the
   wrong axis). Prescribe the capacity ladder order explicitly so the agent can't invert it.

## Silent-failure / collapse watch

[The failure mode where **the loss looks fine but the model is actually broken** — the thing a
naive "loss went down → success" check misses. Name it explicitly and say how to detect it.
Examples: representation collapse in self-supervised/JEPA training (latent variance → 0, low
effective rank, while matching loss trends to ~0); posterior collapse in VAEs; over-smoothing
(low MSE by blurring sharp features); a metric gamed by a degenerate solution. State the
detection signal and the threshold/trend that flags it. If there is genuinely no such mode for
this stage, say so — don't leave it blank.]

## Acceptance check (the STOP-gate — what the human reviews)

[Concrete, verifiable, as a model outcome. Include the full [gate] eval results, per-subgroup, in
physical units, beating a stated trivial baseline (e.g. predict-the-mean). Define what "closed"
means: good-enough-to-proceed vs. stop-and-report vs. escalate. It is usually NOT the goal to
reach a *perfect* model at this stage — just one good enough for the next stage, and to have
surfaced any problem for review. Clean commit history (one experiment = one commit, message
stating what changed + resulting metrics) is part of acceptance — the history IS the experiment
log.]

## Autonomy envelope (architecture/hyperparameter search)

**Free to modify (no need to ask):** [the search space that IS the task — e.g. depth, widths,
latent size, LR/optimizer/schedule, batch size, the training loop]. Work in a **git worktree/branch**
so this is isolated and reviewable; commit one experiment per commit.

**Free but MUST NOTIFY** (do it, then tell the human — reversible in the worktree, but they want
to know): [large, evidenced departures — e.g. abandoning the chosen backbone family for another;
falling back to a documented alternative approach; cloning a new external reference].

**HARD STOP-and-ask** (do NOT proceed autonomously): [the design decisions already made that the
agent must not silently overturn — e.g. changing the data representation / input pipeline;
anything belonging to a different stage; changing the fundamental model structure]. See also the
Data-scale gate.

## Data-scale gate

[Whether the current data scale is expected to be sufficient for this stage's target, and — this
is the key prompt — **whether expanding it is in-scope or a hard stop-and-ask.** Data volume is a
predictable binding constraint that's easy to omit until an agent hits it mid-run. State: current
scale, whether the agent may expand it, and if not, that hitting a data-limited ceiling is a
report-and-stop (with what evidence to bring). If a bigger data-prep job (re-processing,
re-tokenizing, downloading) would be needed, that is almost always a separate heavy task, not
part of this handoff.]

## Notification policy

[Which milestones warrant a push/RC notification — the deliverable, a genuine fork, a
stop-gate reached, an unrecoverable failure, a NOTIFY-class autonomy action above — NOT routine
per-run progress (that goes to the Live status log + the experiment tracker, which the human reads
between notifications). One line, <200 chars, lead with the actionable fact. Note: the notify tool
may silently no-op while the human is actively attached to the session — expected, not a failure;
it delivers once they detach. If the human tracks/advises via Remote Control, say so — and that
the agent should watch for and incorporate mid-run advice.]

**WATCHOUT — do not stall waiting on a monitor/background job.** A recurring failure: the agent
launches a training run or a Monitor, then blocks for hours with no progress because the wait
mechanism silently died, the job hung, or nothing re-triggered it. Guard against it:
- When you launch a background run, ALSO define how you'll know it finished or died — a bounded
  wait with a timeout, a completion/failure marker file you poll, or a monitor whose filter covers
  BOTH success AND failure signatures (a monitor that only greps for the success string stays
  silent forever through a crash). Silence is not success.
- Never leave a foreground shell blocking indefinitely on a job. If a wait exceeds a sane bound for
  the work, actively check job/GPU state (`nvidia-smi`, process list, log tail) rather than assume
  it's still progressing.
- If you find yourself with nothing to do because you're "waiting," that is a signal to verify the
  thing you're waiting on is actually alive — not to keep waiting.

## Compute envelope + review checkpoint

Give the agent its RESOURCES and a WALL-CLOCK checkpoint, NOT a run-count budget. (A
run-count budget backfires: it makes the agent ration discrete runs — hoarding, then spending
them badly — and it forces a stop on an arbitrary count, often right when the trend is clearest.
Observed directly: a ~6-run budget pushed 4 of 6 runs into one sweep at the wrong operating point,
then stopped exactly when one more run was most informative.)

[- **Compute envelope:** the resources available (e.g. "N GPUs, cap ≤M concurrent for long runs"),
  how to check availability (`nvidia-smi` / queue) BEFORE every launch, never preempt other
  work/projects. State it as a budget to USE (parallelize freely within it), not ration.
- **Wall-clock review checkpoint (a PAUSE, not a kill):** "work productively for ~X hours, then
  STOP and report progress for human review" — a human-in-loop checkpoint, after which the agent
  may continue. This is what replaces the run budget. It pairs with the grounding ladder (which
  keeps the window from being spent on a bad direction). Pick X to match how long a meaningful
  chunk of progress takes, not an arbitrary cap.
- **Smoke-first and early-abort** (kill on NaN/inf loss, or no improvement past a patience window)
  — strong guidelines; the main defense against wasted compute within the window.
- **Checkpoint interval < any per-run wall-clock cap**, so a stopped/cut-off run never loses a
  full segment. Spell out the arithmetic; don't assume the interval fits the window.
- **Stamp data provenance into every run** — hash the input data + normalization-stats files into
  the run config AND the experiment tracker. Makes a stale-data / mid-run-change error impossible
  to miss rather than reliant on someone noticing (observed: a mid-run dataset rewrite silently
  invalidated an A/B; a version stamp would have caught it for free).
- **Experiment-tracker discipline:** no duplicate/relaunched-identical configs; consistent
  naming.]

## Experiment tracking

[The tracker (e.g. wandb/tensorboard/mlflow): project name, entity/workspace, online-vs-offline
(and the fallback if online auth is unavailable — don't block on it), the run-naming scheme, and
how the human reviews at the gate (the tracker + Live status log + notifications triad). Confirm
auth actually works before relying on it — a stale key fails silently until a run crashes.]

## Live status log

[Append-only, most-recent-last, one short timestamped line per significant action/state change —
runs launched, architectures tried + their headline metric, stop-gates hit. This is what makes
cross-session status-checking work without reconstructing from job logs. Keep the per-run detail
here (and in the tracker), NOT in notifications.]

- [YYYY-MM-DD HH:MM] [what happened / what's running / what's next]

## Final report

[Filled in ONCE, only when the stage is done OR permanently stopped — not incrementally (that's
the Live status log). Cover: the final model/architecture chosen; the full [gate] eval results
per-subgroup; whether any settled assumption was overturned (+ why); artifacts with paths
(checkpoints, tracker run ids/urls); what the next stage inherits and should watch for.]

**If stopped rather than completed:** set Status to "STOPPED — needs human decision", and make
the Open Question(s) explicit — what decision is needed and what's already been ruled out. That
is the actual handoff back to a human; don't bury it.

## Self-review / post-mortem (MANDATORY at task end or limit — do not skip)

When this task finishes OR its wall-clock/limit is reached, fill in the post-mortem form
(copy it from `_template/postmortems/AGENT-POSTMORTEM.md` to this phase folder's
`postmortems/NN-<step-name>.md` — SAME number and name as this step doc, so plan and outcome
pair up). It is a blameless account covering: was it under
control or did it wander; every honest cause of any shortfall across THREE categories —
task-design, your own process, AND human-steer (the human WANTS the steer feedback); the single
change that would most have kept it grounded; and what went right to carry forward. This is a
primary input to refining the template and any eventual skill — a specific, uncomfortable account
is worth far more than a clean-looking one. (The B1-attempt-1 post-mortem in
variational-jepa-generalisation is the worked exemplar.)

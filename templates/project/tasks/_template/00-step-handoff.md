# Step [N] — [Task Name] (autonomous handoff)

**Status:** [Not started | In progress | Blocked — needs human decision | Done] ([YYYY-MM-DD])
**Depends on:** [prior step, or "none"]
**Blocks:** [downstream step(s) this gates, or "nothing yet"]
**Handed off:** [YYYY-MM-DD] to [a detached terminal/screen session | subagent | ...] — see
Live status log below for what's happened since.

Use this variant instead of the plain `00-step.md` when the step's execution itself (not just
its planning) is being handed to another agent to run with little/no live supervision —
typically a long-running background job (compute jobs, multi-hour builds, anything that outlives
a single conversation). Same section vocabulary as the standard step doc, plus four additions at
the end for the parts a supervised step doesn't need: notification policy, resource guardrails, a
running status log, and a closing report.

---

## Goal

[What this step accomplishes and why it's scoped this way — written for an agent with ZERO
conversation history, since that's exactly who reads this first. Call out any structural
decisions inherited from earlier discussion, with a pointer to where they were made.]

## Reference

[Precedent to reuse, so nothing here gets re-derived OR re-crashed-into from scratch:
- What's already done / explicitly do-not-touch.
- What's already been tried and what happened — including dead ends. A failed approach with its
  numbers written down is worth as much here as a successful one; it's the difference between
  the next agent avoiding a known wall and walking straight into it again.
- Environment facts worth not re-deriving (resource/queue limits, paths, current budget or
  allocation balance, etc.).]

## Plan

1. [Concrete step. Where a step is genuinely a hard stop condition — "if X, STOP and report back
   rather than proceeding to Y" — write it as a hard requirement, not a soft suggestion. Under
   autonomous execution, soft gates get worked around; explicit ones don't.]
2. [...]

## Acceptance check

[How you'll know this task is actually, fully done — concrete and verifiable. For a handoff,
also define what "closed" means: when to stop retrying vs. declare done vs. escalate to one of
the Plan's stop conditions instead.]

## Open Questions

- [ ] [Question, with current lean if you have one. Stop conditions triggered during execution
  land here too, until a human resolves them — see the STOPPED-status convention below.]

---

## Notification policy

[Which milestones actually warrant a push notification — genuine forks, failures, or completion,
not routine progress (notification fatigue is a real cost, the tool's own guidance says so).
Message tone: under 200 characters, one line, no markdown, lead with the actionable fact. Note
any environment quirks worth knowing, e.g. some notification tools silently no-op if the harness
judges the session "actively being watched" — that's expected behavior, not a failure, and it
should start delivering once the session is actually unattended.]

## Resource guardrails

[Concurrency/quota limits to check before consequential actions (job queue caps, concurrent-job
limits), budget checks (current balance and where to recheck it), and any "reset stale state
before reuse" gotchas from config/files this step will touch repeatedly.]

## Live status log

[Append-only, most-recent-last, one short timestamped line per significant action or state
change. This is what makes cross-session status-checking work: anyone checking in later —
including a different agent that can't see this session's conversation — reads this section
alone and knows current state without reconstructing it from job logs or file timestamps.]

- [YYYY-MM-DD HH:MM] [what happened / what's running / what's next]

## Final report

[Filled in once, only when this task is fully done OR permanently stopped — not before, and not
incrementally (that's what the Live status log is for). Covers: what was actually done vs. what
the Plan said, final numbers/results, any deviations from the Plan and why, artifacts produced
(files/outputs, with paths), and pointers to follow-up work if anything's left hanging.]

**If stopped rather than completed:** set Status above to "Blocked — needs human decision", and
make sure the Open Questions section states clearly what decision is needed and what's already
been ruled out — that's the actual handoff back to a human, don't bury it only in this section.

## Self-review / post-mortem (MANDATORY at task end or limit — do not skip)

When this task finishes OR its limit is reached, fill in the post-mortem form (copy it from
`_template/postmortems/AGENT-POSTMORTEM.md` to this phase folder's `postmortems/NN-<step-name>.md`
— SAME number and name as this step doc, so plan and outcome pair up). It is a blameless account
of whether the task stayed under control, every honest cause of any shortfall (task-design, your
own process, AND human-steer), the single change that would most have kept it grounded, and what
to carry forward. This is a primary input for refining the task and any eventual skill — a
specific, uncomfortable account is worth more than a clean-looking one.

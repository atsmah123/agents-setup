# Task: Repo Bootstrap + Config Skeleton

**Status:** Partially done (2025-11-03) — Steps 0/1 done, Step 2 not
started. Execution jumped ahead to `01-data-pipeline/` before finishing
this task, since the training-loop infra (Step 2) isn't needed until data
loading is verified — see per-step status below.
**Phase:** 0 of the project's phase breakdown (see [[objectives]] short-term goals)
**Reference repos:** `prior-project-a` (closest structural match, dip into
for config patterns — don't browse broadly, it's a large repo)

This file is an index only — no design detail lives here, see the docs
below for that.

---

## Docs

| File | Purpose |
|---|---|
| [00-directory-skeleton.md](00-directory-skeleton.md) | `src/`, `configs/`, `tests/` layout |
| [01-base-config.md](01-base-config.md) | Path/ID cascade + empty config-group folders |

**External references** (read directly, don't re-derive from memory):
- `prior-project-a/configs/base_config.yaml` — path-cascade idiom this
  design borrows from

---

## Open Questions

- [ ] Which config-composition library to standardize on across phases —
      Current lean: Hydra, since two of three candidate follow-on phases
      already assume it; revisit only if a later phase hits a real
      limitation, not preemptively.

# Step 0 — Directory Skeleton

**Status:** Done
**Depends on:** none
**Blocks:** Step 1 (base config assumes these folders exist)

---

## Goal

Stand up the repo skeleton (`src/`, `configs/`, `tests/`) so later phases
(data pipeline, model, training, evaluation) slot in without reworking the
top-level layout. Structured to anticipate branching from day one, since
this project's downstream phases fork into more than one model variant.

## Reference

`prior-project-a`'s top-level layout — same shape, reused directly rather
than re-derived.

## Plan

1. Create `src/{data,models,training,eval}/`, `configs/`, `tests/`.
2. Add a placeholder `README.md` per `src/` subfolder stating its intended
   scope (not implementation — just what belongs there).
3. Confirm the package imports cleanly (`python -c "import src"`).

## Acceptance check

`python -c "import src"` succeeds with no folders missing from the plan
above.

## Open Questions

- [ ] None currently.

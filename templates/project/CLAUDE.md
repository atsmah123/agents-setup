# Project: [name]

**Purpose:** [one or two sentences: what this project builds and for whom]

**Status:** [Active | Paused | Done]. Started [YYYY-MM-DD]. [Deadlines, if any.]

**New here?** Read [research/objectives.md](research/objectives.md), then the current phase in
[tasks/README.md](tasks/README.md).

## Start of session

Decide your role first:

- **Supervisor:** an interactive session with the user. It plans, decides, keeps the records and
  hands long work to workers.
- **Worker:** a session started from a handoff prompt. It carries out one task doc.

`.claude/scripts/session_start.sh` (a SessionStart hook) prints BOARD, TODO and the latest
CHANGELOG headings into every new session.

The SUPERVISOR reads all four of these BEFORE its first answer -- every session, also one resumed mid-task:

1. `TODO.md` -- open work.
2. `EXPERIMENTS.md`, newest section -- what was last tried and what came out of it.
3. `CHANGELOG.md`, last 3 entries -- newest first, one `## ` heading per entry.
4. `.claude/tasks/BOARD.md` -- work handed to workers, and its state.

Skip any the project doesn't have. The WORKER reads its task doc in full before doing anything
else and works from it alone.

## Supervisor and worker

1. **Size the request.** A read-only check stays in this session; anything longer is a handoff.
2. **Hand off** with `handoff2auto`: a task doc in `.claude/tasks/<phase>/`, a row in
   `.claude/tasks/BOARD.md`, and a handoff prompt the user pastes into a new worker session.
3. **Close out.** When a worker finishes, read its Live status log and post-mortem, then update
   the BOARD row, `TODO.md`, `EXPERIMENTS.md` and `CHANGELOG.md`.

**The supervisor does not run long work itself, even after the user says "go".** Anything that writes code, submits a
GPU job, or takes longer than ~30 min becomes a task doc (`handoff2auto`) + a `BOARD.md` row + a handoff prompt the
user pastes into a worker session. In-session the supervisor only does read-only checks (reading results and logs,
scoring saved predictions, a CPU probe of a few minutes) and the records.

## Paths

- [path] — [one line]

## Working history

@.claude/tasks/README.md

#!/usr/bin/env bash
# SessionStart hook: put the supervisor's start-of-session reading into every new session's context.
cd "$(dirname "$0")/../.." || exit 0
P=$(basename "$PWD")
echo "$P SESSION START -- decide your role first (CLAUDE.md). SUPERVISOR (interactive): read TODO, EXPERIMENTS newest"
echo "section, last 3 CHANGELOG entries and BOARD before the first answer; long work (more than a small code fix, GPU jobs,"
echo ">30 min) goes to a worker via handoff2auto task doc + BOARD row + handoff prompt -- never run directly. For a small"
echo "code fix, ask the user: make it here or hand it off. WORKER: read your task doc in full."
H=$(hostname -s 2>/dev/null || hostname)
if [ -f .claude/SETUP.md ]; then
  echo; echo "=== .claude/SETUP.md (this host: $H -- find its Machine section; none = first session on this machine) ==="
  cat .claude/SETUP.md
else
  echo; echo "!!! No .claude/SETUP.md (host $H): FIRST supervisor session here -- settle paths, environment, compute and"
  echo "    storage with the user and write .claude/SETUP.md before project work (global CLAUDE.md section 8)."
fi
[ -f .claude/tasks/BOARD.md ] && { echo; echo "=== .claude/tasks/BOARD.md ==="; cat .claude/tasks/BOARD.md; }
[ -f TODO.md ] && { echo; echo "=== TODO.md ==="; cat TODO.md; }
[ -f CHANGELOG.md ] && { echo; echo "=== CHANGELOG.md, last 3 entries (headings) ==="; grep -n '^## ' CHANGELOG.md | head -3 | cut -c1-300; }
exit 0

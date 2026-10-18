#!/usr/bin/env bash
# SessionStart hook: put the supervisor's start-of-session reading into every new session's context.
cd "$(dirname "$0")/../.." || exit 0
P=$(basename "$PWD")
echo "$P SESSION START -- decide your role first (CLAUDE.md). SUPERVISOR (interactive): read TODO, EXPERIMENTS newest"
echo "section, last 3 CHANGELOG entries and BOARD before the first answer; long work (more than a small code fix, GPU jobs,"
echo ">30 min) goes to a worker via handoff2auto task doc + BOARD row + handoff prompt -- never run directly. For a small"
echo "code fix, ask the user: make it here or hand it off. WORKER: read your task doc in full."
# This machine's SETUP.md section: a "## Machine:" heading whose "(hosts: ...)" holds backticked shell globs matching
# the short or full hostname. The template's own "[name]" heading never counts.
H=$(hostname -s 2>/dev/null || hostname); F=$(hostname -f 2>/dev/null || hostname)
M="" re='`([^`]+)`(.*)'
if [ -f .claude/SETUP.md ]; then
  while IFS= read -r line; do
    case $line in *"[name]"*) continue ;; *"hosts:"*) ;; *) continue ;; esac
    rest=${line#*hosts:}
    while [[ $rest =~ $re ]]; do
      pat=${BASH_REMATCH[1]} rest=${BASH_REMATCH[2]}
      # shellcheck disable=SC2254  # $pat is meant as a glob
      case $H in $pat) M=$line ;; esac
      case $F in $pat) M=$line ;; esac
    done
    [ -n "$M" ] && break
  done < <(grep '^## Machine:' .claude/SETUP.md)
fi
if [ -n "$M" ]; then
  echo; echo "=== .claude/SETUP.md (this host: $H; its section: ${M#'## '}) ==="
  cat .claude/SETUP.md
else
  echo; echo "!!! FIRST supervisor session on this machine (host $H): .claude/SETUP.md is missing or has no section whose hosts match."
  echo "    Before project work, settle paths, environment, compute and storage with the user and write a section headed"
  echo "    '## Machine: <name> (hosts: \`$H\`)', replacing the template's [name] section if it is still there (global CLAUDE.md section 8)."
  [ -f .claude/SETUP.md ] && { echo; echo "=== .claude/SETUP.md as it stands ==="; cat .claude/SETUP.md; }
fi
[ -f .claude/tasks/BOARD.md ] && { echo; echo "=== .claude/tasks/BOARD.md ==="; cat .claude/tasks/BOARD.md; }
[ -f TODO.md ] && { echo; echo "=== TODO.md ==="; cat TODO.md; }
[ -f CHANGELOG.md ] && { echo; echo "=== CHANGELOG.md, last 3 entries (headings) ==="; grep -n '^## ' CHANGELOG.md | head -3 | cut -c1-300; }
exit 0

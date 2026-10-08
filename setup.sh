#!/usr/bin/env bash
# Install this setup into ~/.claude on the current machine. Safe to re-run.
#   - global/CLAUDE.md          -> ~/.claude/CLAUDE.md
#   - every dir under global/skills/ that holds a SKILL.md -> ~/.claude/skills/<dir name>
#   - AGENTS_SETUP exported in ~/.bashrc / ~/.zshrc (skills read templates/ through it)
# Anything real already at a destination is moved aside to <name>.bak.<timestamp>, never deleted.
set -euo pipefail

AGENTS_SETUP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
mkdir -p "$CLAUDE_HOME/skills"

link() {
  local src=$1 dest=$2
  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    mv "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"
    echo "backed up $dest"
  fi
  ln -s "$src" "$dest"
  echo "linked $dest -> $src"
}

link "$AGENTS_SETUP/global/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"

# Skills are grouped in the source tree (global/skills/<group>/<skill>/SKILL.md) but Claude Code
# only reads ~/.claude/skills/<skill>/, so each skill is linked flat under its own name. A group
# folder that gets its own SKILL.md (a router) is linked the same way, under the group's name.
find "$AGENTS_SETUP/global/skills" -name SKILL.md | sort | while read -r f; do
  d=$(dirname "$f")
  link "$d" "$CLAUDE_HOME/skills/$(basename "$d")"
done

start='# >>> agents-setup >>>'
end='# <<< agents-setup <<<'
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [ -f "$rc" ] || continue
  # drop an earlier block (the repo may have moved), then put the current one at the TOP: a
  # stock ~/.bashrc returns early for non-interactive shells, and agents' tool shells are those
  { printf '%s\nexport AGENTS_SETUP="%s"\n%s\n' "$start" "$AGENTS_SETUP" "$end"
    awk -v s="$start" -v e="$end" '$0==s{skip=1} !skip{print} $0==e{skip=0}' "$rc"; } > "$rc.tmp"
  cat "$rc.tmp" > "$rc" && rm "$rc.tmp"
  echo "AGENTS_SETUP set in $rc"
done

echo "done. open a new shell (or: export AGENTS_SETUP=\"$AGENTS_SETUP\")"

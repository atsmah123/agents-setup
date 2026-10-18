#!/usr/bin/env bash
# Scaffold <project>/.claude/ from templates/project/. Only adds missing files; never overwrites.
# Usage: ./init-project.sh [project dir, default .]
# A project that keeps its CLAUDE.md at the root gets no .claude/CLAUDE.md: Claude Code would load both.
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/templates/project"
dest="${1:-.}/.claude"

(cd "$src" && find . -type f) | sort | while read -r f; do
  [ "$f" = ./CLAUDE.md ] && { [ -e "${1:-.}/CLAUDE.md" ] || [ -L "${1:-.}/CLAUDE.md" ]; } && continue
  if [ ! -e "$dest/$f" ] && [ ! -L "$dest/$f" ]; then   # a dangling link is setup.sh's to migrate, not ours
    mkdir -p "$(dirname "$dest/$f")"
    cp "$src/$f" "$dest/$f"
    echo "added .claude/${f#./}"
  fi
done

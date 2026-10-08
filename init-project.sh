#!/usr/bin/env bash
# Scaffold <project>/.claude/ from templates/project/. Only adds missing files; never overwrites.
# Usage: ./init-project.sh [project dir, default .]
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/templates/project"
dest="${1:-.}/.claude"

(cd "$src" && find . -type f) | sort | while read -r f; do
  if [ ! -e "$dest/$f" ]; then
    mkdir -p "$(dirname "$dest/$f")"
    cp "$src/$f" "$dest/$f"
    echo "added .claude/${f#./}"
  fi
done

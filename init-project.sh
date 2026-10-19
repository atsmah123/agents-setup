#!/usr/bin/env bash
# Scaffold <project>/.claude/ from templates/project/. Only adds missing files; never overwrites.
# Usage: ./init-project.sh [--hook-only] [project dir, default .]
#   --hook-only   only make sure the startup hook works: scripts/session_start.sh present and runnable, and wired in
#                 settings.json (setup.sh runs this on every project it set up earlier)
# A project that keeps its CLAUDE.md at the root gets no .claude/CLAUDE.md: Claude Code would load both.
# A project with its own .claude/settings.json gets the SessionStart hook added to it; nothing else there changes.
set -euo pipefail

hook_only=0; [ "${1:-}" = --hook-only ] && { hook_only=1; shift; }
src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/templates/project"
dest="${1:-.}/.claude"

(cd "$src" && find . -type f) | sort | while read -r f; do
  [ "$hook_only" = 1 ] && case $f in ./settings.json|./scripts/session_start.sh) ;; *) continue ;; esac
  [ "$f" = ./CLAUDE.md ] && { [ -e "${1:-.}/CLAUDE.md" ] || [ -L "${1:-.}/CLAUDE.md" ]; } && continue
  if [ ! -e "$dest/$f" ] && [ ! -L "$dest/$f" ]; then   # a dangling link is setup.sh's to migrate, not ours
    mkdir -p "$(dirname "$dest/$f")"
    cp "$src/$f" "$dest/$f"
    echo "added .claude/${f#./}"
  fi
done

# A startup script that lost its executable bit fails silently (the hook swallows errors).
script="$dest/scripts/session_start.sh"
if [ -f "$script" ] && [ ! -x "$script" ]; then chmod +x "$script" && echo "made .claude/scripts/session_start.sh runnable"; fi

# An existing settings.json keeps everything it has; only the hook that runs scripts/session_start.sh is added.
settings="$dest/settings.json"
if [ -f "$settings" ] && [ ! -L "$settings" ] && ! grep -q 'session_start\.sh' "$settings"; then
  if command -v python3 >/dev/null; then
    python3 - "$settings" "$src/settings.json" <<'PY' && echo "added the SessionStart hook to .claude/settings.json"
import json, sys
path, template = sys.argv[1], sys.argv[2]
try:
    with open(path) as f:
        settings = json.load(f)
except ValueError:
    sys.exit("could not add the SessionStart hook: .claude/settings.json is not plain JSON; add it by hand")
with open(template) as f:
    hook = json.load(f)["hooks"]["SessionStart"]
settings.setdefault("hooks", {}).setdefault("SessionStart", []).extend(hook)
with open(path, "w") as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
    f.write("\n")
PY
  else
    echo "could not add the SessionStart hook (no python3): copy the hooks block from templates/project/settings.json"
  fi
fi

exit 0

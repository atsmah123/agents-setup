#!/usr/bin/env bash
# Optional: keep project files that can't live in their own repo (the repo is public or a team's, or the folder is
# not a repo) in a private git repo of your own, and put them back on every machine.
#
# The private repo mirrors your projects folder: <private repo>/<path> is <projects folder>/<path>. Its `paths` file
# lists what to keep, one path per line relative to the projects folder (a trailing / keeps a whole folder); a line
# starting with ! is an rsync exclude pattern, and # starts a comment.
#
#   ./private.sh restore   update the private repo and copy its files into your projects; never overwrites
#   ./private.sh save      copy the listed files from your projects into the private repo, commit and push
#
# ./setup.sh --private <git URL> remembers the repo (cloned to .private/ here) and runs restore on every setup.
set -euo pipefail

AGENTS_SETUP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/agents-setup"
dir="$AGENTS_SETUP/.private"
case "${1:-}" in save|restore) ;; *) sed -n '2,12p' "$0"; exit 2 ;; esac
[ -s "$CONFIG/private-repo" ] || { echo "no private repo set up: run ./setup.sh --private <git URL>" >&2; exit 1; }
projects=$(cat "$CONFIG/projects-dir" 2>/dev/null || echo "$HOME/projects")

if [ -d "$dir/.git" ]; then
  git -C "$dir" pull -q --ff-only || echo "could not update $dir; using what is here"
else
  git clone -q "$(cat "$CONFIG/private-repo")" "$dir"
fi
[ -f "$dir/paths" ] || { echo "$dir/paths is missing: list the files to keep there" >&2; exit 1; }

paths=() excl=()
while IFS= read -r l; do
  l=${l%%#*}; l=${l#"${l%%[![:space:]]*}"}; l=${l%"${l##*[![:space:]]}"}
  case $l in "") ;; !*) excl+=(--exclude "${l#!}") ;; *) paths+=("$l") ;; esac
done < "$dir/paths"

if [ "$1" = restore ]; then
  for p in "${paths[@]}"; do
    [ -e "$dir/$p" ] || continue
    # only into projects this machine has: the folder above the path's .claude/ (or above the file)
    q=${p%/}; proj=${q%%/.claude*}; [ "$proj" = "$q" ] && proj=$(dirname "$q")
    [ -d "$projects/$proj" ] || { echo "skipped $p (no $proj here)"; continue; }
    rsync -a --relative --ignore-existing --out-format='restored %n' "${excl[@]}" "$dir/./$p" "$projects/" \
      | { grep -v '/$' || true; }                         # list files put back, not folders
  done
  exit 0
fi
for p in "${paths[@]}"; do
  [ -e "$projects/$p" ] && rsync -a --relative --delete "${excl[@]}" "$projects/./$p" "$dir/"
done
git -C "$dir" add -A
if git -C "$dir" diff --cached --quiet; then echo "nothing changed"; exit 0; fi
git -C "$dir" commit -q -m "save from $(hostname -s) $(date +%F)"
git -C "$dir" push -q && echo "saved and pushed: $(git -C "$dir" log --oneline -1)"

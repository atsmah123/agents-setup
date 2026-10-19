#!/usr/bin/env bash
# Install agents-setup on this machine. Safe to re-run.
#   - global/CLAUDE.md -> ~/.claude/CLAUDE.md and every skill dir -> ~/.claude/skills/<name> (symlinks)
#   - asks once where your projects live (default ~/projects) and remembers it
#   - restores your private project files, if you keep them in a private repo (--private URL, see private.sh)
#   - lists the projects it finds there and sets up the ones you pick: init-project.sh adds missing .claude/ files
#     (never overwrites), and each is recorded in ~/.config/agents-setup/projects -- machine-local, never in this repo
#   - AGENTS_SETUP exported at the top of ~/.bashrc / ~/.zshrc (skills read templates/ through it)
#
# Never displaces what you already have: a real file or a foreign symlink at a destination is left alone and
# listed with a diff command, so you can merge by hand. Only links that point into this repo are refreshed.
# --replace moves an existing destination aside to <name>.bak.<timestamp> and links instead (the old behaviour).
#
# Usage: ./setup.sh [--projects-dir DIR] [--project DIR]... [--private GIT_URL] [--replace] [--no-ask]
set -euo pipefail

AGENTS_SETUP="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/agents-setup"
REGISTRY="$CONFIG/projects"
replace=0 ask=1 projects=() projects_dir="" private_repo=""
while [ $# -gt 0 ]; do
  case $1 in
    --replace) replace=1 ;;
    --no-ask) ask=0 ;;
    --project) shift; projects+=("$1") ;;
    --projects-dir) shift; projects_dir="$1" ;;
    --private) shift; private_repo="$1" ;;
    -h|--help) sed -n '2,14p' "$0"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done
mkdir -p "$CLAUDE_HOME/skills" "$CONFIG"
touch "$REGISTRY"
kept=()

link() {
  local src=$1 dest=$2
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "ok      $dest"; return
  fi
  if [ -L "$dest" ] && case "$(readlink "$dest")" in "$AGENTS_SETUP"/*) true ;; *) false ;; esac; then
    rm "$dest"                                          # our own link, from an older layout: refresh it
  elif [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ "$replace" = 1 ]; then
      mv "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"; echo "backed up $dest"
    else
      kept+=("$dest|$src"); echo "kept    $dest (yours; not replaced)"; return
    fi
  fi
  ln -s "$src" "$dest"
  echo "linked  $dest -> $src"
}

link "$AGENTS_SETUP/global/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"

# Skills are grouped in the source tree (global/skills/<group>/<skill>/SKILL.md) but Claude Code only reads
# ~/.claude/skills/<skill>/, so each skill is linked flat under its own name.
while read -r f; do
  d=$(dirname "$f")
  link "$d" "$CLAUDE_HOME/skills/$(basename "$d")"
done < <(find "$AGENTS_SETUP/global/skills" -name SKILL.md | sort)

interactive=0; [ "$ask" = 1 ] && [ -t 0 ] && interactive=1

# The projects folder: where your project repos live. Asked once, remembered in $CONFIG/projects-dir.
[ -z "$projects_dir" ] && [ -s "$CONFIG/projects-dir" ] && projects_dir=$(cat "$CONFIG/projects-dir")
if [ -z "$projects_dir" ]; then
  projects_dir="$HOME/projects"
  if [ "$interactive" = 1 ]; then
    ans=""; echo; read -r -p "Where do your projects live? [$projects_dir] " ans || true
    [ -n "${ans:-}" ] && projects_dir=$ans
  fi
fi
projects_dir="${projects_dir/#\~/$HOME}"
if [ -d "$projects_dir" ]; then
  projects_dir="$(cd "$projects_dir" && pwd)"
  echo "$projects_dir" > "$CONFIG/projects-dir"
  echo "projects folder: $projects_dir"
else
  echo "projects folder $projects_dir does not exist (yet): skipped finding projects there"; projects_dir=""
fi

# One-time migration: earlier versions linked per-directory files from a workspaces/ folder in this repo into
# project directories. Such a link becomes a real copy if its file is still here; otherwise the broken link is
# removed, so a private repo (--private) can put the file back in the restore below.
roots=()
while read -r p; do [ -n "$p" ] && roots+=("$p"); done < "$REGISTRY"
[ -n "$projects_dir" ] && roots+=("$projects_dir")
for root in "${roots[@]}"; do
  [ -d "$root" ] || continue
  while read -r l; do
    rel=$(readlink "$l"); rel=${rel#"$AGENTS_SETUP"/}
    if [ -f "$AGENTS_SETUP/$rel" ]; then
      cp "$AGENTS_SETUP/$rel" "$l.agents-setup-copy" && mv "$l.agents-setup-copy" "$l"
      echo "copied  $l (was a link into this repo)"
    else
      rm "$l"; echo "removed $l (a broken link to $rel; your private repo restores it if it keeps it)"
    fi
  # the links only ever sat at <dir>[/<repo>]/CLAUDE.md and inside its .claude/ (two levels): look exactly there,
  # never walk the whole folder, which on a big data disk takes forever
  done < <(for l in "$root"/{,*/,*/*/}{CLAUDE.md,.claude/*,.claude/*/*}; do
             [ -L "$l" ] && case "$(readlink "$l")" in "$AGENTS_SETUP"/workspaces/*) echo "$l" ;; esac
           done)
done

# Private project files (optional, see private.sh). Restored BEFORE the template below, because both only add
# missing files: whichever lands first is kept, and the real files must win over blank templates.
[ -n "$private_repo" ] && echo "$private_repo" > "$CONFIG/private-repo"
if [ -n "$projects_dir" ] && [ -s "$CONFIG/private-repo" ]; then
  "$AGENTS_SETUP/private.sh" restore || echo "private files not restored (see the error above); setup goes on without them"
fi

# Projects: directories that get a project .claude/ skeleton and are switched into by shell/project-env.sh.
# Found in the projects folder: every folder in it, and every repo inside a folder that is not itself a repo
# (a workspace folder holding several repos). This clone is never one.
if [ -n "$projects_dir" ]; then
  new=()
  for d in "$projects_dir"/*/; do
    d=${d%/}; [ -d "$d" ] && [ "$d" != "$AGENTS_SETUP" ] || continue
    grep -qxF "$d" "$REGISTRY" || new+=("$d")
    [ -e "$d/.git" ] && continue
    for s in "$d"/*/; do
      s=${s%/}; [ -e "$s/.git" ] && ! grep -qxF "$s" "$REGISTRY" && new+=("$s")
    done
  done
  if [ ${#new[@]} -gt 0 ] && [ "$interactive" = 1 ]; then
    echo; echo "Projects found in $projects_dir, not set up yet:"
    for d in "${new[@]}"; do echo "  ${d#"$projects_dir"/}"; done
    ans="" picked=(); read -r -p "Set them all up? [Y/n] " ans || true
    case ${ans:-y} in
      [Yy]*) projects+=("${new[@]}") ;;
      *) read -r -p "Which ones? (names as listed, space-separated; empty for none) " -a picked || true
         for n in "${picked[@]}"; do projects+=("$projects_dir/$n"); done ;;
    esac
  elif [ ${#new[@]} -gt 0 ]; then
    echo "${#new[@]} project(s) in $projects_dir not set up yet; run ./setup.sh in a terminal to pick them"
  fi
fi
for p in "${projects[@]}"; do
  [ -n "$p" ] || continue
  p="${p/#\~/$HOME}"
  if [ ! -d "$p" ]; then echo "skipped project $p: no such directory"; continue; fi
  p="$(cd "$p" && pwd)"
  "$AGENTS_SETUP/init-project.sh" "$p" | sed "s|^|  $p: |"
  grep -qxF "$p" "$REGISTRY" || echo "$p" >> "$REGISTRY"
  echo "project $p"
done

start='# >>> agents-setup >>>'
end='# <<< agents-setup <<<'
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [ -f "$rc" ] || continue
  # drop an earlier block (the repo may have moved), then put the current one at the TOP: a stock ~/.bashrc
  # returns early for non-interactive shells, and agents' tool shells are those
  { printf '%s\nexport AGENTS_SETUP="%s"\n[[ $- == *i* ]] && . "$AGENTS_SETUP/shell/project-env.sh"\n%s\n' "$start" "$AGENTS_SETUP" "$end"
    awk -v s="$start" -v e="$end" '$0==s{skip=1} !skip{print} $0==e{skip=0}' "$rc"; } > "$rc.tmp"
  cat "$rc.tmp" > "$rc" && rm "$rc.tmp"
  echo "AGENTS_SETUP set in $rc"
done

if [ ${#kept[@]} -gt 0 ]; then
  echo; echo "Left alone (already yours). Merge by hand if you want this repo's version, or re-run with --replace:"
  for k in "${kept[@]}"; do echo "  diff -r ${k%%|*} ${k#*|}"; done
fi
echo "done. open a new shell (or: export AGENTS_SETUP=\"$AGENTS_SETUP\")"

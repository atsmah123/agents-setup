# Switch Python environment automatically as you cd around $PROJECTS_DIR (default ~/projects).
# Sourced by the agents-setup block in ~/.bashrc / ~/.zshrc, interactive shells only.
#
# At each prompt, walk up from the current directory to $PROJECTS_DIR. The first directory with
#   .conda-env   (one line: a conda env name)  -> conda activate that env
#   .venv/       (a virtualenv)                 -> source .venv/bin/activate
# wins. Anywhere else under $PROJECTS_DIR the `projects` conda env (envs/projects.yml) is used;
# outside it, everything is deactivated. Nothing happens unless the target changes, so a
# manual `conda activate` lasts until you move to a directory with a different target.

_project_env_target() {
  local root="${PROJECTS_DIR:-$HOME/projects}" d="$PWD"
  case "$d/" in "$root"/*) ;; *) return ;; esac
  while :; do
    if [ -f "$d/.conda-env" ]; then echo "conda:$(head -n1 "$d/.conda-env")"; return; fi
    if [ -f "$d/.venv/bin/activate" ]; then echo "venv:$d/.venv"; return; fi
    [ "$d" = "$root" ] && break
    d=$(dirname "$d")
  done
  echo "conda:projects"
}

_project_env_switch() {
  local rc=$? target  # keep $? intact for prompts that show the last exit code
  target=$(_project_env_target)
  [ "$target" = "${_PROJECT_ENV-}" ] && return $rc
  if [ -n "${VIRTUAL_ENV-}" ] && type deactivate >/dev/null 2>&1; then deactivate; fi
  if type conda >/dev/null 2>&1; then
    while [ "${CONDA_SHLVL:-0}" -gt 0 ]; do conda deactivate; done
  fi
  case $target in
    venv:*) . "${target#venv:}/bin/activate" ;;
    conda:*) conda activate "${target#conda:}" ;;
  esac
  _PROJECT_ENV=$target
  return $rc
}

if [ -n "${ZSH_VERSION-}" ]; then
  precmd_functions+=(_project_env_switch)
else
  case ";${PROMPT_COMMAND-};" in
    *";_project_env_switch;"*) ;;
    *) PROMPT_COMMAND="_project_env_switch${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
  esac
fi

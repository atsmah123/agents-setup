# SETUP -- where this project runs, settled once per machine

Written by the FIRST supervisor session in this directory on each machine, together with the user, and read by every
later supervisor session before its first answer (`CLAUDE.md` -> Start of session). Later sessions ask only about what
is missing here or has changed -- never the same setup question twice. One section per machine; the SessionStart hook
prints this file and the current host so a session can tell whether its machine has a section yet.

## Machine: [name] (hosts: [hostname pattern, e.g. `login*`, `gpu-node-0[1-4]`])

Settled [YYYY-MM-DD] with the user ([one-line quote of any decision that was a real choice]).

* **Paths:** project root [path]; data roots [paths]; scratch / outputs [paths]; anything that must NOT be used.
* **Environment:** [conda env / venv / container image + the wrapper that runs commands in it]; how to run tests.
* **Compute inventory:** [scheduler (Slurm / PBS / none), account, partitions -> GPU type x count per node, walltime
  limits, exclusive-process GPUs?]; login-node limits (what must not run there).
* **How to check what is free right now:** [e.g. `sinfo -p <part> -N -o "%N %G %t"`, `squeue -p <part>`,
  `nvidia-smi`]. A supervisor runs these BEFORE asking the user any compute question, and asks with what is free in hand.
* **Compute policy:** [no standing cap -- the user sets compute per handoff | a standing cap of ...].
* **Storage:** [quota / free space, and the rule for large temporary files (delete after use)].
* **Accounts / logins:** [experiment tracker entity + projects; git remote + `gh` login; data-portal logins still
  missing].
* **Notifications:** [channel; whether push works on this machine].
* **Workspace boundary:** everything stays inside the project directory; worktrees at `.worktrees/<run>` (gitignored).
* **Open setup questions:** [anything not settled yet, with the current lean].

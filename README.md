# agents-setup

A ready-made setup for [Claude Code](https://claude.com/claude-code) that you install once per machine. Afterwards
every Claude Code session, in every project, works the same way:

- **Shared guidelines** for how Claude should work (think before coding, keep changes small, explain plainly), and
  skills such as `handoff2auto` for handing long-running work to a background session.
- **A project template** that gives each project a `.claude/` folder: settings, a startup script that shows Claude
  the project's open work at the start of each session, and folders for notes, research and task history.
- **One question per machine, asked once.** The first Claude session in a project on a new machine asks you about
  paths, environment and compute, and writes the answers down so later sessions don't ask again.
- **The right Python environment** switched on automatically as you `cd` into a project (optional).

## Quick start

You need Claude Code, `git`, `bash` and `rsync`.

1. **Put your projects in one folder,** e.g. `~/projects/`.
2. **Clone this repo and run setup:**
   ```bash
   git clone https://github.com/atsmah123/agents-setup.git ~/agents-setup
   ~/agents-setup/setup.sh
   ```
   It asks two questions:
   - **Where do your projects live?** Press Enter for `~/projects`.
   - **Set them all up?** It lists the projects it found: each folder, plus the repos inside a folder that isn't a
     repo itself (e.g. `my-workspace/website`). Press Enter for all of them, or `n` to pick.
3. **Open a new terminal and start Claude Code in one of your projects.** The first session will introduce itself
   as the first one on this machine and ask its setup questions.

Setup never overwrites a file you already have, so it is safe to run again at any time.

## Everyday use

Run these from the `agents-setup` folder.

| To | Do |
|---|---|
| Add a project | put it in your projects folder and run `./setup.sh`; it offers the new one |
| Add a project kept somewhere else | `./setup.sh --project <dir>` |
| Get the latest version | `git pull && ./setup.sh` |
| Change the shared guidelines or a skill | edit the files in `global/`; they take effect at once |
| Add a skill | create `global/skills/<group>/<name>/SKILL.md` (its `name` field = the folder name), run `./setup.sh` |
| Move your projects folder | `./setup.sh --projects-dir <dir>` |

Edit the shared files here, in `global/`, not in `~/.claude`: the files there are links to this folder.

## Optional: private project files

Some project files can't go in the project's own repo: the repo is public or belongs to a team, or the folder isn't
a repo at all. You can keep those files in a private git repo of your own, and setup will put them back on every
machine.

1. Create a private repo that mirrors your projects folder (`<repo>/my-site/CLAUDE.md` is
   `<projects folder>/my-site/CLAUDE.md`), with a `paths` file listing what to keep:
   ```
   my-site/CLAUDE.md
   my-workspace/.claude/        # a trailing / keeps a whole folder
   !.claude/skills/             # a line starting with ! is left out
   ```
2. On each machine, once: `./setup.sh --private <your repo's git URL>`. Later runs of `./setup.sh` restore the files
   without asking, and never overwrite a file you already have.
3. After editing any of those files: `./private.sh save` copies them into the private repo, commits and pushes.

## What's in here

```
setup.sh                      installs everything; safe to re-run
private.sh                    the optional private project files (save / restore)
init-project.sh <dir>         adds the project template to one folder (setup.sh runs it for you)
global/                       linked into ~/.claude
├── CLAUDE.md                 guidelines for every session
└── skills/<group>/<skill>/   skills, grouped by what they do
templates/project/            what each project's .claude/ folder starts from (copied, then yours to fill in)
├── CLAUDE.md                 project header to fill in; how sessions split work (below)
├── SETUP.md                  this machine's paths, environment and compute; one section per machine
├── settings.json             permissions (no edits to secrets, ask before commit/push) and the startup hook
├── scripts/session_start.sh  shows the session SETUP.md, the task board, TODO and recent CHANGELOG entries
├── context/ research/ docs/  notes about the project, its research, and finished reports
└── tasks/                    working history by phase, with templates for steps, handoffs and post-mortems
envs/projects.yml             an optional shared Python env for projects without their own
shell/project-env.sh          switches Python env as you cd (installed into your shell by setup.sh)
```

## How it works

### How sessions work in each project

- **Supervisor and workers.** The session you talk to plans and keeps the records. Long work goes to a separate
  worker session through a `handoff2auto` task doc and a row on `.claude/tasks/BOARD.md`. A running worker is steered
  only through its task doc.
- **The first session on a machine settles the setup.** The startup script looks in `.claude/SETUP.md` for a heading
  like `` ## Machine: laptop (hosts: `my-laptop`) `` whose patterns (shell globs, e.g. `login*`) match this
  machine's hostname. If none matches, the session asks you about paths, environment, compute and storage, and
  writes that section before doing any project work.
- **Compute is checked before you are asked about it** (`SETUP.md`, then `sinfo` / `squeue` / `nvidia-smi`).
- **Everything stays inside the project folder;** worktrees go in `<project>/.worktrees/<run>`.
- **Measured results** state in advance how they will be read, with checks against fooling yourself (see the
  training-handoff template).

### What setup.sh changes on your machine

- **Links** `global/CLAUDE.md` and each skill into `~/.claude`. If you already have your own file there, it is left
  alone and setup prints a `diff` command so you can merge by hand; `--replace` moves yours aside to
  `<name>.bak.<timestamp>` instead.
- **Copies** the project template into each project's `.claude/`, adding only missing files. A project that keeps its
  CLAUDE.md at the root gets no second one in `.claude/`, since Claude Code would load both. A project that already
  has its own `.claude/settings.json` keeps it, with only the startup hook added (needs `python3`).
- **Remembers your answers** in `~/.config/agents-setup/`: `projects-dir` (the projects folder), `projects` (one
  project per line) and `private-repo`. Nothing about your machine goes into this repo.
- **Adds a short marked block** at the top of `~/.bashrc` / `~/.zshrc` that sets `AGENTS_SETUP` and turns on the
  env switching.

Projects keep their own copies of the template, so later template changes don't reach existing projects on their own.
Copy an updated file over by hand (e.g. `templates/project/scripts/session_start.sh`), or merge it if you've changed
yours. Very old versions of this repo linked files from a `workspaces/` folder; setup removes any such link left
behind, and your private repo (if you use one) puts the file back.

### Where Claude Code looks for these files

- **CLAUDE.md** is read from the folder a session starts in *and every folder above it*, so a CLAUDE.md in a
  workspace folder reaches every repo inside it.
- **Skills and `settings.json`** are read only from the folder a session starts in, so each repo needs its own
  `.claude/settings.json`. Skills meant for every project go in `global/skills/`. Claude Code finds skills only one
  level deep in `~/.claude/skills/`, so the groups exist only in this repo and skill names must be unique.

### Python environments (optional)

To use the shared env, install conda (e.g. Miniforge) and run `conda env create -f envs/projects.yml` once. It has
Python 3.12, pytest, ruff, ipython and jq.

As you `cd` inside a project, the first match walking up to the project's root wins:

| Found | Activates |
|---|---|
| `.conda-env` (one line: an env name) | that conda env |
| `.venv/` | that virtualenv |
| nothing | the shared `projects` env |
| outside every project | nothing (conda's auto-activated base is turned off) |

To give a project its own conda env: `conda create -n <name> ...`, then `echo <name> > <project>/.conda-env`. Claude's
own tool shells don't switch environments, so the guidelines tell it to call Python by absolute path.

### Planned: routes

Each skill group will get its own `SKILL.md` that, given a task, names the skill in the group to use. `setup.sh`
already links any folder holding a `SKILL.md`, so this needs no script change. Not built yet.

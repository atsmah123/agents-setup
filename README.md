# agents-setup

Portable Claude Code configuration: one global layer for every machine (guidelines and skills), one template for
every project. Clone it, run `setup.sh`, and every Claude Code session on that machine works the same way.

This repo holds nothing about any particular machine. Machine-specific facts live on the machine, and project files
that can't go in their own repo live on the private `project-files` branch.

## Set up a new machine

Needs `git`, `bash` and `rsync`; conda (e.g. Miniforge) is optional, for the shared Python env.

1. **Clone your project repos into one folder,** e.g. `~/projects/`.
2. **Clone this repo and run setup.**
   ```bash
   git clone <this repo's URL> ~/agents-setup
   ~/agents-setup/setup.sh
   ```
   It asks two things:
   - **Where do your projects live?** Press Enter for `~/projects`. Asked once; the answer is remembered.
   - **Set them all up?** It lists what it found there: each folder, plus the repos inside a folder that isn't a repo
     itself (e.g. `my-workspace/website`). Enter sets them all up; `n` lets you name the ones you want.

   It also puts back your private project files (see below) before adding any template files, so your real files
   always win. Nothing that already exists is overwritten, and re-running is safe.
3. **Optional, the shared Python env:** `conda env create -f ~/agents-setup/envs/projects.yml`
4. **Open a new shell, then start Claude Code in a project.** The first session on each machine says so at the top
   and asks you about paths, environment and compute, then writes that machine's section into the project's
   `.claude/SETUP.md`. Later sessions read it and don't ask again.

## Everyday use

| To | Do |
|---|---|
| Add a project | put it in your projects folder and run `./setup.sh` (it offers new ones); anywhere else: `./setup.sh --project <dir>` |
| Bring a machine up to date | `git pull && ./setup.sh` |
| Change the global guidelines or a skill | edit `global/` here (it is linked, so it applies at once), then commit and push |
| Save edits to private project files | `.worktrees/project-files/sync.sh save && git -C .worktrees/project-files push` |
| Add a skill | create `global/skills/<group>/<name>/SKILL.md` (frontmatter `name` = folder name), run `./setup.sh` |
| Move the projects folder | `./setup.sh --projects-dir <dir>` |

Claude can't edit through a symlink, so change global files here, in this repo, not in `~/.claude`.

**Private project files** are the ones no project repo can hold, because the repo is public or a team's, or the
folder isn't a repo (e.g. a workspace folder's CLAUDE.md and `.claude/`). They live on this repo's private
`project-files` branch, which `setup.sh` checks out at `.worktrees/project-files/` and restores from. Restoring
never overwrites, so to take a newer version of a file this machine already has, delete the local copy and re-run
`./setup.sh`. The list of files kept is at the top of `.worktrees/project-files/sync.sh`.

## What's in here

```
global/                       linked into ~/.claude by setup.sh
├── CLAUDE.md                 behavioural guidelines for every project
└── skills/<group>/<skill>/   skills, grouped by what they do
    └── delegation/handoff2auto/   hand long-running work to a detached agent
envs/projects.yml             the shared `projects` conda env
shell/project-env.sh          switches env automatically on cd into a registered project
templates/project/            a project's .claude/ skeleton (copied, not linked)
├── CLAUDE.md                 project header to fill in; supervisor/worker roles and session start
├── SETUP.md                  per-machine setup (paths, env, compute + how to check it), one section per machine
├── settings.json             auto mode by default; no edits to secrets; ask before commit/push;
│                             SessionStart hook running scripts/session_start.sh
├── scripts/session_start.sh  prints this machine's SETUP.md section (or flags a first session), BOARD, TODO
│                             and recent CHANGELOG headings into each session
├── context/                  facts about the project (repo map, dependencies, docs guide)
├── research/                 objectives, methodology, theory, early discussions
├── docs/                     polished reports (see context/docs-writing-guide.md)
└── tasks/                    working history by phase; _template/ holds step, handoff,
                              training-handoff and post-mortem templates; BOARD.md tracks
                              work handed to worker sessions
```

## Reference

### Working conventions (every project)

- **Supervisor and workers.** The interactive session plans and keeps the records; long work goes to worker
  sessions through `handoff2auto` task docs + `tasks/BOARD.md`; a running worker is steered only through its doc's
  `Supervisor instructions`.
- **First session on a machine settles the setup.** The startup script looks in `.claude/SETUP.md` for a
  `` ## Machine: <name> (hosts: `<pattern>`) `` heading whose patterns (shell globs, e.g. `login*`) match this
  machine's hostname. With none, the session settles paths, environment, compute, storage, accounts and
  notifications with the user and writes that section before project work.
- **Check compute before asking about it** (`SETUP.md`, then `sinfo` / `squeue` / `nvidia-smi`); compute is set per
  handoff from what is actually free.
- **Everything stays inside the project directory;** worktrees at `<project>/.worktrees/<run>` (gitignored).
- **Measured results** carry a reading fixed before the first number, plus premise / reproduction / null-control
  gates where they apply (training-handoff template).

### What setup.sh touches

- **Global files are linked**, so editing them here changes every session on this machine; commit and push to carry
  the change to other machines. **Project files are copied**, because each project fills them in.
- **Your answers stay on this machine,** in `~/.config/agents-setup/`: `projects-dir` (the projects folder) and
  `projects` (the projects set up, one path per line, which the env switching reads). Edit them freely.
  A project that keeps its CLAUDE.md at the root gets no `.claude/CLAUDE.md`, since Claude Code would load both.
- **Existing files are never displaced.** If `~/.claude/CLAUDE.md` or a skill folder already exists and is not a link
  into this repo, `setup.sh` leaves it alone and prints a `diff` command so you can merge by hand; `--replace` moves
  it aside to `<name>.bak.<timestamp>` instead.
- **Existing projects don't pick up template changes,** because nothing is overwritten. A project that already had
  `.claude/settings.json` or `.claude/CLAUDE.md` needs the `hooks` block and the CLAUDE.md session sections merged in
  by hand; an updated `scripts/session_start.sh` is copied over by hand.
- **Older versions** linked per-directory files from a `workspaces/` folder into project directories. `setup.sh`
  turns any such link it finds (in the projects folder or any project) into a real copy of
  its content, taken from this repo's git history if the file is gone.

How Claude Code picks up these files, which decides what goes where:

- **CLAUDE.md** loads from the working directory *and every parent*, so a CLAUDE.md in a parent directory reaches
  every repo below it. Put principles shared by several repos there.
- **Skills and `settings.json`** load only for the directory a session starts in, not from parents, so each repo
  needs its own `.claude/settings.json`. Skills meant for every project belong in `global/skills/`. Claude Code only
  finds skills one level deep in `~/.claude/skills/`, so groups exist only in this repo and skill names must be
  unique across groups.

### Python environments

`shell/project-env.sh` (sourced from your shell rc by `setup.sh`, interactive shells only) switches environment as
you `cd`. Inside a registered project, walking up from the current directory to the project's root, the first match
wins:

| Found | Activates |
|---|---|
| `.conda-env` (one line: an env name) | that conda env |
| `.venv/` | that virtualenv |
| nothing, but inside a registered project | `projects` (Python 3.12, pytest, ruff, ipython, jq) |
| outside every registered project | nothing (conda's auto-activated base is turned off) |

To give a repo its own conda env: `conda create -n <name> ...`, then `echo <name> > <repo>/.conda-env` (add it to
that repo's `.git/info/exclude` if it shouldn't be committed). Agents' tool shells are non-interactive and don't
switch; skills and CLAUDE.md files name interpreters by absolute path instead.

Skills read the templates through `$AGENTS_SETUP` (e.g. handoff2auto reads
`$AGENTS_SETUP/templates/project/tasks/_template/00-step-handoff.md`), so the clone can live anywhere.

### Planned: routes

Each group will get its own `SKILL.md` (e.g. `global/skills/delegation/SKILL.md`). It acts as a router: given a
task, it names the skill inside the group to use. `setup.sh` already links any folder that holds a `SKILL.md`, so
adding a router needs no script change. Not built yet.

# agents-setup

Portable Claude Code configuration: one global layer for every machine, one project template for
every repo. Clone it anywhere and run the setup script.

```bash
git clone <this repo's URL> ~/agents-setup
~/agents-setup/setup.sh                  # global layer into ~/.claude; asks which directories are projects
~/agents-setup/init-project.sh <repo>    # scaffold <repo>/.claude/ (adds missing files only)
```

## Layout

```
global/                       linked into ~/.claude by setup.sh
├── CLAUDE.md                 behavioural guidelines for every project
└── skills/<group>/<skill>/   skills, grouped by what they do
    └── delegation/handoff2auto/   hand long-running work to a detached agent
envs/projects.yml             the shared `projects` conda env
shell/project-env.sh          switches env automatically on cd into a registered project
templates/project/            a project's .claude/ skeleton (copied, not linked)
├── CLAUDE.md                 project header to fill in; supervisor/worker roles and session start
├── SETUP.md                  per-machine setup (paths, env, compute + how to check it), written by the
│                             first supervisor session on each machine, read by every later one
├── settings.json             auto mode by default; no edits to secrets; ask before commit/push;
│                             SessionStart hook running scripts/session_start.sh
├── scripts/session_start.sh  prints BOARD, TODO and recent CHANGELOG headings into each session
├── context/                  facts about the project (repo map, dependencies, docs guide)
├── research/                 objectives, methodology, theory, early discussions
├── docs/                     polished reports (see context/docs-writing-guide.md)
└── tasks/                    working history by phase; _template/ holds step, handoff,
                              training-handoff and post-mortem templates; BOARD.md tracks
                              work handed to worker sessions
```

## Working conventions (every project)

- **Supervisor and workers.** The interactive session plans and keeps the records; long work goes to worker
  sessions through `handoff2auto` task docs + `tasks/BOARD.md`; a running worker is steered only through its doc's
  `Supervisor instructions`.
- **First session on a machine settles the setup.** No `.claude/SETUP.md`, or no section for this machine: the
  supervisor settles paths, environment, compute, storage, accounts and notifications with the user and writes them
  down before project work. Later sessions read it and ask only about what is missing or changed.
- **Check compute before asking about it** (`SETUP.md`, then `sinfo` / `squeue` / `nvidia-smi`); compute is set per
  handoff from what is actually free.
- **Everything stays inside the project directory;** worktrees at `<project>/.worktrees/<run>` (gitignored).
- **Measured results** carry a reading fixed before the first number, plus premise / reproduction / null-control
  gates where they apply (training-handoff template).

`init-project.sh` only adds missing files, so a project that already has `.claude/settings.json`
or `.claude/CLAUDE.md` won't pick up the SessionStart hook or the supervisor rules: merge the
`hooks` block and the two CLAUDE.md sections in by hand.

Global files are **symlinked**, so editing them here changes every session on this machine; commit
and push to carry the change to other machines. Project files are **copied**, because each project
fills them in.

## Projects and what setup.sh touches

This repo holds nothing about any particular machine or directory, so it can be shared as is. What is specific to a
machine stays on that machine:

- **Projects** are the directories you name when `setup.sh` asks (or pass with `--project DIR`). Each gets a
  `.claude/` skeleton from `templates/project/` -- missing files only, never an overwrite, and no `.claude/CLAUDE.md` if the project keeps one at its root -- and is recorded in
  `~/.config/agents-setup/projects`, a machine-local list the env switching reads. A project's machine-specific
  facts (paths, compute, environment) go in its own `.claude/SETUP.md`, written by its first supervisor session.
- **Existing files are never displaced.** If `~/.claude/CLAUDE.md` or a skill folder already exists and is not a link
  into this repo, `setup.sh` leaves it alone and prints a `diff` command so you can merge by hand; `--replace` moves
  it aside to `<name>.bak.<timestamp>` instead.
- **Older versions** linked per-directory files from a `workspaces/` folder into project directories. `setup.sh`
  turns any such link it finds (in registered projects, or in `$PROJECTS_DIR` / `~/projects` if that exists) into a
  real copy of its content, taken from this repo's git history if the file is gone.

- **Files no project repo can hold** (the repo is public or a team's, or the directory isn't a repo) are kept on the
  private `project-files` branch, never on main. Its `sync.sh` saves them from the projects and restores them on a new
  machine without overwriting anything; the header says how to check it out.

How Claude Code picks up these files, which decides what goes where:

- **CLAUDE.md** loads from the working directory *and every parent*, so a CLAUDE.md in a parent directory reaches
  every repo below it. Put principles shared by several repos there.
- **Skills and `settings.json`** load only for the directory a session starts in, not from parents, so each repo
  needs its own `.claude/settings.json`. Skills meant for every project belong in `global/skills/`.

## Project environments

Conda provides one shared env, `projects`, defined in
[`envs/projects.yml`](envs/projects.yml): Python 3.12, pytest, ruff, ipython, jq. It's for
quick fixes in any repo that has no environment of its own.

```bash
conda env create -f envs/projects.yml   # once per machine, after installing conda (e.g. Miniforge)
```

`shell/project-env.sh` (sourced by the `setup.sh` block, interactive shells only) switches
environment as you `cd`. Inside a registered project, walking up from the current directory to the
project's root, the first match wins:

| Found | Activates |
|---|---|
| `.conda-env` (one line: an env name) | that conda env |
| `.venv/` | that virtualenv |
| nothing, but inside a registered project | `projects` |
| outside every registered project | nothing (conda's auto-activated base is turned off) |

To give a repo its own conda env: `conda create -n <name> ...`, then
`echo <name> > <repo>/.conda-env` (add it to that repo's `.git/info/exclude` if it shouldn't be
committed). Agents' tool shells are non-interactive and don't switch; skills and CLAUDE.md
files name interpreters by absolute path instead.

Skills read the templates through `$AGENTS_SETUP` (e.g. handoff2auto reads
`$AGENTS_SETUP/templates/project/tasks/_template/00-step-handoff.md`), so the clone can live
anywhere.

## Adding a skill

1. Create `global/skills/<group>/<skill-name>/SKILL.md` (frontmatter `name` = folder name).
2. Run `./setup.sh` again.

Claude Code only finds skills one level deep in `~/.claude/skills/`, so groups exist only in this
repo. Skill names must be unique across all groups.

## Planned: routes

Each group will get its own `SKILL.md` (e.g. `global/skills/delegation/SKILL.md`). It acts as a
router: given a task, it names the skill inside the group to use. `setup.sh` already links any
folder that holds a `SKILL.md`, so adding a router needs no script change. Not built yet.

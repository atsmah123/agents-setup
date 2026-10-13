# agents-setup

Portable Claude Code configuration: one global layer for every machine, one project template for
every repo. Clone it anywhere and run the setup script.

```bash
git clone https://github.com/atsmah123/agents-setup.git ~/agents-setup
~/agents-setup/setup.sh                  # global layer into ~/.claude, AGENTS_SETUP in your shell rc
~/agents-setup/init-project.sh <repo>    # scaffold <repo>/.claude/ (adds missing files only)
```

## Layout

```
global/                       linked into ~/.claude by setup.sh
├── CLAUDE.md                 behavioural guidelines for every project
└── skills/<group>/<skill>/   skills, grouped by what they do
    └── delegation/handoff2auto/   hand long-running work to a detached agent
workspaces/<dir>/             linked into ~/projects/<dir>/ by setup.sh, file by file
├── my-workspace/                  supervisor CLAUDE.md + platform principles for every repo under it
│   └── website/              CLAUDE.md pointing at the site's README house rules
└── my-site/                CLAUDE.md for the personal site
envs/projects.yml             the shared `projects` conda env
shell/project-env.sh          switches env automatically on cd under ~/projects
templates/project/            a project's .claude/ skeleton (copied, not linked)
├── CLAUDE.md                 project header to fill in; supervisor/worker roles and session start
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

`init-project.sh` only adds missing files, so a project that already has `.claude/settings.json`
or `.claude/CLAUDE.md` won't pick up the SessionStart hook or the supervisor rules: merge the
`hooks` block and the two CLAUDE.md sections in by hand.

Global files are **symlinked**, so editing them here changes every session on this machine; commit
and push to carry the change to other machines. Project files are **copied**, because each project
fills them in.

## Workspaces

`workspaces/<dir>/` mirrors `~/projects/<dir>/` (override with `PROJECTS_DIR`). `setup.sh` links
each file to the same path there, skipping any workspace whose directory doesn't exist yet and
any destination that already holds a real file. Links that land inside a git repo are added to
that repo's `.git/info/exclude`, so they never show up as untracked.

How Claude Code picks these up, which decides what goes where:

- **CLAUDE.md** loads from the working directory *and every parent*, so `my-workspace/CLAUDE.md`
  reaches sessions started in `my-workspace/my-repo/` or `my-workspace/website/`. Put shared
  principles here.
- **Skills and `settings.json`** load only for the directory a session starts in, not from
  parents. A workspace's `.claude/settings.json` governs sessions started at that level only,
  so each repo needs its own. Skills meant for every project belong in `global/skills/`.
- Claude can't edit through a symlink: change these files here, in `agents-setup`.

Repos that already commit their own `CLAUDE.md`/`.claude/` (e.g. `my-workspace/my-repo`) get
nothing from here beyond the parent `my-workspace/CLAUDE.md`.

## Project environments

Conda (Miniforge, `~/miniforge3`) provides one shared env, `projects`, defined in
[`envs/projects.yml`](envs/projects.yml): Python 3.12, pytest, ruff, ipython, jq. It's for
quick fixes in any repo that has no environment of its own.

```bash
conda env create -f envs/projects.yml   # once per machine, after installing Miniforge
```

`shell/project-env.sh` (sourced by the `setup.sh` block, interactive shells only) switches
environment as you `cd`. Walking up from the current directory to `~/projects`, the first match
wins:

| Found | Activates |
|---|---|
| `.conda-env` (one line: an env name) | that conda env |
| `.venv/` | that virtualenv (e.g. `my-workspace/my-repo`) |
| nothing, but inside `~/projects` | `projects` |
| outside `~/projects` | nothing (conda's auto-activated base is turned off) |

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

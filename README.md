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
templates/project/            a project's .claude/ skeleton (copied, not linked)
├── CLAUDE.md                 project header to fill in
├── settings.json             plan mode by default; no edits to secrets; ask before commit/push
├── context/                  facts about the project (repo map, dependencies, docs guide)
├── research/                 objectives, methodology, theory, early discussions
├── docs/                     polished reports (see context/docs-writing-guide.md)
└── tasks/                    working history by phase; _template/ holds step, handoff,
                              training-handoff and post-mortem templates
```

Global files are **symlinked**, so editing them here changes every session on this machine; commit
and push to carry the change to other machines. Project files are **copied**, because each project
fills them in.

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

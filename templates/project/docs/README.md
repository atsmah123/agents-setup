# docs/

Polished, standalone reports meant to be shared with collaborators.
See [`.claude/context/docs-writing-guide.md`](../.claude/context/docs-writing-guide.md)
for conventions and process before writing anything here.

**Layout:** one directory per topic —

```
docs/<topic>/
├── <topic>-report.md
├── figures/
└── literature/          # per-paper summaries via the paper-summary skill
```

Create a new `docs/<topic>/` directory once a topic's working discussion in
`.claude/tasks/` has produced enough resolved decisions to be worth a
standalone writeup — don't create the directory speculatively ahead of that.

# Writing Reports in `docs/`

`docs/` holds **polished, standalone reports** — one topic directory per
major area (e.g. preprocessing, tokenization, model design, ...) — meant to
be shared with collaborators without access to this repo's internal working
notes. Think of each report as a pre-manuscript methods section: what was
done, why, and what the evidence shows. **This guide stays in `.claude/`**
— never copy it into `docs/`.

**`docs/` is a different thing from `.claude/tasks/`.** `tasks/` is the
working history — implementation status, file/config references, decisions
in progress, open engineering questions. `docs/` reports are *derived from*
that material, not a copy of it — synthesized, stripped of implementation
detail, organized around the science rather than the chronology of how it
was built.

---

## Topic directory layout

```
docs/<topic>/
├── <topic>-report.md      # the polished writeup
├── figures/                # real generated figures, referenced by the report
└── literature/              # per-paper summaries, one .md per paper
```

**`literature/`** — one markdown file per paper (`<bibkey>.md`), produced
with the `paper-summary` skill. Don't dump raw PDFs here uncatalogued; each
paper gets a summary file pairing it with a verified BibTeX entry. If a
report cites a paper, the citation should trace to a `literature/<bibkey>.md`
file, not to memory.

---

## Writing a new report — conventions

**1. No implementation details.** No file paths, function/class names,
config file names, or engineering-status phrasing ("not yet wired in",
"TODO", "resolved on <date>"). Describe design choices in terms of what
they do and why, not how they're coded. A reader without codebase access
should be able to follow the entire report.

**2. Fully standalone.** No links or references into `.claude/`. If a
detail from a task doc is worth keeping, restate it in report prose.
External literature (papers, other repos) can be cited normally.

**3. Structure: overview → methodology/reasoning → results/verification →
open questions.**
- State *why* a design choice was made, with the underlying reasoning, not
  just the final value.
- Back claims with actual numbers from real runs, not descriptions of what
  should happen in principle.
- End with an honest "open questions" section, phrased as scientific
  questions, not engineering TODOs.

**4. Use real visualizations, with real captions.** Each figure needs a
caption explaining what it shows and why it's evidence for the claim being
made. **Before citing a number printed on a figure, check it against the
verified value in your source material** — figures can predate the final
configuration; flag any mismatch explicitly rather than trusting whichever
number is more convenient.

**5. Concise but detailed — not exhaustive.** A source task doc might log
many sequential experiments; the report states the resolved conclusion with
enough evidence to be convincing, without replaying the full log.

---

## Producing a report: process

1. Read the relevant `.claude/tasks/*/` docs end to end — ground truth for
   what was actually decided and verified, not just chat history.
2. Check for existing visualizations and real numbers (outputs, caches) —
   prefer verified, already-computed results over re-deriving from memory.
3. Where a claim needs a number and none is readily available, compute it
   directly rather than estimating by hand — cross-check against any
   related figure/number already in the source material.
4. Write the report following the conventions above. If something is
   genuinely unresolved, say so plainly in "open questions."
5. Cross-check every number and figure caption against source material one
   more time before finishing — a report shared with collaborators is read
   as authoritative.

---

## Current contents of `docs/`

| Directory | Report | Status |
|---|---|---|
| [Add a row per topic directory as reports are written] | | |

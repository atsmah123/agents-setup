# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

## 5. Explaining Your Work

**Explain the problem, not the code. Plain language over jargon.**

When reporting findings, analysis, or what you changed:
- Lead with what actually goes wrong and what it costs. A reader should
  understand the problem before seeing a single file path or symbol name.
- Say it in ordinary words. "The file gets thrown away" beats "the write path
  silently truncates on collision."
- Cite code as evidence *after* the point is made, not as the point itself.
  One reference is usually enough; don't narrate every line you read.
- Cut tables, matrices and severity ratings unless they're genuinely clearer
  than a sentence. Usually they aren't.
- Skip the tour of your process. What you found matters; which greps got you
  there does not.

The test: could a colleague who hasn't read this code follow the explanation?
If it only parses for someone with the file already open, rewrite it.

---

## 6. Python environments

Your shell does not switch environments for you (the `cd` hook only runs in interactive
terminals). Under `~/projects`, pick the interpreter by absolute path: the repo's own
`.venv/bin/python3` if it has one, the env named in its `.conda-env` file if it has that, and
otherwise the shared `~/miniforge3/envs/projects/bin/python3`. Never `pip install` into the
shared env for one project's sake; that project needs its own environment.

---

## 7. Commits

**Never add Claude/AI attribution to commits.** Do not include a `Co-Authored-By: Claude ...` trailer or any "Generated with Claude Code" line in commit messages or PR bodies. Write the message as the author's own.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

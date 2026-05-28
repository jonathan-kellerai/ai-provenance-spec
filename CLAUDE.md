# CLAUDE.md — Claude Code instructions for ai-provenance-spec

@AGENTS.md

## Claude-specific notes

The import above loads [AGENTS.md](AGENTS.md), the agent entry point. Everything
below is specific to Claude Code.

- **This repo is docs-only.** Do not run `cargo`, `npm`, `python -m`, or any
  build or test command — there is no implementation here and nothing to
  execute.
- **No in-repo issue tracker.** There is no `bd` / `.beads/` tracker in this
  repository. Do not try to invoke `bd`. Issues are tracked on GitHub once the
  repo is published.
- **Prose edits**: use the `writing-clearly-and-concisely` skill for clarity
  passes and `human-writing` for tone passes when editing documentation.
- **Citations**: cite internal references as `path:line`; cite external or
  academic sources with a full bibliographic reference. See
  [`docs/agents/citation.md`](docs/agents/citation.md).
- **Constitution discipline**: [`docs/governance/constitution.md`](docs/governance/constitution.md)
  is binding. Do not change the meaning of an invariant in an ordinary edit —
  amendments follow the constitution's Amendment Rule (see [AGENTS.md](AGENTS.md)).

## Staging vs. publishable files

Some files in this working tree are **staging-only**: they are excluded by
`.gitignore` and must never be edited or cited as if they were publishable.
Notable staging artifacts under `.claude-tmp/`:

- `.claude-tmp/PUBLISH-MANIFEST-v2.md` — the pre-publication audit record.
- `.claude-tmp/CRITIQUE-pass*.md` — the five-pass adversarial critique trail.
- `.claude-tmp/whitepaper-ai-provenance-spec.{md,pdf}` — the companion whitepaper.

The `.gitignore` boundary is the source of truth: if a file is gitignored, it is
staging-only and does not ship; otherwise it is publishable. Everything under
`.claude/` and `.claude-tmp/` is staging.

## Publish gate

[`scripts/check-publish-gate.sh`](scripts/check-publish-gate.sh) gates
publication. It exits 0 only when the companion repository `grounded-rag-spec` is
live on GitHub. AI Provenance Spec must not be published before that gate clears.

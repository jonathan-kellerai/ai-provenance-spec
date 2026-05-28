# AGENTS.md

This repository is the **v1 specification** for **AI Provenance Spec**, a trusted release
and deployment substrate for portable cognition capsules. **Humans read
[README.md](README.md); agents start here.**

If you are an automated agent — Claude Code, Codex, or otherwise — reading or
editing this repo, this file is your entry point. It is Tier 1 of a three-tier
progressive-disclosure structure: read this first, then follow the Tier-2
pointers at the bottom only when a task needs that depth.

## What this repo is

- A **specification**, at v1, for the release, attestation, and admission of AI
  skill artifacts. The architecture is binding per
  [`docs/governance/constitution.md`](docs/governance/constitution.md).
- **Docs-only.** There is no implementation. No Rust, Python, Go, or build
  system ships here.
- Licensed **Apache-2.0** ([LICENSE](LICENSE), [NOTICE](NOTICE)). Copyright 2026 Jonathan A. Bowe.

## What this repo is NOT

- It is **not** a runtime. AI Provenance Spec targets one runtime compatibility class,
  `archangel.local.v1`, but ships no code that runs.
- Agents **must not** invent code paths, file trees, APIs, or claim AI Provenance Spec
  has an executable. If a task asks you to "run" or "build" AI Provenance Spec, it is
  mis-scoped — there is nothing to run.
- It is not a marketplace, not a packaging tool, not a multi-tenant platform.

## File layout and reading order

A new agent answering an architecture question should read, in this order:

1. [`docs/governance/constitution.md`](docs/governance/constitution.md) — the
   binding architecture: 15 invariants, 9 canonical objects. Authoritative when
   any other document disagrees.
2. [`docs/ADR.md`](docs/ADR.md) — append-only decision log; the *why* behind the
   constitution.
3. [`docs/project-context/v1-scope.md`](docs/project-context/v1-scope.md) — the
   narrowest falsifiable v1 cut: what is in, what is out, the exact first user.
4. [`docs/specs/hot-swap-v1.md`](docs/specs/hot-swap-v1.md) — the first concrete
   operational spec.

Supporting context:

- [`docs/project-context/proposal.md`](docs/project-context/proposal.md) — the
  self-contained proposal packet.
- [`docs/project-context/backstory.md`](docs/project-context/backstory.md) —
  origin, naming, and the relationship to the sister project, Matryoshka.
- [`docs/specs/spec-template.md`](docs/specs/spec-template.md) — the template
  for expressing a new spec.
- [`docs/governance/policies/`](docs/governance/policies/) — illustrative OPA
  policy that validates a spec against the constitution.
- [`docs/whitepaper-ai-provenance-spec.md`](docs/whitepaper-ai-provenance-spec.md) — the
  companion whitepaper: the formal models behind the constitution.

## Load-bearing concepts agents must respect

- **Invariant 11 is non-negotiable:** "No trust decision may depend on mutable
  ambient state that is not recorded in the deployment record." Every
  architectural claim must be consistent with it.
- **The five kernel objects** are exactly `ReleaseEnvelope`, `PolicySnapshot`,
  `EnvironmentProfile`, `DeploymentRecord`, and `DeploymentLedger`. Do not invent
  additional kernel objects. The constitution's full canonical set is nine; see
  [`docs/agents/glossary.md`](docs/agents/glossary.md).
- **The five-stage hash chain** stage names are exact and ordered:
  `source_commit_hash` → `build_artifact_hash` → `policy_check_hash` →
  `canary_result_hash` → `promotion_timestamp_hash` → `ledger_hash`.
- **Constitution amendments** require an explicit architecture decision with
  recorded approval from the Policy Authority, Release Authority, and
  Environment Owner. Never silently rewrite an invariant.

## Conventions agents must follow

- The default branch is **`main`**. Never create or target `master`.
- **Conventional Commits**: `<type>(<scope>): <subject>`, subject ≤50 chars,
  imperative mood. Types: `feat`, `fix`, `chore`, `docs`, `refactor`. Scope is
  optional.
- **Branch naming** — agent work uses `<agent>/<scope>` (e.g.
  `claude/fix-typo-adr-003`, `codex/clarify-invariant-15-canary-ceiling`);
  human work uses `feat/*`, `fix/*`, `docs/*`, `chore/*`.
- Edits to publishable docs (`docs/**`, `README.md`, `AGENTS.md`, `CLAUDE.md`)
  go through a **pull request**. Edits to gitignored staging files (anything
  under `.claude-tmp/**`, and the staging prompts) may be direct.
- **Never delete a file** without explicit permission from the repository owner.
- Cite internal references as `path:line`; cite external sources with a full
  bibliographic reference.

## Open architectural question

The hot-swap architecture has an unresolved empirical prerequisite — **Gate
Zero** in [`docs/specs/hot-swap-v1.md`](docs/specs/hot-swap-v1.md): when
`gateway_session_surface_apply` is called mid-session, does Claude Code re-issue
a `tools/list` request and see the updated tool set in the same conversation? If
Gate Zero fails, the tool-surface-discipline benefit does not exist and the
architecture requires fundamental redesign. Any agent discussing hot-swap
viability must surface this gate first.

## Tier-2 references

Read these only when a task needs the depth:

- [`docs/agents/conventions.md`](docs/agents/conventions.md) — Conventional
  Commits, branch naming, PR style, ADR supersession discipline, citation format.
- [`docs/agents/citation.md`](docs/agents/citation.md) — how to cite AI Provenance Spec
  v1, its Apache-2.0 license, and the BibTeX entry.
- [`docs/agents/glossary.md`](docs/agents/glossary.md) — the load-bearing
  vocabulary: kernel objects, the confidence model, the six roles, the negative
  states, the kill criteria.
- [`docs/agents/enforcement.md`](docs/agents/enforcement.md) — how these
  conventions are enforced going forward.

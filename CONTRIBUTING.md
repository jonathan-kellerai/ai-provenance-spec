# Contributing to AI Provenance Spec

AI Provenance Spec is a **specification-stage project**.
The architecture is binding per [`docs/governance/constitution.md`](docs/governance/constitution.md) — its 15 invariants are stable and not open to redefinition through pull request.

What that means for contributions:

## What we welcome

- **Issues** that surface ambiguity, contradiction, or under-specification in the constitution, proposal, or v1 scope.
- **Issues** that propose a new ADR for a decision the current ADR set does not cover.
- **Pull requests** that improve documentation language: clarity, typo fixes, grammar, structural editing of prose, fixing broken links.
- **Pull requests** that add worked examples or diagrams illustrating an existing invariant without altering its meaning.

## What we will not accept

- Pull requests that **change the meaning** of an existing invariant in `constitution.md`.
- Pull requests that **add or remove an invariant**.
- Pull requests that **redefine a canonical kernel object** (`ReleaseEnvelope`, `PolicySnapshot`, `EnvironmentProfile`, `DeploymentRecord`, `DeploymentLedger`, etc.) by renaming, restructuring, or relaxing its required fields.
- Pull requests that broaden the v1 scope in `docs/project-context/v1-scope.md`. The v1 cut is intentionally narrow; broadening happens via a new spec under `docs/specs/`, not by editing v1.
- Implementation code. This repo is the specification. Implementation lives elsewhere.

If a change to the binding architecture is genuinely needed, open an issue first and let it discuss before opening a PR. An ADR follow-up (under `docs/ADR.md`) will be the right vehicle, not a direct edit to the constitution.

## How to file an issue

- One concern per issue.
- Quote the section, file path, and line number you are responding to.
- If you are proposing language, propose the exact replacement text.

## How to file a pull request

- Keep the diff small. One logical change per PR.
- Update related docs in the same PR if your change requires cross-references to move.
- The PR description should name the file(s) being changed and the reason.

## Conventions

This repository follows one set of conventions for agents and humans alike:

- **[AGENTS.md](AGENTS.md)** — the entry point: what the repo is, its file
  layout, the load-bearing concepts, and the conventions in brief.
- **[docs/agents/conventions.md](docs/agents/conventions.md)** — the full
  detail: Conventional Commits, branch naming, PR style, ADR supersession.
- **[docs/agents/glossary.md](docs/agents/glossary.md)** — the load-bearing
  vocabulary, so an issue or PR uses the terms the specification defines.

In short: branch from `main` (`feat/*`, `fix/*`, `docs/*`, `chore/*` for human
contributors); write [Conventional Commits](https://www.conventionalcommits.org/)
with an imperative subject; keep each PR to one logical change.

## License

By contributing, you agree that your contribution is licensed under the
[Apache License 2.0](LICENSE) that covers the rest of the project.

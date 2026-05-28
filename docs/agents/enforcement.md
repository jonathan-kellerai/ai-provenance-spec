# Enforcement

Tier-2 reference. How the conventions in [AGENTS.md](../../AGENTS.md) and
[conventions.md](conventions.md) are kept true over time — not by goodwill, but
by automation and a small number of human gates.

## Continuous integration

`.github/workflows/ci.yml` runs on every push and pull request:

- **Governance policy** — `opa check` and `opa test` over
  `docs/governance/policies/`. The rego test suite is the canonical
  correctness gate for this repository.
- **Markdown lint** — `markdownlint-cli2` against `.markdownlint-cli2.yaml`.
- **JSON well-formedness** — every `*.json` file must parse.
- **Sanitization gate** — `scripts/check-sanitization.sh` (see below).
- **Link check** — `lychee` over every Markdown link.

`.github/workflows/commitlint.yml` rejects any pull-request commit whose
message is not a valid Conventional Commit. `.github/workflows/pages.yml`
publishes `docs/` to GitHub Pages on every push to `main`. A red check blocks
the merge.

## The sanitization gate

`scripts/check-sanitization.sh` fails the build if an internal term reaches a
tracked file. Its denylist is base64-encoded so the script does not itself
republish the strings it exists to keep out. The same script runs in CI and in
the local pre-commit hook — a leak cannot pass either gate.

## Local pre-commit hook

`lefthook.yml` runs the governance test and the sanitization gate before a
commit is created. Contributors enable it once with `lefthook install`. The
hook mirrors CI, so problems surface locally rather than in review.

## Human review gates

`.github/CODEOWNERS` requires the repository owner's review for any change to
`.github/`, `LICENSE`, `NOTICE`, `AGENTS.md`, `CLAUDE.md`, or
`docs/governance/`. Leaf documentation stays open to ordinary review.

The pull-request template makes every contributor state the artifacts touched,
the validation they ran, the semver impact, and whether they are an agent.

## The canonical-document rule

`AGENTS.md` is the canonical statement of the conventions. When a convention
changes, it changes in `AGENTS.md` first, then propagates outward to
`CONTRIBUTING.md`, `README.md`, and the rest of `docs/agents/`. Editing a
downstream copy and leaving `AGENTS.md` stale is a defect.

## Review cadence

- **Glossary** — every new ADR or spec that introduces a term must add or
  update the matching entry in [glossary.md](glossary.md) in the same PR.
- **Constitution** — an invariant changes only through the constitution's
  Amendment Rule: a named clause, a reason, migration / compatibility /
  security impact, a rollback plan, and recorded sign-off from the Policy
  Authority, Release Authority, and Environment Owner. No pull request may
  change an invariant's meaning on its own.
- **ADR log** — append-only. A superseded decision is marked, never deleted
  (see [conventions.md](conventions.md)).

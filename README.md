# AI Provenance Spec

> Trusted release and deployment substrate for portable cognition capsules.

## Status

Specification, v1. Implementation deferred.
Architecture is binding per [`docs/governance/constitution.md`](docs/governance/constitution.md).

## What this repository is

AI Provenance Spec answers the questions that ordinary plugin and packaging systems answer badly when the artifact being shipped is a reasoning artifact:

- What exact bytes are being shipped?
- What exact behavior is being declared?
- What exact inputs were validated?
- What exact trust chain applies?

The specification is built around five canonical kernel objects:

- `ReleaseEnvelope` — the immutable, signed unit of deployable cognition.
- `PolicySnapshot` — the exact policy bundle a release was evaluated against.
- `EnvironmentProfile` — the runtime trust anchors and environmental constraints of the target.
- `DeploymentRecord` — the per-deployment evidence object: which envelope, against which policy, into which environment, by whom, when.
- `DeploymentLedger` — the append-only chain of deployment records, tamper-evident by construction.

Every promotion of a `ReleaseEnvelope` into a live `EnvironmentProfile` is a single transaction, and that transaction is recorded as one `DeploymentRecord` appended to one `DeploymentLedger`.

## The 5-stage hash chain

Each `DeploymentRecord` carries a chain that binds the release to the conditions under which it was promoted. The chain composes, in order:

- `source_commit_hash`
- `→ build_artifact_hash`
- `→ policy_check_hash`
- `→ canary_result_hash`
- `→ promotion_timestamp_hash`
- `→ ledger_hash`

Each stage is the hash of the prior stage concatenated with the new evidence. The terminal `ledger_hash` is the only value a downstream verifier needs to admit, reject, or revoke a deployment — and to prove, after the fact, exactly which release ran, under which policy, against which environment, with which canary outcome, at which moment.

## The binding invariant

The chain exists to serve one rule. Constitution invariant 11:

> No trust decision may depend on mutable ambient state that is not recorded in the deployment record.

(See [`docs/governance/constitution.md`](docs/governance/constitution.md) for the full set of 15 invariants and all 9 canonical objects, of which the 5 above are the core deployable-unit primitives.)

## One deployable unit, one serious loop

The v1 shape is intentionally narrow:

- one deployable unit: `ReleaseEnvelope`
- one target family: `archangel.local.v1`
- one serious loop: package, validate, attest, deploy, verify admission, rollback, revoke

Everything in `docs/specs/` and `docs/governance/policies/` is in service of executing that loop end-to-end against one capsule class, against one runtime family, with full audit evidence at every stage.

## Audience

The specification is written to be useful to three reader roles:

- **Staff System Safety Engineer** — the person asked to defend the deployment posture in a safety case.
- **Director of Safety** — the person asked to sign off that the posture is defensible at the program level.
- **Mission Autonomy P&B Manager** — the person asked to put a real autonomous artifact into a real environment and explain afterward what happened.

The constitution, ADR log, and v1 scope are the artifacts those three readers should be able to walk top-to-bottom and form their own opinion from. The proposal exists to give them the context. The hot-swap spec exists to show how a concrete operational requirement — context-efficient skill loading — was scoped against the constitution’s invariants. Some invariants apply directly to v1; others (full ReleaseEnvelope packaging, attestation) are explicitly deferred to later specs.

## Document map

| File | What it is |
|---|---|
| [`docs/governance/constitution.md`](docs/governance/constitution.md) | The binding architecture. 15 invariants, 9 canonical objects. Treat as authoritative when any other document disagrees. |
| [`docs/project-context/proposal.md`](docs/project-context/proposal.md) | Self-contained proposal packet. Names the 5-stage hash chain, the ten commitments, and the `bd create --file`-compatible spec form. |
| [`docs/project-context/v1-scope.md`](docs/project-context/v1-scope.md) | The narrowest falsifiable v1 cut. What is in, what is explicitly out, what the exact first user looks like. |
| [`docs/project-context/backstory.md`](docs/project-context/backstory.md) | Origin and naming. Includes the relationship to the sister project, Matryoshka. |
| [`docs/ADR.md`](docs/ADR.md) | Append-only architecture decision log. Records context, decision, and trade-offs accepted; superseded decisions are marked, not deleted. |
| [`docs/specs/hot-swap-v1.md`](docs/specs/hot-swap-v1.md) | The first concrete operational spec: skill hot-swap v1 against an ArchangelMCP-style runtime. |
| [`docs/specs/spec-template.md`](docs/specs/spec-template.md) | The `bd create --file` template used to express new specs in this repo. |
| [`docs/governance/policies/spec_validation.rego`](docs/governance/policies/spec_validation.rego) (and [`_test.rego`](docs/governance/policies/spec_validation_test.rego)) | OPA policy that validates a spec satisfies the constitution. Illustrative; not a production policy bundle. |
| [`docs/whitepaper-ai-provenance-spec.md`](docs/whitepaper-ai-provenance-spec.md) | Companion whitepaper. A specification-first treatment of the release, attestation, and admission architecture, with the formal models behind the constitution. |

## Companion repository

AI Provenance Spec is the deployment half of a two-repo story. The cognition-capsule half is [`github.com/jonathan-kellerai/grounded-rag-spec`](https://github.com/jonathan-kellerai/grounded-rag-spec). The combined posture is intentional: trust the release (AI Provenance Spec) and trust the capsule (Grounded RAG). Each spec is self-contained, but they are written to compose.

---

### For agents

Agents reading this repo should start at [AGENTS.md](AGENTS.md), not this README.
Claude Code users: see [CLAUDE.md](CLAUDE.md), which imports `AGENTS.md`. The
agent files document the conventions, vocabulary, and contribution discipline
agents are expected to follow.

## License and contributing

This specification is published under the [Apache License 2.0](LICENSE). Copyright 2026 Jonathan A. Bowe; see [NOTICE](NOTICE).

AI Provenance Spec is a **specification-stage** project. The architecture is binding; the invariants are stable. Issues that surface ambiguity or under-specification are welcome. Pull requests should target documentation language, not the meaning of an invariant. See [CONTRIBUTING.md](CONTRIBUTING.md) for the full stance.

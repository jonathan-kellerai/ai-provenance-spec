# AI Provenance Spec Constitution

## Purpose

This document fixes the non-negotiable structural rules for AI Provenance Spec.

AI Provenance Spec exists to turn a portable cognition capsule from a local artifact
into a deployable, attestable, rollbackable, and revocable runtime object.

This document is binding for v1. It is written to stop architectural drift,
not to describe aspirations.

## Product Identity

### One-sentence identity

AI Provenance Spec is a trusted release and deployment substrate for portable cognition
capsules.

### Dominant identity

The dominant identity is `deployment substrate`.

AI Provenance Spec includes packaging, attestation, release governance, deployment, and
revocation because those functions are required to make a cognition capsule
deployable with trust.

### It is not

AI Provenance Spec is not, by default:

- a cognition engine
- a skill authoring framework
- a marketplace
- a general plugin manager
- a runtime orchestration fabric for arbitrary services
- a substitute for the runtime host that executes capsule logic

The runtime host remains a separate system. In v1, that host is an
Aegis-compatible Archangel deployment target.

## Objective Hierarchy

When goals conflict, this order is binding:

1. Security and artifact integrity
2. Policy compliance and least authority
3. Reproducibility
4. Rollbackability
5. Auditability
6. Operator usability
7. Deployment speed
8. Portability
9. Ecosystem flexibility

Higher-priority objectives always win over lower-priority objectives.

## Core Invariants

The following rules are mandatory:

1. No deployable artifact exists without a machine-readable manifest.
2. No deployable artifact exists without immutable artifact bytes and stable
   digests, a stable capsule identity binding, and a declared behavioral boundary.
3. No attestation is valid unless it binds to pinned inputs and exact artifact
   digests.
4. No release is deployable without successful attestation.
5. No deployment occurs without evaluation against a specific `PolicySnapshot`
   and a specific `EnvironmentProfile`.
6. No runtime admission may expose capability that is not declared in the
   release manifest.
7. No hidden dependency may bypass the release envelope.
8. No revoked artifact or revoked locked dependency may be newly deployed.
9. No rollback may target an artifact that was not previously admitted and
   recorded as valid for that environment.
10. No deployment record may omit the exact release id, policy snapshot id,
    environment profile id, actor, and time.
11. No trust decision may depend on mutable ambient state that is not recorded
    in the deployment record.
12. No failure of higher-order automation may cause fail-open deployment.
13. No admission may be granted against an attestation set that has passed its
    declared `TrustExpiry` without explicit re-verification against current trust
    anchors.
14. No capsule whose `CapsuleIdentityRecord` has been revoked may be packaged
    into a new release envelope.
15. No more than five concurrent canary experiments may be active across one
    target environment at any time. A sixth release must queue until one canary
    concludes with explicit promote or rollback.

## Deployable Unit

### Unit of deployment

The deployable unit is one `ReleaseEnvelope`.

A `ReleaseEnvelope` is an immutable, signed release object containing:

- one capsule payload
- one `ReleaseManifest`
- one dependency lock
- one compatibility class declaration
- one attestation set bound to the envelope digest

Deployment always operates on one exact `ReleaseEnvelope`.

### What a release envelope is not

A release envelope is not:

- a mutable logical skill name
- a directory on disk
- a policy bundle
- an environment-specific overlay
- a runtime session snapshot

## Capsule Identity

A capsule has a logical identity that persists across all its releases.

Capsule identity is separate from release identity:

- capsule identity is stable, human-assigned, and recorded in a
  `CapsuleIdentityRecord`
- release identity is derived deterministically from exact envelope bytes

The `CapsuleIdentityRecord` is the stable anchor for rollback genealogy,
revocation cascade reasoning, upgrade path tracking, and capsule-level
behavioral boundary declaration.

A capsule identity may be revoked independently of any specific release.
Revoking a capsule identity blocks all future releases for that identity.

## Unit of Trust

The trust decision in AI Provenance Spec is made over this exact tuple:

- `ReleaseEnvelope` digest
- embedded `ReleaseManifest`
- embedded dependency lock
- embedded attestation set
- selected `PolicySnapshot`
- selected `EnvironmentProfile`
- `TrustExpiry` declared in the attestation set

Everything else is untrusted input or auxiliary record.

In particular:

- deployment history is recorded, not trusted
- operator notes are recorded, not trusted
- runtime-reported metadata is trusted only if the environment profile marks it
  as attested input
- undeclared transitive dependencies are not trusted, even if present on disk

## Unit of Ownership

Decision rights are explicit:

- `Artifact Author`
  - defines payload contents, manifest fields, declared dependencies, and
    rollback compatibility statement
- `Policy Authority`
  - owns policy classes, policy snapshots, trust rules, and deny rules
- `Release Authority`
  - approves promotion of an attested envelope into a deployable release
- `Environment Owner`
  - owns the `EnvironmentProfile`, target trust zone, runtime constraints, and
    admission configuration
- `Incident Owner`
  - may trip circuit breakers and force rollback-only or degraded mode
- `Revocation Authority`
  - may revoke envelopes, signers, or locked dependencies

One human may hold multiple roles, but the rights themselves must remain
separate in the model and in the records.

## Public Contract

### To artifact authors

AI Provenance Spec guarantees:

- the package boundary is explicit
- the release id is stable for identical bytes
- deployability is decided from recorded validation and policy, not hidden host
  state
- refusal states are explicit and machine-readable

### To deploy operators

AI Provenance Spec guarantees:

- every admission decision names the exact envelope, policy snapshot, and
  environment profile involved
- rollback operates on a previously admitted release, not a reconstructed guess
- revocation blocks future admission deterministically
- degraded mode is conservative and predictable

### To runtime systems

AI Provenance Spec guarantees:

- runtime admission receives one exact release envelope reference
- the runtime surface must not exceed the manifest-declared surface
- the runtime may reject admission if compatibility checks fail locally

### To auditors

AI Provenance Spec guarantees:

- each deployment can be traced to exact artifact bytes, exact trust inputs, and
  exact policy snapshot
- each release decision is replayable from durable records
- each revocation and rollback has durable cause and scope records

### To incident responders

AI Provenance Spec guarantees:

- artifact-level and dependency-level revocation units are explicit
- circuit breakers are independently triggerable
- rollback-only mode can be entered without opening forward deployment

## Canonical Durable Objects

The minimal durable object set for v1 is:

- `ReleaseEnvelope`
- `PolicySnapshot`
- `EnvironmentProfile`
- `ReleaseRecord`
- `DeploymentRecord`
- `RevocationRecord`
- `DeploymentLedger`
- `ReleaseConfidenceVector`
- `BitemporalDeploymentRecord`

> **Reconciliation note:** `ReleaseAuditRecord` (required by `v1-scope.md`) is specified there as a 10th durable object pending incorporation into this list via amendment. `ConflictStatus` (appearing in `proposal.md`) is a component sub-structure of `ReleaseConfidenceVector`, not a standalone durable object.

No additional canonical object is required in v1.

### Object definitions

- `ReleaseEnvelope`
  - immutable release object with payload, manifest, dependency lock,
    compatibility class, and attestation set
- `PolicySnapshot`
  - versioned deployment policy evaluated for release and admission
- `EnvironmentProfile`
  - versioned declaration of one deployment target's trust zone, compatibility
    rules, runtime constraints, and local trust anchors
- `ReleaseRecord`
  - control-plane decision that a specific release envelope is packaged,
    validated, attested, and either promoted or refused for a class of targets
- `DeploymentRecord`
  - admission decision for one release into one environment, including whether
    the deployment was a forward deploy or rollback
- `RevocationRecord`
  - explicit durable record that blocks a release envelope digest, signer, or
    locked dependency digest
- `DeploymentLedger`
  - tamper-evident hash-linked chain sealing the five stages from source commit
    through build, policy check, canary result, and promotion timestamp; any
    modification to any stage invalidates the ledger hash and blocks the release
- `ReleaseConfidenceVector`
  - combined Dempster-Shafer belief-plausibility interval [Bel, Pl] produced by
    combining BPA vectors from all deployment gate checks; travels with the
    `ReleaseRecord` and is auditable at any future point
- `BitemporalDeploymentRecord`
  - extends `DeploymentRecord` with two independent time axes: valid-time
    (valid_from_deploy, valid_until_deploy) and transaction-time (tx_ingested,
    tx_retired); enables point-in-time deployment queries without reconstruction

## Hot Path and Control Plane

### Artifact creation

Artifact creation is control-plane only.

Allowed work:

- assemble payload
- generate release manifest
- compute dependency lock
- build release envelope

Forbidden on the deploy hot path:

- rebuilding payload
- discovering undeclared dependencies
- mutating the manifest

### Validation

Validation is control-plane only.

Allowed work:

- schema validation
- digest verification
- dependency lock completeness checks
- compatibility-class checks
- policy evaluation for releasability

### Signing and attestation

Signing and attestation are control-plane only.

Attestation must bind to exact envelope bytes and exact pinned inputs.

### Deployment

Deployment is a hot-path operation.

Allowed work:

- fetch release envelope by id
- verify signature and attestation locally or against cached trust roots
- verify policy snapshot and environment profile references
- evaluate deploy-time policy gates
- select highest-MDL-score release when multiple candidates are queued
- emit deployment record
- hand runtime admission the exact release reference

Forbidden on deploy hot path:

- artifact rebuilding
- manifest rewriting
- dependency solving
- policy synthesis
- trust-anchor mutation

### Runtime admission

Runtime admission is on the hot path but is narrower than deployment.

Allowed work:

- compatibility check against the environment profile
- manifest-surface enforcement
- lease issuance or admission token issuance

Runtime admission must not:

- expand the declared capability surface
- pull undeclared dependencies
- self-approve policy waivers

#### Source Tolerance Gate

New capsule registrations undergo a three-phase admission screen before they
may enter a production environment:

1. **Schema overlap** — the incoming capability surface is compared against
   existing admitted capsules; near-duplicates are flagged for review before
   admission proceeds
2. **Autoreactive check** — the capsule's policy surface is evaluated for
   collision with existing OPA rules; a collision rate greater than five percent
   triggers the `AUTOIMMUNE_FAILURE` circuit breaker for this capsule class
3. **Burn-in** — the first ten invocations of a newly admitted capsule are
   routed at seventy percent trust weight; full weight is granted after ten
   successful calls

Capsules that fail phase two do not merely fail admission; they trigger a
circuit breaker that prevents the entire capsule class from proceeding until
the policy conflict is resolved.

### Rollback

Rollback is a deployment action using a previous valid `ReleaseRecord`.

Rollback does not rebuild or reinterpret old artifacts.

### Revocation

Revocation is control-plane first and hot-path enforced.

The control plane writes `RevocationRecord`s.
The hot path refuses future admissions against those records.

## Release Confidence Model

Release gates use a unified confidence framework that combines structured
conflict analysis, probabilistic uncertainty quantification, and tiered
promotion thresholds.

### ConflictStatus

Policy conflict during release validation is represented as a `ConflictStatus`
record, not a boolean flag:

- `conflict_type`: `rebutting` — two active policies directly contradict each
  other; or `undercutting` — one policy undermines the applicability of another
- `conflict_degree`: normalized magnitude of the conflict in the range [0, 1]
- `extension_count`: number of distinct consistent policy extensions admissible
  under the current policy set

When `extension_count > 1`, the release is blocked — the policy space is
ambiguous and no unique resolution exists. When `extension_count == 1`, exactly
one consistent resolution exists and promotion may proceed. When
`extension_count == 0`, there is no active policy conflict — this is the clean
state required for `BEYOND_REASONABLE_DOUBT` promotion. When `conflict_degree > 0`
and `extension_count == 0` simultaneously, the conflict is in genuine deadlock
(no valid extension resolves it); this case also blocks promotion and must be
escalated to the `Policy Authority`.

### Release BPA Vector

Each deployment gate check (policy evaluation, health probe, canary metric)
emits a belief-plausibility assignment (`BPA`) over three outcomes:
`Safe`, `Degraded`, and `Abort`. A `ReleaseConfidenceVector` combines all
gate BPAs via Dempster's combination rule to produce a confidence interval
[Bel, Pl] on the `Safe` hypothesis. When the conflict mass K exceeds 0.5,
Yager normalization applies and promotion is blocked regardless of the raw
Bel value.

### Three-Tier Promotion Gate

| Tier | Threshold | Action |
|---|---|---|
| `REASONABLE_SUSPICION` | Bel ≥ 0.40 | Route 5% canary traffic; monitor |
| `PREPONDERANCE` | Bel ≥ 0.65 | Staged rollout to 50% traffic |
| `BEYOND_REASONABLE_DOUBT` | Bel ≥ 0.85, extension_count = 0 | Full promotion to 100% |

No release may advance to a higher tier without satisfying the lower-tier
threshold. Tier regression under degraded gate signals requires fresh gate
re-evaluation before re-promotion.

### Observability Resolution

Deployment observability is structured at five resolutions:

| Layer | Scope | V1 Status |
|---|---|---|
| L0 | Raw metrics: CPU, memory, latency, error rate | Active |
| L1 | Service-level health: up/down/degraded per capsule | Active |
| L2 | Feature-level rollout state: canary percentage, tier | Reserved |
| L3 | Release-version summary: promotion history, confidence history | Reserved |
| L4 | Cross-service dependency graph: blast radius modeling | Reserved |

L0 and L1 are active in v1. L2–L4 are reserved and must not be required by
any v1 implementation.

## Evolution Boundaries

### May evolve automatically

The following may evolve automatically because they are not trust roots:

- local caches
- artifact mirror selection
- telemetry presentation
- non-authoritative indexing
- deployment queue ordering inside a single environment

### Must never evolve automatically

The following must never change automatically:

- `ReleaseEnvelope` bytes
- `ReleaseManifest` contents
- dependency lock contents
- attestation set contents
- `PolicySnapshot` selected for a promoted release
- `EnvironmentProfile` trust anchors
- release promotion state
- revocation state
- public deployment result states

No autonomous system may rewrite an artifact or silently promote a release.

## Rollback and Revocation Semantics

### Rollback unit

The rollback unit is one previously admitted `ReleaseRecord` for the same
capsule identity and target environment class.

A rollback creates a new `DeploymentRecord` that references:

- the target environment
- the restored release id
- the source deployment being superseded
- the actor or automation that triggered rollback

### Revocation unit

The revocation unit is exactly one of:

- `ReleaseEnvelope` digest
- signer identity
- locked dependency digest

Logical names are not revocation units in v1.

### Blast radius

- Envelope revocation blocks that exact envelope everywhere.
- Signer revocation blocks every envelope whose trust chain depends on that
  signer.
- Dependency revocation blocks every envelope listing that dependency digest in
  its dependency lock.

### Effect on already-running deployments

Revocation does not rewrite live memory or mutate the running payload.

In v1:

- future admissions are denied immediately
- already-running deployments are marked revoked
- lease renewal is denied
- runtime instances are allowed to drain until lease expiry unless the
  environment profile marks the target as `hard-stop-on-revoke`

### Effect on future admissions

Any release affected by revocation becomes non-deployable until replaced by a
new release envelope with a valid trust chain and valid dependency lock.

## Circuit Breakers

The system must support independent hard stops for:

- artifact publication
- release promotion
- deployment
- cross-environment rollout
- runtime admission
- automated rollback
- trust propagation and signer acceptance

Each breaker must be triggerable without mutating artifact bytes.

## Boring Mode

The boring mode is mandatory.

In boring mode, AI Provenance Spec allows only:

- deployment of already-attested release envelopes from local trusted storage
- evaluation against cached policy snapshots and cached environment profiles
- manual forward deployment by a human operator
- manual rollback to a locally available, previously admitted release

Boring mode forbids:

- new artifact publication
- new signing or attestation
- automatic promotion
- cross-environment rollout waves
- adaptive trust propagation

If trust or policy machinery is impaired, AI Provenance Spec must fail closed into
boring mode rather than fail open.

## Portability Contract

### What travels with the artifact

The portable unit is the `ReleaseEnvelope`.

It carries:

- payload bytes
- release manifest
- dependency lock
- compatibility class declaration
- runtime constraints
- declared capability surface
- provenance and attestation set
- deployment ledger hash: tamper-evident seal over the five-stage build-to-promote
  chain (source commit → build artifact → policy check → canary result →
  promotion timestamp)

### What remains environmental

The following do not travel with the artifact:

- environment-specific secrets
- environment trust anchors
- deployment history
- operator approvals
- incident state
- revocation state
- runtime leases

Artifact portability does not imply deployability. Deployability always depends
on local `PolicySnapshot` and `EnvironmentProfile` state.

## Named Future Primitives

The following primitives are named and reserved but deferred from v1:

- `BehavioralCertificate`
  - LTS-encoded observable API contract for a capsule; two releases holding
    the same certificate are bisimulation-equivalent and hot-swap safe; v1
    stub schema only; certificate issuance and bisimulation checking deferred
    pending toolchain maturity
- `ZKBehavioralProof`
  - zero-knowledge proof of behavioral compliance without revealing capsule
    internals; deferred pending practical toolchain maturity
- `SessionTypedProtocol`
  - compile-time protocol enforcement for tool invocation sequences; deferred
    pending session-type system availability
- `RevocationImpactAssessment`
  - blast-radius simulation and propagation analysis before executing revocation;
    deferred pending dependency graph tooling
- `PolicyTransparencyLog`
  - append-only, publicly verifiable log of all `PolicySnapshot` versions;
    deferred pending multi-tenant requirements
- `PolicyConflictGraph`
  - persistent graph of all active policy conflict relationships, updated
    incrementally as policies change; enables proactive conflict detection
    and AI-assisted policy authoring before any specific release triggers a
    conflict
- `EpistemicStateSnapshot`
  - structured capture of the system's epistemic state — DS confidence values,
    conflict mass, policy resolution state — at each decision point; enables
    "explain this decision" queries at any future point in history
- `CapabilityDriftDetector`
  - per-release semantic diff of capability surface changes, classified as
    surface-compatible, surface-expanding, surface-contracting, or
    surface-mutating; AI-native companion to `BehavioralCertificate`
- `RevocationCascadeSimulator`
  - forward simulation of the minimum recovery path after a revocation event,
    computing optimal restoration sequence from the dependency graph and MDL
    scoring; depends on `RevocationImpactAssessment`
- `ConstitutionalInvariantMonitor`
  - AI-native continuous audit primitive that verifies all constitution
    invariants against the live object graph and emits a signed attestation
    of compliance; the formalization of the AI governance loop

These primitives are architecturally coherent with v1. They are deferred because
v1 does not require them. The v1 object model must remain compatible with their
future addition.

## Amendment Rule

This constitution may change only through an explicit architecture decision that
names:

- the clause being changed
- the reason for change
- migration impact
- compatibility impact
- security impact
- rollback plan
- proof that existing deployment records remain interpretable

An amendment is valid only with recorded approval from:

- `Policy Authority`
- `Release Authority`
- `Environment Owner`

Constitution changes must not be smuggled in through ordinary implementation
work.

## Appendix: Artifact Lifecycle States

The lifecycle states for a release envelope are:

- `authored`
  - payload and manifest exist locally but no envelope exists yet
- `packaged`
  - a release envelope with stable digest exists
- `validated`
  - schema, dependency lock, and compatibility checks passed
- `attested`
  - required attestation set is present and valid
- `promoted`
  - a `ReleaseRecord` marked the envelope deployable for at least one target
    class
- `admitted`
  - a `DeploymentRecord` admitted the envelope into one environment
- `active`
  - the runtime accepted admission and exposed the declared surface
- `superseded`
  - a newer admitted release replaced it for forward deployment
- `revoked`
  - a `RevocationRecord` blocks future admissions
- `retired`
  - not deployable and not eligible for rollback

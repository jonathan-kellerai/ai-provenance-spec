<!-- markdownlint-disable -->
# AI Provenance Spec: Self-Contained Proposal

> **Comprehensive Proposal Packet and Beads-Compatible Spec**
>
> - **Project:** AI Provenance Spec
> - **Date:** 2026-03-26
> - **Status:** Proposal, tightened by constitution and v1 scope
> - **Binding docs:** `docs/governance/constitution.md`, `docs/project-context/v1-scope.md`
> - **Spec format:** `bd create --file` compatible in Part III

---

# Part I: What is AI Provenance Spec?

### Status

This document is the self-contained proposal packet for AI Provenance Spec.

It is written so another strong model or reviewer can understand:

- what AI Provenance Spec is actually trying to build
- what problem it is solving
- what has already been forced into scope
- what adjacent systems matter
- what recent research materially changed the design
- what the narrow serious implementation cut is
- what should be attacked, revised, or rejected

This document is not the constitution. The binding rules remain in:

- `docs/governance/constitution.md`
- `docs/project-context/v1-scope.md`

This document explains the proposal around those rules and packages it into a
form suitable for external review and for `bd create --file`.

### Executive Summary

AI Provenance Spec is the trusted release and deployment substrate for portable
cognition capsules.

Its job is not to make a capsule intelligent. Its job is to answer the hard
deployment questions that ordinary plugin and packaging systems answer badly for
this class of artifact:

- what exact bytes are being shipped
- what exact behavior is being declared
- what exact inputs were validated
- what exact trust chain applies
- what exact runtime target may admit it
- what exact unit can be rolled back
- what exact unit can be revoked
- what exact proof remains after the fact

The proposal has been tightened into ten key commitments:

1. the deployable unit is one immutable `ReleaseEnvelope`
2. buildable artifacts are not deployable by default
3. deployability is decided from explicit trust inputs, not ambient host state
4. runtime admission is host-mediated and manifest-bounded
5. rollback, revocation, and degraded mode are first-class control operations
6. release confidence is a probabilistic interval [Bel, Pl], not a boolean verdict
7. every release carries a tamper-evident `DeploymentLedger` from source to promotion
8. concurrent canary experiments are hard-limited to five per target environment
9. point-in-time deployment queries are answered from bitemporal durable records
10. new capsule admissions undergo a three-phase immunological tolerance gate

### The Problem

The ecosystem is starting to generate a new class of artifact:

- skill-like units with a narrow outer interface
- hidden internal organs such as retrieval, planning, reranking, or local model
  roles
- non-trivial dependency and policy surfaces
- local-first deployment patterns today
- stricter governance, attestation, rollback, and trust-zone requirements later

Conventional plugin and package systems are weak fits for this class because
they usually assume one or more of the following:

- installation is the main boundary
- runtime exposure is effectively static
- provenance ends at package origin
- rollback means reinstalling an older version
- revocation is soft and delayed
- runtime admission is implicit

Those assumptions break down for cognition capsules. Capsules may expose a thin
surface while hiding complex internals, and may need much stricter release,
admission, and revocation semantics than ordinary plugins.

### The Solution

AI Provenance Spec packages a cognition capsule into a release object, validates it,
attests it, promotes it, deploys it into a compatible runtime target, and keeps
durable records for rollback, revocation, and audit.

The core operational path is:

1. author capsule payload and manifest
2. build immutable `ReleaseEnvelope`
3. validate manifest, dependency lock, and compatibility class
4. attach attestation
5. promote into a deployable `ReleaseRecord`
6. deploy into one compatible environment
7. perform runtime admission against manifest and local policy
8. emit durable deployment records
9. support rollback and revocation using exact release units

### What AI Provenance Spec Is

AI Provenance Spec is, primarily:

- a release substrate
- a deployment substrate
- an attestation boundary
- a runtime admission gate
- a rollback and revocation control surface

It is not, primarily:

- a capsule authoring framework
- a cognition runtime
- a marketplace
- a general package manager
- a federated trust exchange in v1

### What a Cognition Capsule Is

For AI Provenance Spec, a cognition capsule is a portable runtime artifact with:

- a declared outer surface
- a declared dependency boundary
- a declared compatibility class
- a hidden internal implementation that Aegis does not interpret semantically
- a need for release, trust, and runtime-admission discipline

The capsule may contain deep internals. AI Provenance Spec does not certify those
internals as correct. It certifies the release envelope, validates the declared
contract around it, and governs its admission into runtime.

### What Makes AI Provenance Spec Special

The project is compelling because it makes four distinctions explicit that most
systems blur:

- `buildable` versus `deployable`
- `declared` versus `validated`
- `recorded` versus `trusted`
- `rolled back` versus `revoked`

Those are not naming preferences. They are the difference between a packaging
tool and a serious release substrate.

### How AI Provenance Spec Works

The kernel concepts are intentionally few.

#### ReleaseEnvelope

The exact deployable unit.

Contains:

- capsule payload
- `ReleaseManifest`
- dependency lock
- compatibility class declaration
- attestation set

#### PolicySnapshot

The exact policy version used to decide releasability and deployability.

#### EnvironmentProfile

The exact runtime target description:

- trust zone
- trust anchors
- compatibility requirements
- local runtime constraints
- runtime admission rules

#### ReleaseRecord

The control-plane decision that a specific release envelope is packaged,
validated, attested, and either promoted or refused.

#### DeploymentRecord

The admission event that says one release went into one environment under one
policy snapshot.

#### RevocationRecord

The explicit durable block on a release envelope digest, signer, or dependency
digest.

### Runtime Boundary

The runtime host remains separate from AI Provenance Spec.

In v1, the deployment target is an Aegis-compatible Archangel runtime family.
That means:

- Aegis does not define the cognition runtime internals
- Aegis does not replace the host's execution model
- Aegis does define what must be packaged, validated, trusted, admitted,
  recorded, rolled back, and revoked

### Sister Systems and Boundaries

#### ArchangelMCP

Archangel is the runtime target family for v1.

Aegis depends on Archangel for:

- runtime admission target
- session-surface exposure
- compatible host semantics

Aegis does not depend on Archangel to define release identity, trust units,
rollback units, or revocation units.

#### Matryoshka

Matryoshka is an example of the kind of cognition capsule Aegis may eventually
ship.

Matryoshka does not define Aegis's architecture. It is a candidate artifact
class, not the substrate.

#### Truth JBT and Sentinel

These systems are relevant as adjacent inspirations:

- Truth JBT for governed state, visibility, and change-control semantics
- Sentinel for research distillation and cross-domain primitives

They are not required runtime dependencies of Aegis v1.

### Forced V1 Decisions

The following decisions are already forced:

- dominant identity: trusted release and deployment substrate
- first user: platform engineer operating one controlled runtime target
- first target family: `archangel.local.v1`
- first deployable artifact: one `ReleaseEnvelope`
- first loop: package, validate, attest, deploy, verify admission, rollback,
  revoke
- boring mode: mandatory, fail-closed, rollback-capable

### What Reviewers Should Attack

External reviewers should focus on these questions:

- Is `ReleaseEnvelope` the right deployable and trust unit, or should trust and
  deployment be split differently?
- Is the host/runtime boundary precise enough, or does the proposal still hide
  critical host assumptions?
- Are rollback and revocation semantics operationally credible?
- Is the v1 artifact class narrow enough?
- Does the control-plane complexity earn itself compared to simpler manual
  mounting paths?

---

# Part II: The Four Research-Grounded Findings

The following four findings materially changed the proposal. They are not
polish. They forced architecture.

### Finding 1: The release boundary must be an exact trust envelope

#### What it is

The proposal originally drifted toward loose language:

- package the thing
- sign the thing
- deploy the thing

That is not good enough for a cognition capsule. The stronger conclusion is:

- the release boundary must be one exact immutable object
- trust must bind to exact bytes plus exact validation inputs
- deployability must be distinct from mere package existence

This produced the `ReleaseEnvelope` concept.

#### Why the earlier framing was weak

Without one exact trust envelope:

- provenance becomes hand-wavy
- rollback becomes reconstruction
- revocation becomes ambiguous
- policy evaluation floats across mutable context

The system cannot answer “what exactly was trusted?” if the answer depends on
ambient files, mutable build products, or hand-waved package identity.

#### Research influence

This finding is strongly shaped by modern supply-chain integrity work,
especially:

- SLSA provenance and pinned-input thinking
- policy-transparency style reasoning about proving what software supply chain
  decision actually happened
- the broader lesson from AI software supply-chain research that AI artifacts
  need stricter provenance and attestation boundaries, not looser ones

#### Why it is compelling

This is the move that turns Aegis from “tooling around skills” into a real
release substrate.

It gives the project a serious answer to:

- what exact bytes are trusted
- what exact inputs were validated
- what exact object can be rolled back
- what exact object can be revoked

#### How it changes the project

This finding directly forced:

- `ReleaseEnvelope` as the deployable unit
- `buildable != deployable`
- promotion only after attestation
- trust decisions over exact tuples, not labels
- release records and deployment records as first-class durable objects

### Finding 2: Aegis is host-mediated, not server-defined

#### What it is

The earlier intuitive story was:

- a skill registers surface
- the gateway exposes it
- it executes
- it unregisters

That still matters, but it is incomplete. The stronger conclusion is:

- the host is part of the product boundary
- visibility, admission, and context exposure are not defined by the server
  alone
- Aegis must assume a host-mediated admission model

#### Why the earlier framing was weak

If the server is treated as sufficient, the proposal makes false claims:

- unmount implies disappearance
- tool removal implies cognitive eviction
- gateway state implies host exposure

Those claims are not stable. They hide exactly where runtime truth actually
lives.

#### Research influence

This finding is shaped by:

- the current MCP lifecycle and sampling model, where hosts and clients retain
  decisive control over visibility and interaction
- service-mesh and control-plane lessons that the data plane and presentation
  boundary matter as much as the control logic

#### Why it is compelling

This forces Aegis to tell the truth about what it can and cannot guarantee.

It replaces the soft slogan “deploy and dissolve” with a harder model:

- explicit admission
- manifest-bounded runtime surface
- host compatibility class
- typed residue or durable deployment records instead of magical forgetting

#### How it changes the project

This finding directly forced:

- `EnvironmentProfile` as a required trust input
- explicit compatibility classes
- Archangel compatibility as a target contract, not a vague integration
- runtime admission as a distinct phase from deployment

### Finding 3: Portable cognition should be treated like virtual memory, not installed plugins

#### What it is

The most powerful systems insight is that a cognition capsule should have:

- a stable logical identity
- a dynamically bounded active surface
- hidden internal depth that is not always physically exposed

That is closer to virtual memory than to plugin installation.

#### Why this matters

Plugin systems assume persistence and standing exposure.

Aegis wants something else:

- portable artifact identity
- explicit release boundary
- narrow live surface
- bounded runtime authority
- teardown and re-admission without reinstall semantics

#### Research influence

This finding is shaped by:

- recent virtualized attention and KV-memory work, which separates logical
  continuity from physical backing
- attention-sink and working-set style thinking, where small stable anchors can
  support much larger dynamic movement

#### Why it is compelling

This gives Aegis its strongest non-obvious design perspective.

It explains why the project is not “plugins, but safer.” It is a release and
admission system for artifacts whose outer surface can stay small even while
their internals remain deep.

#### How it changes the project

This finding directly forced:

- declared capability surface as part of the manifest
- separation of artifact identity from active runtime exposure
- boring mode that does not depend on full higher-order machinery
- a portable capsule framing instead of plugin-install semantics

### Finding 4: Admission, rollback, and revocation must be different primitives

#### What it is

The proposal originally risked treating these as one blended safety story.
They are not.

- admission decides whether a release may enter a target
- rollback restores a prior valid release
- revocation blocks future trust and future admissions

They solve different problems and require different records.

#### Why the earlier framing was weak

If rollback and revocation are blurred:

- rollback may target untrusted or never-admitted artifacts
- revocation may become a soft label instead of a real block
- incident behavior becomes ambiguous

The project cannot answer “what happens now?” under failure.

#### Research influence

This finding is shaped by:

- capability-security reasoning about explicit scoped authority
- verifier-first execution and admission thinking
- durable execution and snapshotting lessons that pinned prior states matter for
  safe restore

#### Why it is compelling

This is where Aegis stops behaving like optimistic tooling and starts behaving
like infrastructure.

It makes incident response, boring mode, and trust failure readable and
controllable.

#### How it changes the project

This finding directly forced:

- separate `ReleaseRecord`, `DeploymentRecord`, and `RevocationRecord`
- rollback only to previously admitted releases
- revocation by exact envelope, signer, or dependency digest
- mandatory degraded and rollback-only modes
- circuit breakers as first-class control operations

### Finding 5: Release confidence must be a probabilistic interval, not a boolean verdict

#### What it is

The original design gates release promotion on a pass/fail policy check. That
is necessary but not sufficient. A boolean verdict discards the uncertainty
signal that tells you whether a release is confidently safe or merely
not-yet-proven-unsafe.

The unified Release Confidence Model (combining innovations from argumentation
theory, Dempster-Shafer evidence theory, and legal epistemology) gives every
release a confidence interval [Bel, Pl] and routes it through one of three
explicit promotion tiers.

#### Why the earlier framing was weak

A policy check that returns `true` gives no information about how close to
`false` the decision was. A `ConflictStatus` with `extension_count = 1` means
exactly one consistent resolution exists — barely passing. A `ConflictStatus`
with `extension_count = 0` means deadlock. These are not equivalent to
`policy_violation = false`.

#### Research influence

This finding is shaped by:

- Dung's argumentation framework: conflict type (rebutting vs undercutting) and
  extension count determine whether a policy is merely challenged or structurally
  broken
- Dempster-Shafer evidence theory: combination of uncertain evidence sources
  produces a [Bel, Pl] interval; conflict mass K > 0.5 invalidates naive
  normalization
- Legal epistemology: REASONABLE_SUSPICION / PREPONDERANCE / BEYOND_REASONABLE_DOUBT
  as calibrated confidence thresholds that gate increasing levels of commitment

#### How it changes the project

This finding forced:

- `ConflictStatus` replacing the boolean `policy_violation` flag
- `ReleaseConfidenceVector` as a canonical durable object traveling with the
  `ReleaseRecord`
- three-tier promotion gate: canary at REASONABLE_SUSPICION, staged at
  PREPONDERANCE, full promotion at BEYOND_REASONABLE_DOUBT
- `confidence-blocked` as a distinct negative deployment state

### Finding 6: Release provenance must be a tamper-evident chain

#### What it is

The original design attests the release envelope but does not seal the
five-stage production pipeline. A `DeploymentLedger` makes each stage
in the source-to-promotion chain a hash-linked commitment:

```
source_commit_hash → build_artifact_hash → policy_check_hash
  → canary_result_hash → promotion_timestamp_hash → ledger_hash
```

Any modification to any stage — rebuilding the artifact, re-running policy
checks with different inputs, reordering canary results — produces a different
`ledger_hash` and makes the release non-promotable.

#### Why the earlier framing was weak

Attestation that binds to the envelope bytes but not to the production pipeline
leaves the pipeline itself open to silent manipulation. The `DeploymentLedger`
extends the attestation boundary to the entire path from source to production.

#### Research influence

Shaped by:

- git object model: content-addressed DAG where each commit embeds parent digests
- SLSA provenance chains: linking build outputs to their inputs cryptographically
- in-toto framework: step-by-step chain of custody from source to deployment

#### How it changes the project

This finding forced:

- `DeploymentLedger` as a canonical durable object
- `deployment_ledger_hash` as a required field in Packaging success output
- ledger hash verification as a hot-path step before admission

### Finding 7: Deployment records must be bitemporal

#### What it is

A deployment record that captures only wall-clock time cannot answer the
question "what was deployed in environment E at point-in-time T?" without
replaying the full event log. A `BitemporalDeploymentRecord` carries two
independent time axes:

- **valid-time**: when the deployment was actually live
  (`valid_from_deploy`, `valid_until_deploy`)
- **transaction-time**: when Aegis recorded the event
  (`tx_ingested`, `tx_retired`)

Point-in-time queries become first-class operations answered from durable
records alone.

#### Research influence

Shaped by:

- bitemporal database theory (Snodgrass, Jensen): separating when something was
  true in the world from when the system learned about it
- Datomic's immutable bitemporal fact model: as-of queries without reconstruction

#### How it changes the project

This finding forced:

- `BitemporalDeploymentRecord` extending `DeploymentRecord` with four temporal fields
- point-in-time deployment queries as a v1 audit capability
- `tx_ingested` and `valid_from_deploy` as required fields in Deployment success output

### Finding 8: Canary experiments must have a hard ceiling

#### What it is

When more than five canary experiments are active simultaneously in one
environment, signal attribution becomes unreliable. A metric anomaly cannot be
assigned to the release that caused it without ambiguity.

The hard ceiling of five concurrent canaries per target environment is enforced
at the `ReleaseAuditRecord` level — a `canary_count > 5` is non-conformant and
triggers a review flag. The queue is visible. Growth is never silent.

#### Research influence

Shaped by:

- Miller's Law: working memory capacity is bounded at approximately 7 ± 2 items;
  5 is the safe engineering margin
- queue theory: unbounded concurrent experiments create measurement interference
  that negates the value of the experiment

#### How it changes the project

This finding forced:

- invariant 15: hard ceiling of five concurrent canaries
- `canary_count_at_promotion` as a required field in Deployment success output
- `ReleaseAuditRecord` as a new canonical object
- non-conformant flag when `canary_count > 5` at promotion time

### Finding 9: New capsule admissions must undergo a tolerance gate

#### What it is

The primary admission failure mode is not a capsule that attacks the system —
it is a capsule that looks legitimate but creates systemic policy conflict when
admitted alongside existing capsules. The three-phase source tolerance gate,
borrowed from immunological thymic selection, catches this class of failure:

1. **Schema overlap** (positive selection): does this capsule's surface overlap
   with existing admitted capsules?
2. **Autoreactive check** (negative selection): does this capsule's policy surface
   collide with existing rules at a rate > 5%? If so, fire `AUTOIMMUNE_FAILURE`.
3. **Burn-in**: first ten invocations at 70% trust weight before full grant.

#### Research influence

Shaped by:

- mammalian thymic selection: T-cells that react too strongly against self-antigens
  are deleted before they enter circulation (clonal deletion)
- Snare tool (peg/snare): production canary-token pattern for AI agent admission
- immunological danger model (Matzinger): treat unexpected self-reactivity as a
  danger signal, not just a mismatch

#### How it changes the project

This finding forced:

- three-phase source tolerance gate in the deploy-time control plane
- `AUTOIMMUNE_FAILURE` circuit breaker for policy-colliding capsule classes
- `tolerance-blocked` as a distinct negative deployment state
- burn-in routing as a mandatory admission phase

### Finding 10: MDL scheduling minimizes deployment risk per capability unit

#### What it is

When multiple release candidates are queued, the promotion scheduler should
prefer releases that maximize functional capability gain per unit of deployment
risk — not the releases that represent the most accumulated work or the largest
changeset.

MDL (Minimum Description Length) selection: a release that changes three files
and provides equivalent observable capability to one that changes thirty files
should be promoted first. It contributes the same value at lower blast radius
and is cheaper to roll back if it fails.

#### Research influence

Shaped by:

- Kolmogorov complexity and MDL principle (Rissanen): the best model is the
  simplest one that fully describes the data
- Occam's Razor formalized: prefer the hypothesis that requires the fewest
  assumptions (changes) to explain the observation (new capability)

#### How it changes the project

This finding forced:

- MDL score computation as a consideration in the promotion scheduling step
- "select highest-MDL-score release when multiple candidates are queued"
  added to the deploy-time control-plane work

### Why these four findings matter together

Together, these findings give AI Provenance Spec a coherent identity:

- exact release boundary
- explicit host/runtime boundary
- portable but bounded capsule model
- distinct control operations for admission, rollback, and revocation

Without these findings, Aegis would drift back toward a vague plugin story.
With them, it becomes a serious substrate for portable cognition capsules.

---

# Part III: Implementation Spec

> **Everything below is `bd create --file` compatible.**
> Each `##` heading creates a beads issue. Run:
> `bd create --file docs/proposal.md`

---

## AI Provenance Spec - Trusted Release Substrate for Portable Cognition Capsules

AI Provenance Spec is a trusted release and deployment substrate for portable cognition
capsules targeting an Aegis-compatible Archangel runtime family. The v1 cut is
intentionally narrow: one artifact class (`ReleaseEnvelope`), one compatibility
class (`archangel.local.v1`), one first user (platform engineer), one serious
loop (package, validate, attest, deploy, verify admission, rollback, revoke).

This epic exists to build the smallest implementation that proves the proposal's
core thesis: that a cognition capsule can become a portable, attestable,
governable runtime object with explicit release, trust, rollback, and
revocation boundaries.

**Success Metrics:**

- A capsule payload plus manifest becomes one immutable `ReleaseEnvelope`
- Buildable artifacts are not deployable until validated, attested, and
  promoted
- Deployment evaluates against one `PolicySnapshot` and one
  `EnvironmentProfile`
- Runtime admission exposes only the manifest-declared surface
- Rollback restores a previously admitted release without rebuilding old
  artifacts
- Revocation blocks future admissions deterministically
- Degraded mode and rollback-only mode fail closed and remain usable

### Priority
1

### Type
epic

### Design
**Decision Trace:**

- Constitution: dominant identity is deployment substrate
- V1 Scope: artifact class is one `ReleaseEnvelope` targeting
  `archangel.local.v1`
- Finding 1: trust must bind to exact release envelope bytes and exact policy
  inputs
- Finding 2: runtime admission is host-mediated
- Finding 3: artifact identity and active runtime exposure are distinct
- Finding 4: admission, rollback, and revocation are separate control
  operations

**Kernel objects in v1:**

- `ReleaseEnvelope`
- `PolicySnapshot`
- `EnvironmentProfile`
- `ReleaseRecord`
- `DeploymentRecord`
- `RevocationRecord`
- `DeploymentLedger`
- `ReleaseConfidenceVector`
- `BitemporalDeploymentRecord`
- `ReleaseAuditRecord`
- `ConflictStatus`

**Boundaries:**

- Aegis does not define the capsule's internal reasoning logic
- Aegis does define the release, trust, admission, rollback, and revocation
  boundaries around it

### Acceptance Criteria
- [ ] All subtasks complete and integrated
- [ ] One capsule can be packaged into an immutable `ReleaseEnvelope`
- [ ] One release can be validated, attested, and promoted
- [ ] One promoted release can be deployed into one `archangel.local.v1`
      environment
- [ ] Runtime admission exposes exactly the manifest-declared surface
- [ ] Rollback to a previously admitted release succeeds without artifact
      rebuild
- [ ] Revocation blocks future admissions for the targeted release or locked
      dependency
- [ ] Degraded mode and rollback-only mode behave as specified
- [ ] Every packaged release emits a sealed `deployment_ledger_hash`
- [ ] Every promoted release carries a `ReleaseConfidenceVector` with [Bel, Pl]
- [ ] Deployment confidence tier is recorded in every `DeploymentRecord`
- [ ] `BitemporalDeploymentRecord` supports point-in-time deployment queries
- [ ] Canary count at promotion is recorded; count > 5 is flagged non-conformant
- [ ] Three-phase source tolerance gate runs for every new capsule admission

### Labels
epic, ai-provenance-spec, release-substrate, cognition-capsules

---

## AI Provenance Spec - ReleaseEnvelope Builder and Manifest Contract

Implement the v1 deployable unit.

This track owns:

- `ReleaseManifest` schema
- dependency lock schema
- `ReleaseEnvelope` assembly
- stable digests and release id derivation
- explicit distinction between `buildable` and `deployable`

This is the critical path. Nothing else in v1 is coherent until the release
envelope is exact and immutable.

### Priority
0

### Type
feature

### Design
**Decision Trace:**

- Finding 1 is primary here: exact trust envelope, not loose package identity
- Constitution: no deployable artifact without a machine-readable manifest,
  immutable bytes, and stable digests
- V1 Scope: one supported artifact class only

**Required fields in `ReleaseManifest`:**

- capsule identity
- semantic version
- payload entrypoint
- declared capability surface
- dependency lock root
- compatibility class
- policy class
- runtime constraints
- rollback compatibility statement
- `behavioral_certificate_hash` (v1: null stub; post-v1: SHA256 of LTS encoding)

**Implementation notes:**

- The release id should be derived from envelope content, not assigned by a
  mutable registry
- The manifest must declare the surface explicitly; undeclared surface is not
  permitted later at admission time
- The builder must emit machine-readable digests for payload, manifest, and
  dependency lock

### Acceptance Criteria
- [ ] `ReleaseManifest` schema defined and versioned
- [ ] Dependency lock schema defined and versioned
- [ ] `ReleaseEnvelope` format defined and immutable after build
- [ ] Release id deterministically derived from envelope bytes
- [ ] Builder emits `packaged` result with release id and digests
- [ ] Buildable artifacts are not marked deployable by the builder
- [ ] Builder refuses envelopes missing declared capability surface or rollback
      compatibility statement
- [ ] Builder emits `deployment_ledger_hash` sealing all five build stages
- [ ] Builder populates `behavioral_certificate_hash` as null stub in v1

### Labels
core, release-envelope, manifest, critical-path

### Dependencies
blocks:AI Provenance Spec - Trusted Release Substrate for Portable Cognition Capsules

---

## AI Provenance Spec - Attestation, Trust Verification, and Release Promotion

Implement the trust path that makes a release envelope deployable.

This track owns:

- attestation format
- signature verification
- trust-anchor evaluation
- promotion rules
- `ReleaseRecord` creation

The key boundary is that attestation proves exact envelope identity and pinned
inputs. Promotion decides deployability. These are related but distinct.

### Priority
0

### Type
feature

### Design
**Decision Trace:**

- Constitution: no release without attestation; no attestation without pinned
  inputs
- Finding 1: trust is an exact tuple, not a label
- Finding 4: promotion must remain separate from deployment and revocation

**Required verification outputs:**

- envelope digest verified
- attestation set present and valid
- signer or attestor chain trusted
- pinned inputs match the promoted envelope
- release status set to promoted or refused in `ReleaseRecord`

**Non-goals in v1:**

- no autonomous release approval
- no dynamic trust-anchor synthesis
- no cross-tenant trust exchange

### Acceptance Criteria
- [ ] Attestation format defined for v1 release envelopes
- [ ] Verification distinguishes `invalid`, `unverifiable`, and `untrusted`
- [ ] Promotion writes a durable `ReleaseRecord`
- [ ] Unattested releases cannot be promoted
- [ ] Releases with failing trust chain cannot be promoted
- [ ] Promotion output records policy snapshot id and actor
- [ ] Verification path works from durable records alone
- [ ] `ReleaseConfidenceVector` is computed by combining all gate BPA vectors
- [ ] `ConflictStatus` is emitted with `conflict_type` and `extension_count`
- [ ] Promotion is blocked when `extension_count > 1` or conflict mass K > 0.5
- [ ] `deployment_confidence_tier` is set before `ReleaseRecord` is written

### Labels
attestation, trust, promotion, critical-path

### Dependencies
blocks:AI Provenance Spec - Trusted Release Substrate for Portable Cognition Capsules
depends on:AI Provenance Spec - ReleaseEnvelope Builder and Manifest Contract

---

## AI Provenance Spec - PolicySnapshot and EnvironmentProfile Admission Model

Implement the two non-artifact trust inputs that determine where a release may
be deployed.

This track owns:

- `PolicySnapshot` schema
- `EnvironmentProfile` schema
- compatibility-class checks
- deploy-time policy evaluation
- refusal reasons tied to exact snapshot and environment ids

This is where Aegis stops pretending that deployability is universal.

### Priority
1

### Type
feature

### Design
**Decision Trace:**

- Constitution: no deployment without one exact `PolicySnapshot` and one exact
  `EnvironmentProfile`
- Finding 2: host/runtime boundary is real; admission is host-mediated
- Finding 4: policy-blocked is a distinct public state

**`EnvironmentProfile` must declare:**

- environment id
- trust zone
- trust anchors
- compatibility classes accepted
- runtime constraints
- hard-stop-on-revoke behavior

**`PolicySnapshot` must declare:**

- snapshot id
- policy class mapping
- deploy-time deny rules
- least-authority rules
- degraded-mode rules

### Acceptance Criteria
- [ ] `PolicySnapshot` schema defined and versioned
- [ ] `EnvironmentProfile` schema defined and versioned
- [ ] Deploy-time evaluation returns `policy-blocked` distinctly from
      `untrusted`
- [ ] Compatibility mismatch produces explicit refusal
- [ ] Environment profile trust anchors participate in trust tuple
- [ ] Admission decision records exact policy snapshot id and environment
      profile id
- [ ] Stale environment metadata forces degraded behavior as specified

### Labels
policy, environment, admission, host-boundary

### Dependencies
blocks:AI Provenance Spec - Trusted Release Substrate for Portable Cognition Capsules
depends on:AI Provenance Spec - ReleaseEnvelope Builder and Manifest Contract

---

## AI Provenance Spec - Archangel Local Runtime Admission and Surface Enforcement

Implement the v1 runtime-admission handoff for `archangel.local.v1`.

This track owns:

- deploy-time admission handoff into the runtime target
- manifest-surface enforcement
- compatibility verification at the runtime boundary
- `DeploymentRecord` emission

The requirement is strict: runtime admission must not expose more than the
manifest-declared surface.

### Priority
1

### Type
feature

### Design
**Decision Trace:**

- Finding 2: host-mediated runtime admission is a separate phase
- Finding 3: artifact identity and active exposure are distinct
- Constitution: runtime admission may not expose undeclared capability

**Admission contract:**

- input: release id, environment profile id, policy snapshot id
- runtime verifies compatibility class and local constraints
- runtime receives manifest-declared tools, prompts, resources, and templates
- runtime refuses undeclared expansion

**V1 boundary:**

- one runtime family only: `archangel.local.v1`
- no federation
- no dynamic cross-host translation layer

### Acceptance Criteria
- [ ] One promoted release can be deployed into one `archangel.local.v1`
      environment
- [ ] Runtime admission verifies compatibility class
- [ ] Runtime exposure is bounded to manifest-declared surface
- [ ] Admission emits `DeploymentRecord` with actor, time, policy snapshot id,
      and environment profile id
- [ ] Runtime can refuse admission locally on compatibility or constraint
      failure
- [ ] No undeclared surface bypass is possible on the admitted path

### Labels
runtime, admission, archangel, surface-enforcement

### Dependencies
blocks:AI Provenance Spec - Trusted Release Substrate for Portable Cognition Capsules
depends on:AI Provenance Spec - Attestation, Trust Verification, and Release Promotion
depends on:AI Provenance Spec - PolicySnapshot and EnvironmentProfile Admission Model

---

## AI Provenance Spec - Rollback, Revocation, and Lease-Control Semantics

Implement the control operations that differentiate incident response from
ordinary deployment.

This track owns:

- rollback semantics
- revocation semantics
- lease-renewal denial on revoke
- running-deployment behavior on revoke
- `RevocationRecord` handling

The central rule is that rollback and revocation remain different primitives.

### Priority
1

### Type
feature

### Design
**Decision Trace:**

- Finding 4 is primary here
- Constitution: rollback unit is a previously admitted release; revocation unit
  is exact envelope digest, signer, or locked dependency digest
- V1 Scope: `revoked`, `superseded`, `degraded`, and `rollback-only` are
  distinct states

**Rollback rule:**

- rollback deploys a prior admitted release
- rollback creates a new `DeploymentRecord`
- rollback never reconstructs artifacts from mutable state

**Revocation rule:**

- future admissions denied immediately
- already-running deployments marked revoked
- lease renewal denied
- drain until lease expiry unless environment profile requires hard stop

### Acceptance Criteria
- [ ] Rollback restores a previously admitted release without rebuild
- [ ] Rollback records restored release id and superseded deployment id
- [ ] Revocation works at envelope, signer, and dependency level
- [ ] Revocation blocks future admissions deterministically
- [ ] Running deployments deny lease renewal after revoke
- [ ] Environment profile can require hard-stop-on-revoke
- [ ] `superseded` and `revoked` remain distinct visible states

### Labels
rollback, revocation, incident-response, leases

### Dependencies
blocks:AI Provenance Spec - Trusted Release Substrate for Portable Cognition Capsules
depends on:AI Provenance Spec - Attestation, Trust Verification, and Release Promotion
depends on:AI Provenance Spec - PolicySnapshot and EnvironmentProfile Admission Model
depends on:AI Provenance Spec - Archangel Local Runtime Admission and Surface Enforcement

---

## AI Provenance Spec - Degraded Mode, Rollback-Only Mode, and Circuit Breakers

Implement the safe fallback path.

This track owns:

- degraded-mode entry and behavior
- rollback-only mode
- circuit-breaker controls
- refusal behavior when policy, attestation, or environment facts are impaired

This is mandatory. Aegis is not serious if it only works while all higher-order
machinery is healthy.

### Priority
1

### Type
feature

### Design
**Decision Trace:**

- Finding 4: boring mode is part of the trust story, not a convenience
- Constitution: no failure of higher-order automation may cause fail-open
  deployment
- V1 Scope: degraded mode behavior is explicitly specified for policy engine
  failure, attestation outage, partial verification, stale environment
  metadata, and missing rollback target

**Required circuit breakers:**

- artifact publication
- release promotion
- deployment
- cross-environment rollout
- runtime admission
- automated rollback
- trust propagation

**Required safe-path behavior:**

- no new forward deploy on missing policy engine
- no promotion without attestation
- rollback only to locally present, previously verified releases
- no mutation of current deployment on failed rollback target lookup

### Acceptance Criteria
- [ ] Degraded mode can be entered manually and automatically
- [ ] Rollback-only mode blocks forward deployment
- [ ] Missing policy engine fails closed
- [ ] Missing attestation blocks promotion and forward deploy
- [ ] Partial signature verification yields `unverifiable`
- [ ] Stale environment metadata forces degraded behavior
- [ ] Missing rollback target does not mutate current deployment
- [ ] Circuit breakers are independently triggerable

### Labels
degraded-mode, circuit-breakers, safety, boring-mode

### Dependencies
blocks:AI Provenance Spec - Trusted Release Substrate for Portable Cognition Capsules
depends on:AI Provenance Spec - Rollback, Revocation, and Lease-Control Semantics

---

## AI Provenance Spec - Deployment Audit, Decision Trace, and External Review Packet

Implement the review and audit outputs that prove the system can explain itself
to humans and to other models.

This track owns:

- release decision trace export
- deployment trace export
- self-contained review packet generation
- provenance-rich external review inputs

The goal is not pretty reporting. The goal is to make architecture, trust, and
failure reviewable without chasing hidden state.

### Priority
2

### Type
feature

### Design
**Decision Trace:**

- This proposal itself is the first example of the review packet shape
- Finding 1 requires exact trust boundary traceability
- Finding 2 requires host/runtime assumptions to be explicit
- Finding 4 requires incident semantics to remain inspectable after the fact

**Required packet contents:**

- release identity and digests
- manifest summary
- dependency lock summary
- attestation summary
- policy snapshot summary
- environment profile summary
- deployment and refusal states
- rollback and revocation semantics

### Acceptance Criteria
- [ ] A release can emit a self-contained review packet from durable records
- [ ] A deployment can emit a self-contained review packet from durable records
- [ ] The packet makes buildable vs deployable distinction explicit
- [ ] The packet makes trusted vs recorded inputs explicit
- [ ] The packet makes rollback vs revocation semantics explicit
- [ ] A reviewer can reconstruct the main decision path without reading source
      code

### Labels
audit, provenance, review-packet, decision-trace

### Dependencies
depends on:AI Provenance Spec - Attestation, Trust Verification, and Release Promotion
depends on:AI Provenance Spec - PolicySnapshot and EnvironmentProfile Admission Model
depends on:AI Provenance Spec - Archangel Local Runtime Admission and Surface Enforcement
depends on:AI Provenance Spec - Rollback, Revocation, and Lease-Control Semantics

---

## AI Provenance Spec - Release Confidence Model and DeploymentLedger

Implement the unified confidence framework and tamper-evident ledger.

This track owns:

- `ConflictStatus` schema and policy conflict evaluation
- `ReleaseConfidenceVector` computation via Dempster-Shafer combination
- three-tier promotion gate enforcement
- `DeploymentLedger` five-stage hash chain
- `BitemporalDeploymentRecord` temporal field extensions
- `ReleaseAuditRecord` schema including canary count

### Priority
1

### Type
feature

### Design
**Decision Trace:**

- Finding 5: boolean policy verdicts discard the uncertainty signal; structured
  conflict analysis and probabilistic confidence intervals replace them
- Finding 6: attestation must extend to the full build pipeline via tamper-evident
  ledger, not just the envelope bytes
- Finding 7: deployment queries must be answerable at any historical point-in-time
  without event replay
- Finding 8: canary count must be bounded and recorded; measurement fidelity
  requires a hard ceiling of 5 concurrent experiments

**`ConflictStatus` fields:**
- `conflict_type`: rebutting | undercutting
- `conflict_degree`: float [0, 1]
- `extension_count`: int (0 = deadlock, 1 = unique resolution, >1 = block)

**Promotion tier thresholds:**
- REASONABLE_SUSPICION: Bel ≥ 0.40 → 5% canary traffic
- PREPONDERANCE: Bel ≥ 0.65 → 50% staged rollout
- BEYOND_REASONABLE_DOUBT: Bel ≥ 0.85, extension_count = 0 → full promotion

**DeploymentLedger chain:**
- source_commit_hash → build_artifact_hash → policy_check_hash
  → canary_result_hash → promotion_timestamp_hash → ledger_hash

### Acceptance Criteria
- [ ] `ConflictStatus` emitted for every policy evaluation
- [ ] `ReleaseConfidenceVector` computed from combined gate BPA vectors
- [ ] Promotion blocked when extension_count > 1 or K > 0.5
- [ ] Three promotion tiers enforced with recorded threshold values
- [ ] `DeploymentLedger` sealed at packaging time; verified at admission
- [ ] `deployment_ledger_hash` mismatch blocks admission
- [ ] `BitemporalDeploymentRecord` supports as-of queries by valid-time
- [ ] `canary_count_at_promotion` recorded; count > 5 flagged non-conformant

### Labels
confidence-model, deployment-ledger, bpa, bitemporal, canary-ceiling

### Dependencies
blocks:AI Provenance Spec - Trusted Release Substrate for Portable Cognition Capsules
depends on:AI Provenance Spec - ReleaseEnvelope Builder and Manifest Contract
depends on:AI Provenance Spec - Attestation, Trust Verification, and Release Promotion

# AI Provenance Spec V1 Scope

## Product Identity

AI Provenance Spec v1 is a local-first release and deployment substrate for one class of
portable cognition capsule.

It packages, validates, attests, deploys, rolls back, and revokes that capsule
class against one controlled runtime family.

It is not, in v1:

- a general package ecosystem
- a federated trust exchange
- a marketplace
- a runtime scheduler for arbitrary services
- an autonomous release system
- a policy synthesis system

## Exact First User

The first user is a platform engineer who operates an Aegis-compatible
Archangel deployment target and is responsible for shipping one cognition
capsule safely into that runtime.

The first user is not a casual skill author, not a marketplace consumer, and
not a multi-tenant platform operator.

## Exact First Use Case

The first use case is:

Package one cognition capsule, validate it, attest it, deploy it to one
controlled runtime target, verify runtime admission, roll back to a previous
release, and revoke the bad release.

If AI Provenance Spec does not do that better than ad hoc local mounting and manual
rollback, v1 is not justified.

## Exact First Artifact Class

The only supported v1 artifact class is one `ReleaseEnvelope` for one portable
cognition capsule targeting the compatibility class `archangel.local.v1`.

The v1 capsule may contain opaque internal logic. AI Provenance Spec does not inspect or
certify that internal cognition logic. It certifies and deploys the release
envelope around it.

Each v1 release envelope contains:

- one capsule payload
- one `ReleaseManifest`
- one dependency lock
- one declared capability surface
- one compatibility class declaration
- one attestation set

V1 does not support multiple artifact classes.

## Buildable vs Deployable

This distinction is mandatory in v1:

- `buildable`
  - the payload and manifest can be assembled into a release envelope
- `deployable`
  - the release envelope has passed validation, has valid attestation, has a
    promoted `ReleaseRecord`, and is admissible under one `PolicySnapshot` and
    one `EnvironmentProfile`

Buildable artifacts are not deployable by default.

## Smallest Falsifiable Loop

The v1 thesis stands or falls on this loop:

1. author one capsule payload and manifest
2. package them into one immutable `ReleaseEnvelope` with a sealed `deployment_ledger_hash`
3. validate schema, dependency lock, compatibility class, and policy class; emit `ConflictStatus`
4. attach valid attestation
5. evaluate release confidence: combine all gate BPA vectors into one `ReleaseConfidenceVector`;
   confirm confidence tier reaches `PREPONDERANCE` (Bel ≥ 0.65) before promotion
6. promote the envelope into one deployable `ReleaseRecord`; record `canary_count_at_promotion`
7. deploy it into one `archangel.local.v1` environment at `REASONABLE_SUSPICION` tier (5% canary traffic)
8. advance to full promotion once `BEYOND_REASONABLE_DOUBT` tier is confirmed (Bel ≥ 0.85)
9. verify that runtime admission exposes exactly the manifest-declared surface
10. roll back to one previous admitted release
11. revoke the bad release and prove new admissions are denied

If this loop is not reliable, the larger Aegis architecture is not earned.

## Exact Success and Failure Contract

Every stage produces one explicit machine-readable result.

### Packaging success

Result state: `packaged`

Always emits:

- `release_id`
- `envelope_digest`
- `manifest_digest`
- `payload_digest`
- `dependency_lock_digest`
- `compatibility_class`
- `deployment_ledger_hash`

### Validation success

Result state: `validated`

Always emits:

- `release_id`
- `validation_profile`
- `policy_class`
- `validation_time`
- `validated_constraints`

### Deployment success

Result state: `admitted`

Always emits:

- `deployment_id`
- `release_id`
- `policy_snapshot_id`
- `environment_profile_id`
- `surface_digest`
- `actor`
- `admission_time`
- `valid_from_deploy`
- `valid_until_deploy`
- `tx_ingested`
- `deployment_confidence_tier`
- `canary_count_at_promotion`

### Blocked deployment

Deployment failure must emit exactly one of the negative states defined below,
plus:

- `release_id` if known
- `environment_profile_id` if known
- `reason_code`
- `policy_snapshot_id` if evaluated

### Revocation

Result state: `revoked`

Always emits:

- `revocation_id`
- `revocation_unit`
- `revocation_scope`
- `future_admissions`
- `running_deployment_action`
- `actor`

### Rollback

Result state: `admitted`

Rollback is represented as a deployment event with:

- `deployment_action=rollback`
- `restored_release_id`
- `superseded_deployment_id`

No generic success blob is allowed. Each stage must emit one typed result.

## Required V1 Object Model

The required object set for v1 is:

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

No other durable kernel object is required in v1.

## Online and Offline Partition

### Author-time

Human-supplied work:

- create payload
- write release manifest
- declare dependencies
- declare compatibility class
- declare policy class
- declare rollback compatibility statement

### Release-time

Control-plane work:

- build release envelope
- compute digests
- validate schema and dependency lock
- verify compatibility class
- attach attestation
- evaluate promotion policy
- write `ReleaseRecord`

### Deploy-time

Hot-path work:

- resolve release by id
- verify signature and attestation
- load policy snapshot and environment profile
- evaluate deploy-time policy; emit `ConflictStatus`
- run source tolerance gate: schema overlap check, autoreactive policy collision
  check (>5% collision rate fires `AUTOIMMUNE_FAILURE` breaker), burn-in routing
  for first ten invocations at 70% weight
- select highest-MDL-score release when multiple candidates are queued (maximize
  functional capability delta per unit of deployment risk)
- verify canary_count_at_dispatch ≤ 5; queue if limit is reached
- emit `DeploymentRecord` with bitemporal fields and confidence tier
- hand admission request to runtime

### Audit-time

Allowed work:

- replay release decision from durable records
- replay deployment decision from durable records
- verify revocation coverage
- query deployment state at any prior point-in-time using `BitemporalDeploymentRecord`
  valid-time and transaction-time axes
- inspect L0 (raw metrics) and L1 (service health) observability layers; L2–L4
  layers (feature rollout state, release-version summary, cross-service dependency
  graph) are reserved for post-v1
- verify `deployment_ledger_hash` integrity against the sealed five-stage chain

### Incident-time

Allowed work:

- trigger circuit breakers
- enter degraded or rollback-only mode
- revoke release or dependency
- perform rollback to a prior admitted release

## Negative States

These states are distinct and must not be collapsed:

- `invalid`
  - the release envelope or manifest is malformed, incomplete, or internally
    inconsistent
- `unverifiable`
  - required digests, signatures, attestations, or environment facts cannot be
    verified
- `untrusted`
  - verification completed, but signer, attestor, or trust chain is not allowed
- `policy-blocked`
  - the artifact is trusted but denied by the selected `PolicySnapshot`
- `revoked`
  - the envelope, signer, or a locked dependency is explicitly revoked
- `superseded`
  - the artifact remains valid but is no longer eligible for forward deployment
    because a later approved release replaced it
- `degraded`
  - Aegis is operating in safe mode because required control-plane functions are
    impaired
- `rollback-only`
  - the target environment is frozen for forward deployment; only rollback to a
    prior admitted release is allowed
- `confidence-blocked`
  - the `ReleaseConfidenceVector` failed to reach `PREPONDERANCE` tier, or
    conflict mass K > 0.5 triggered Yager normalization; promotion is blocked
    until the conflicting gate checks are resolved
- `tolerance-blocked`
  - the source tolerance gate fired `AUTOIMMUNE_FAILURE` due to policy surface
    collision rate exceeding 5%; the capsule class is blocked until the policy
    conflict is resolved
- `tolerance-review-pending`
  - the schema overlap check flagged the capsule as a potential near-duplicate;
    forward deployment continues at `REASONABLE_SUSPICION` tier (5% canary traffic
    only) until the review is resolved; this prevents full blocking for legitimate
    companion capsules that share capability vocabulary by design

These states are part of the public contract.

## Evolution Boundaries

### Mutable in v1

The following may change through explicit human action:

- payload bytes before packaging
- manifest contents before signing
- dependency lock before signing
- policy snapshot set
- environment profile definitions
- release promotion decisions
- revocation decisions

### Frozen in v1

The following are frozen once a release is promoted:

- `ReleaseEnvelope` bytes
- digests
- manifest contents
- compatibility class
- attestation set
- public result-state names
- rollback semantics
- revocation semantics

Nothing in v1 may self-modify after promotion.

## Degraded Mode

The degraded mode rules are mandatory:

### If policy engine is unavailable

- enter `degraded`
- block all new forward deployments
- allow manual rollback only if the prior release, policy snapshot, and
  environment profile are locally cached

### If attestation service is unavailable

- packaging may continue
- promotion and forward deployment are blocked until valid attestation exists
- previously attested releases remain usable if signatures can still be verified

### If signature verification is partial

- treat the release as `unverifiable`
- block promotion and forward deployment
- allow rollback only to a locally present, previously verified release

### If environment metadata is stale

- enter `degraded`
- block forward deployment
- allow rollback only if the cached environment profile exactly matches the last
  admitted release's profile id

### If rollback target is missing

- do not mutate the current deployment
- emit a rollback failure reason
- keep the environment in `rollback-only` or `degraded` until a valid target is
  available

## Kill Criteria

The v1 architecture fails if any of the following are true after the first
serious prototype:

- release-to-admission latency is more than 2x a simpler manual mounting path
  without materially better trust guarantees
- operators cannot deterministically prove what was deployed, under which policy,
  and into which environment from durable records alone
- rollback is not reliable without rebuilding old artifacts
- revocation does not block future admissions deterministically
- the portability benefit is negligible because artifacts remain tightly bound to
  one unreproducible local machine state
- the `ReleaseConfidenceVector` consistently produces conflict mass K > 0.5
  across all gate configurations, indicating the policy set is structurally
  contradictory and the confidence model cannot converge
- the canary hard ceiling (five concurrent experiments) cannot be enforced,
  causing concurrent canary signal attribution to become unreliable

## Explicit Deferrals

The following are intentionally deferred:

- multi-environment promotion waves
- federation across trust domains
- autonomous release approval
- dynamic policy synthesis
- cross-tenant trust exchange
- artifact self-modification after promotion
- runtime learning feedback loops
- generalized package marketplace features
- support for multiple compatibility classes
- automatic hot-stop of running deployments on revoke unless explicitly required
  by the environment profile
- `BehavioralCertificate` issuance and bisimulation checking at the promotion gate
  (v1 stub schema only; `behavioral_certificate_status: "deferred"` in manifest)
- L2–L4 observability layers (feature rollout state, release-version summary,
  cross-service dependency graph)
- full Dempster-Shafer BPA combination for `ReleaseConfidenceVector` (v1 may use
  simplified weighted threshold gates as an initial implementation)
- MDL promotion scheduling with full information-theoretic scoring (v1 uses simple
  blast-radius heuristics only)

## Authoring Contract

To produce a valid v1 release envelope, a human must provide exactly:

- capsule payload
- `ReleaseManifest`
- explicit dependency declarations
- compatibility class declaration
- declared capability surface
- policy class
- runtime constraints
- rollback compatibility statement

The manifest must include at least:

- capsule identity
- semantic version
- payload entrypoint
- declared tools, prompts, resources, and templates
- dependency lock root
- required host capabilities
- trust zone expectation
- maximum privilege needed
- `behavioral_certificate_status` (v1: `"deferred"`; post-v1: SHA256 of LTS encoding
  stored in `behavioral_certificate_hash`)

Everything else is optional and must not be required for a valid v1 artifact.

## What Is Declared vs Validated vs Trusted

### Declared

The manifest declares:

- intended capability surface
- intended dependencies
- intended compatibility class
- intended runtime constraints

### Validated

Validation proves only:

- schema correctness
- digest consistency
- dependency lock completeness
- compatibility with the selected environment profile
- policy admissibility
- attestation presence and signature validity

### Trusted

Trust applies only to:

- exact release envelope bytes
- embedded manifest and dependency lock
- embedded attestation set
- selected policy snapshot
- selected environment profile

The internal cognition quality of the capsule is not trusted by AI Provenance Spec in
v1. It is outside the release substrate's trust claim.

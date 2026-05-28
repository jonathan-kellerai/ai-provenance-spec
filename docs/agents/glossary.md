# Glossary

Tier-2 reference — the load-bearing vocabulary of the AI Provenance Spec v1
specification, sourced from the constitution, `docs/project-context/`, and
`docs/specs/`. Do not invent terms, and do not redefine those listed here.

## Kernel objects

The five canonical deployable-unit primitives:

- **`ReleaseEnvelope`** — the immutable, signed unit of deployable cognition:
  capsule payload, `ReleaseManifest`, dependency lock, declared compatibility
  class, and attestation set. Release identity is derived from envelope bytes,
  not assigned by a registry. Once promoted, it is frozen.
- **`PolicySnapshot`** — the exact, versioned policy bundle a release was
  evaluated against. A trust decision always names the exact snapshot id.
- **`EnvironmentProfile`** — the versioned declaration of a deployment target:
  trust zone, trust anchors, accepted compatibility classes, runtime
  constraints, and revocation behaviour.
- **`DeploymentRecord`** — the per-deployment evidence object: which envelope,
  against which policy, into which environment, by whom, and when.
- **`DeploymentLedger`** — the append-only, tamper-evident chain of deployment
  records. Its terminal `ledger_hash` is the only value a downstream verifier
  must consult to admit, reject, or revoke a deployment.

The constitution's full canonical set is **nine objects** — the five above plus
the four derived objects below.

## Derived durable objects

- **`ReleaseRecord`** — the control-plane decision that a specific release
  envelope is packaged, validated, attested, and either promoted or refused.
- **`RevocationRecord`** — the explicit, durable block on a release envelope
  digest, a signer, or a dependency digest.
- **`ReleaseConfidenceVector`** — replaces a boolean policy verdict with a
  graduated promotion confidence (see *The confidence model*). It travels with
  the `ReleaseRecord`.
- **`BitemporalDeploymentRecord`** — a `DeploymentRecord` carrying two
  independent time axes: valid-time (when the deployment was actually live) and
  transaction-time (when AI Provenance Spec recorded the event).
- **`ReleaseAuditRecord`** — a tenth durable object required by
  [`v1-scope.md`](../project-context/v1-scope.md); the constitution records it as
  pending incorporation into the canonical list via amendment. It enforces the
  canary hard ceiling — a `canary_count > 5` is non-conformant.

## The confidence model (Dempster-Shafer)

- **BPA** — *basic probability assignment*. Each release gate emits a BPA over
  the frame `{Safe, ¬Safe}`. Gate BPAs are combined via Dempster's rule.
- **`[Bel, Pl]`** — the *belief / plausibility* interval on `Safe` derived from
  the combined BPA. It expresses graduated confidence, not a boolean verdict.
- **Conflict mass K** — the probability mass assigned to outright contradiction
  between combined BPAs. When `K > 0.5`, the gates disagree severely.
- **Yager normalization** — the normalization applied when `K > 0.5`; promotion
  is blocked rather than allowed to show paradoxically high combined confidence.
- **`ConflictStatus`** — a sub-structure of `ReleaseConfidenceVector` (not a
  standalone durable object) with `conflict_type`, `conflict_degree`, and
  `extension_count`. Promotion eligibility depends on the extension count.

## Promotion tiers and roles

The **three-tier promotion gate**, with tier names borrowed from legal
epistemology to make the promotion stance auditable in human terms:

- **`REASONABLE_SUSPICION`** — `Bel(Safe) ≥ 0.40`: 5% canary traffic, monitor.
- **`PREPONDERANCE`** — `Bel(Safe) ≥ 0.65`: staged rollout to 50%.
- **`BEYOND_REASONABLE_DOUBT`** — `Bel(Safe) ≥ 0.85` and `extension_count == 0`:
  full promotion to 100%.

The **six roles**, whose rights must remain separate by architectural mandate:
**Artifact Author** (payload, manifest, declared dependencies, rollback
compatibility statement); **Policy Authority** (policy classes, snapshots, trust
rules, deny rules); **Release Authority** (promotion approval of an attested
envelope); **Environment Owner** (the `EnvironmentProfile`, trust zone, runtime
constraints, admission configuration); **Incident Owner** (circuit-breaker
trips, forced rollback-only or degraded mode); **Revocation Authority**
(revoking envelopes, signers, or locked dependencies).

## Operational planes and modes

- **Control plane** — where artifact creation, validation, attestation,
  promotion, and revocation-record writing occur.
- **Hot path** — admission only: fetch a release by id, verify signature and
  attestation, evaluate the named `PolicySnapshot` against the named
  `EnvironmentProfile`, and emit a `DeploymentRecord`. Rebuilding, dependency
  solving, and policy synthesis are **forbidden** on the hot path.
- **Boring Mode** — the mandatory fail-closed degraded mode: manual rollback and
  cached-snapshot evaluation are allowed; new attestation, new publication, and
  automatic promotion are forbidden.

## Negative states

A blocked deployment must emit exactly one of **eleven negative states**:
`invalid`, `unverifiable`, `untrusted`, `policy-blocked`, `revoked`,
`superseded`, `degraded`, `rollback-only`, `confidence-blocked`,
`tolerance-blocked`, and `tolerance-review-pending`. Each is defined in
[`v1-scope.md`](../project-context/v1-scope.md).

## Admission gates

- **Source Tolerance Gate** — a three-phase admission screen modelled on
  thymic selection: (1) *schema overlap* — flag near-duplicate capsules for
  review; (2) *autoreactive check* — a policy-collision rate above 5% trips the
  `AUTOIMMUNE_FAILURE` circuit breaker; (3) *burn-in* — the first ten
  invocations run at 70% trust weight before a full grant.
- **Kill Criteria** — the seven conditions in
  [`v1-scope.md`](../project-context/v1-scope.md) under which the v1
  architecture is judged a failure (for example: operators cannot
  deterministically prove what was deployed; rollback is not reliable without
  rebuilding old artifacts; the canary hard ceiling cannot be enforced). This
  repo uses the term *kill criteria*. Distinct from *circuit breakers* such as
  `AUTOIMMUNE_FAILURE`, which are runtime trips an Incident Owner can fire.

## Binding invariants

- **Invariant 11** — "No trust decision may depend on mutable ambient state that
  is not recorded in the deployment record."
- **Invariant 15** — "No more than five concurrent canary experiments may be
  active across one target environment at any time. A sixth release must queue
  until one canary concludes with explicit promote or rollback."

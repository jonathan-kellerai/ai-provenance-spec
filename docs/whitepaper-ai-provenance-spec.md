# AI Provenance Spec: Trusted Release Substrate for Portable Cognition Capsules

**A specification-first governance architecture for the release, attestation, and admission of AI skill artifacts.**

---

- **Version:** 1.0
- **Date:** May 2026
- **Author:** Jonathan A. Bowe, 2026
- **Classification:** Technical White Paper
- **Companion Repository:** `grounded-rag-spec`
- **License:** Apache-2.0

---

## Abstract

This paper presents AI Provenance Spec, a specification-first release substrate for portable cognition capsules — AI skill units that combine retrieval, planning, and local model components behind thin outer interfaces.
The key innovation is the formal enforcement of four distinctions that conventional plugin and packaging systems blur: buildable versus deployable, declared versus validated, recorded versus trusted, and rolled back versus revoked.
AI Provenance Spec instantiates these distinctions through five kernel objects, a fifteen-clause constitution, a five-stage tamper-evident hash chain (the `DeploymentLedger`), and a Dempster-Shafer release-confidence model that replaces boolean policy verdicts with graduated promotion tiers borrowed from legal epistemology.
Governance is externalized to Open Policy Agent (OPA) with Rego policies (ADR-003, the "Chimera Plan"), preserving auditability and testability outside the runtime.
The architecture imposes a strict separation between a control plane (creation, validation, attestation, promotion, revocation) and a hot path (fetch, verify, evaluate, admit), forbidding policy synthesis or dependency resolution on the deployment path.
The v1 reference implementation is deliberately deferred; the binding artifacts are the constitution, the ADR log, and the narrowest falsifiable v1 scope.
AI Provenance Spec contributes a research-grounded vocabulary and a set of architectural primitives to the open-source community for AI skill deployment pipelines that must operate under real consequence.

---

## 1. Introduction

AI artifact deployment lacks a formal trust substrate.
Current plugin and skill systems were designed for static software artifacts and are silently extended to cover capsules whose internal organs — retrieval indices, small language models, planners, rerankers — exhibit non-trivial dependency, policy, and behavioral surfaces.
The result is a tooling stratum that conflates buildability with deployability, declared capability with validated capability, recorded events with trusted events, and rollback with revocation.
A team operating an AI skill in production cannot, in general, answer the question "what happens now?" under failure, because the system has no vocabulary for the eleven distinct negative states that arise: `invalid`, `unverifiable`, `untrusted`, `policy-blocked`, `revoked`, `superseded`, `degraded`, `rollback-only`, `confidence-blocked`, `tolerance-blocked`, and `tolerance-review-pending` (v1-scope.md).

AI Provenance Spec addresses this gap with a specification-first substrate.
The project is binding at the level of architecture documents — constitution, ADR log, v1 scope — and explicitly defers reference implementation.
This stance is not a limitation but a contribution: it allows the governance model to be evaluated, criticized, and adopted as reference architecture before any team commits to building against it.

### 1.1 Contributions

This paper makes the following contributions:

1. A five-object **kernel ontology** (`ReleaseEnvelope`, `PolicySnapshot`, `EnvironmentProfile`, `DeploymentRecord`, `DeploymentLedger`) that gives names and formal definitions to the architectural primitives required for trusted AI skill deployment.
2. A **five-stage hash chain** (`DeploymentLedger`) that binds source commit, build artifact, policy check, canary result, and promotion timestamp into a single tamper-evident terminal digest.
3. A **Dempster-Shafer release-confidence model** with a three-tier promotion gate, replacing boolean policy verdicts with belief-plausibility intervals and graduated commitment levels (`REASONABLE_SUSPICION`, `PREPONDERANCE`, `BEYOND_REASONABLE_DOUBT`).
4. A **fifteen-clause constitution** whose invariant 11 — "no trust decision may depend on mutable ambient state that is not recorded in the deployment record" — is the load-bearing constraint the entire architecture is constructed to enforce.
5. An **externalized governance model** (ADR-003, the "Chimera Plan") delegating policy decisions to OPA/Rego, with an illustrative `spec_validation.rego` policy and test bundle.
6. A **hot-swap operational spec** demonstrating the constitution applied to a concrete deployment scenario, with an explicit empirical prerequisite (Gate Zero) that gates the entire benefit claim.
7. A **named-future-primitives** register that exposes the architecture's research roadmap (`BehavioralCertificate`, `ZKBehavioralProof`, `SessionTypedProtocol`, and seven others) without encumbering v1 with their absence.

### 1.2 Organization

Section 2 enumerates the contributions in detail.
Section 3 presents the two-plane architecture and the five kernel objects with formal definitions.
Section 4 specifies the `DeploymentLedger` hash chain and compares it to SLSA and in-toto.
Section 5 develops the release-confidence model.
Section 6 describes the OPA/Rego governance plane.
Section 7 presents the hot-swap operational spec.
Section 8 surveys related work.
Section 9 enumerates open problems.
Section 10 concludes.

---

## 2. Contributions

The specific contributions of AI Provenance Spec to the AI and open-source communities are:

- **A formal vocabulary for cognition-capsule release.** Five kernel objects and nine durable objects, each with a defined contract, replace ad hoc naming conventions inherited from static-software packaging.
- **A binding constitution.** Fifteen invariants protected from PR-level change (CONTRIBUTING.md), amendable only through ADR with named approval from Policy, Release, and Environment authorities.
- **A tamper-evident deployment chain.** The five-stage `DeploymentLedger` extends SLSA-style provenance with explicit policy-check and canary-result stages and a terminal `ledger_hash` that is the sole admission token a downstream verifier must consult.
- **Probabilistic release confidence.** The `ReleaseConfidenceVector` combines gate basic probability assignments via Dempster's combination rule into a `[Bel, Pl]` interval on the `Safe` hypothesis, with Yager normalization when conflict mass exceeds 0.5.
- **Argumentation-theoretic conflict semantics.** The `ConflictStatus` record exposes `conflict_type` (rebutting vs. undercutting), `conflict_degree`, and `extension_count`, drawing on Dung's framework to give policy conflict a structured representation.
- **Externalized, testable governance.** OPA/Rego policies are auditable and runnable outside the runtime, with `spec_validation.rego` providing a worked example and a 16-case test bundle.
- **A progressive disclosure tier model (T1–T4).** Skill content is loaded on demand, with a per-skill baseline cost of approximately 80 tokens against full payloads that may reach 100K+ tokens.
- **An immunological admission metaphor with engineering content.** The Source Tolerance Gate borrows positive selection, negative selection, and burn-in directly from mammalian thymic biology, instantiated as schema overlap, autoreactive collision, and ten-call weighting.
- **A canary hard ceiling.** Invariant 15 caps concurrent canaries per environment at five, grounded in Miller's Law and the attributability limit of simultaneous experiments.
- **A boring-mode degraded operational stance.** A mandatory fail-closed mode that allows manual rollback and cached-snapshot evaluation but forbids new attestation, new publication, and automatic promotion.
- **An explicit role separation.** Six roles (Artifact Author, Policy Authority, Release Authority, Environment Owner, Incident Owner, Revocation Authority) whose rights remain separate by architectural mandate.
- **A public contract with four named parties.** Each party (capsule author, deployer, environment owner, downstream verifier) receives explicit written guarantees.

---

## 3. Architecture

### 3.1 Two Planes

AI Provenance Spec decomposes into a control plane and a hot path with a strict prohibition on cross-plane bleed.

```text
┌────────────────────────────────┐     ┌────────────────────────────────┐
│       CONTROL PLANE            │     │          HOT PATH              │
│  (creation, validation,        │     │   (fetch by id, verify sig,    │
│   attestation, promotion,      │────▶│    evaluate policy snapshot,   │
│   revocation record writing)   │     │    emit DeploymentRecord)      │
└────────────────────────────────┘     └────────────────────────────────┘
        no hot-path activity                no rebuilding, no solving,
        permitted here                       no policy synthesis here
```

The control plane is where artifact creation, validation, attestation, promotion, and revocation record writing occur.
The hot path performs only: fetch release by id, verify signature and attestation, evaluate the named `PolicySnapshot` against the named `EnvironmentProfile`, emit a `DeploymentRecord`, and hand the runtime the exact release reference.
Rebuilding, dependency solving, and policy synthesis are forbidden on the hot path.
The target runtime for v1 is a single compatibility class, `archangel.local.v1` (constitution.md §Compatibility).

### 3.2 The Five Kernel Objects

The README identifies five canonical kernel objects as the conceptual core of the system.
The full v1 durable object set is nine; the additional four (`ReleaseRecord`, `RevocationRecord`, `ReleaseConfidenceVector`, `BitemporalDeploymentRecord`, `ReleaseAuditRecord`) are derived from or extend the core five.

#### 3.2.1 ReleaseEnvelope

The `ReleaseEnvelope` is the immutable, signed unit of deployable cognition.
Everything else in the system is either an input to producing an envelope or a record of what happened to one.

Formally, an envelope $E$ is a tuple:

$$E = \langle P, M, L, C, A \rangle$$

where $P$ is the capsule payload, $M$ is the `ReleaseManifest`, $L$ is the dependency lock, $C$ is the declared compatibility class, and $A$ is the attestation set bound to the envelope digest.
Release identity is derived deterministically from envelope bytes:

$$\text{release\_id}(E) = H(\text{canonical\_serialize}(E))$$

It is not assigned by a mutable registry.
Once promoted, the envelope is frozen (constitution.md §Core Invariants 2, 3).

#### 3.2.2 PolicySnapshot

A `PolicySnapshot` is the exact, versioned policy bundle evaluated when deciding releasability and deployability.

$$S = \langle \text{snapshot\_id}, \pi_{\text{class}}, \rho_{\text{deny}}, \rho_{\text{auth}}, \rho_{\text{degraded}} \rangle$$

A trust decision always names the exact snapshot id $S.\text{snapshot\_id}$; it never floats against a live mutable policy set (constitution.md §Core Invariant 5).

#### 3.2.3 EnvironmentProfile

An `EnvironmentProfile` is the versioned declaration of a deployment target's trust zone, compatibility rules, runtime constraints, and local trust anchors.

$$F = \langle \text{env\_id}, Z, T, \mathcal{C}, K, b_{\text{revoke}} \rangle$$

where $Z$ is the trust zone, $T$ is the set of trust anchors, $\mathcal{C}$ is the set of accepted compatibility classes, $K$ is the runtime constraint set, and $b_{\text{revoke}}$ is the hard-stop-on-revoke behavior flag.
Deployability is never universal; it is always relative to a specific $F$.

#### 3.2.4 DeploymentRecord

A `DeploymentRecord` is the per-deployment evidence object recording one admission event.
The v1 success contract requires the following fields:

```text
deployment_id              policy_snapshot_id
release_id                 environment_profile_id
surface_digest             actor
admission_time             valid_from_deploy
valid_until_deploy         tx_ingested
deployment_confidence_tier canary_count_at_promotion
```

A bitemporal extension (`BitemporalDeploymentRecord`) carries two independent time axes: valid-time (when the deployment was actually live) and transaction-time (when Aegis recorded the event).

#### 3.2.5 DeploymentLedger

The `DeploymentLedger` is the append-only, tamper-evident chain of deployment records.
It seals the five-stage pipeline from source commit through promotion timestamp; any modification to any stage produces a different terminal `ledger_hash` and renders the release non-promotable.
Section 4 develops its algorithmic content.

### 3.3 Role Separation

Six roles whose rights must remain separate by architectural mandate:

| Role | Owns |
|---|---|
| Artifact Author | Payload, manifest, declared dependencies, rollback compatibility statement |
| Policy Authority | Policy classes, policy snapshots, trust rules, deny rules |
| Release Authority | Promotion approval of an attested envelope |
| Environment Owner | `EnvironmentProfile`, trust zone, runtime constraints, admission config |
| Incident Owner | Circuit breaker trips, forced rollback-only or degraded mode |
| Revocation Authority | Revocation of envelopes, signers, or locked dependencies |

---

## 4. The DeploymentLedger Hash Chain

### 4.1 Problem

A deployment record is trustworthy only if it is tamper-evident with respect to every condition that materially affected the promotion decision.
SLSA-style provenance covers source-to-build but is silent on policy evaluation and canary outcome.
in-toto provides a step-by-step custody framework but does not prescribe which stages to chain for AI skill release.

### 4.2 Algorithm

The five-stage chain binds the release to the exact conditions under which it was promoted:

```text
source_commit_hash
  → build_artifact_hash
  → policy_check_hash
  → canary_result_hash
  → promotion_timestamp_hash
  → ledger_hash
```

Formally, with $h_i$ the digest produced at stage $i$:

$$h_0 = H(\text{source\_commit})$$

$$h_i = H(h_{i-1} \,\|\, \text{stage\_payload}_i), \quad i \in \{1, 2, 3, 4\}$$

$$\text{ledger\_hash} = h_4$$

The terminal `ledger_hash` is the only value a downstream verifier must consult to admit, reject, or revoke a deployment, and to prove afterward which release ran, under which policy snapshot, against which environment profile, with which canary outcome, at which moment.

### 4.3 Properties

- **Tamper evidence.** Any modification to any stage payload changes `ledger_hash`.
- **Single-token verification.** Downstream verifiers consult one digest rather than reconstructing the chain.
- **Non-promotability under modification.** A release whose recomputed chain disagrees with its recorded `ledger_hash` is not admissible.
- **Invariant 11 compliance.** Because the chain explicitly includes `policy_check_hash` and `canary_result_hash`, no trust decision can depend on mutable ambient policy or canary state that is not recorded.

### 4.4 Comparison to SLSA and in-toto

| Property | SLSA L3 | in-toto | DeploymentLedger |
|---|---|---|---|
| Source-to-build provenance | Yes | Yes | Yes (`source_commit_hash` → `build_artifact_hash`) |
| Step-by-step custody | Partial | Yes | Yes (five named stages) |
| Policy evaluation stage | No | No | Yes (`policy_check_hash`) |
| Canary outcome stage | No | No | Yes (`canary_result_hash`) |
| Terminal single-token verification | No | No | Yes (`ledger_hash`) |
| AI-skill specific | No | No | Yes |

---

## 5. The Release Confidence Model

### 5.1 Beyond Boolean Verdicts

Conventional CI/CD treats policy outcomes as boolean pass or fail.
This is insufficient for AI skill release, where evidence is partial, gates disagree, and the cost of premature full promotion is high.
AI Provenance Spec replaces the boolean verdict with a `ReleaseConfidenceVector` grounded in Dempster-Shafer evidence theory and a `ConflictStatus` record grounded in Dung's argumentation framework.

### 5.2 ConflictStatus

A `ConflictStatus` is a record with three fields:

- `conflict_type`: `rebutting` (direct contradiction) or `undercutting` (defeats inferential warrant)
- `conflict_degree`: normalized magnitude in $[0, 1]$
- `extension_count`: number of distinct consistent policy extensions admissible

Extension count semantics determine promotion eligibility:

| `extension_count` | `conflict_degree` | Outcome |
|---|---|---|
| > 1 | any | Ambiguous policy space; release blocked |
| = 1 | any | Single consistent resolution; promotion may proceed |
| = 0 | 0 | Clean state; required for full promotion |
| = 0 | > 0 | Genuine deadlock; blocked; escalate |

### 5.3 ReleaseConfidenceVector

Each gate emits a basic probability assignment (BPA) over the frame $\Theta = \{\text{Safe}, \neg\text{Safe}\}$.
Gate BPAs are combined via Dempster's rule:

$$(m_1 \oplus m_2)(A) = \frac{1}{1 - K} \sum_{B \cap C = A} m_1(B) \, m_2(C), \quad A \neq \emptyset$$

$$K = \sum_{B \cap C = \emptyset} m_1(B) \, m_2(C)$$

The combined BPA yields a belief-plausibility interval on `Safe`:

$$\text{Bel}(\text{Safe}) = \sum_{B \subseteq \{\text{Safe}\}} m(B), \quad \text{Pl}(\text{Safe}) = \sum_{B \cap \{\text{Safe}\} \neq \emptyset} m(B)$$

When conflict mass $K > 0.5$, Yager normalization applies and promotion is blocked.

### 5.4 Three-Tier Promotion Gate

```text
+----------------------------+-----------------------------+----------------------------+
| Tier                       | Threshold                   | Action                     |
+----------------------------+-----------------------------+----------------------------+
| REASONABLE_SUSPICION       | Bel(Safe) >= 0.40           | 5% canary traffic, monitor |
| PREPONDERANCE              | Bel(Safe) >= 0.65           | Staged rollout to 50%      |
| BEYOND_REASONABLE_DOUBT    | Bel(Safe) >= 0.85 and       | Full promotion to 100%     |
|                            | extension_count == 0        |                            |
+----------------------------+-----------------------------+----------------------------+
```

Tier names are borrowed deliberately from legal epistemology to signal graduated commitment levels and to make the promotion stance auditable in human terms.

### 5.5 Source Tolerance Gate

A three-phase admission screen modeled on mammalian thymic selection:

1. **Positive selection (schema overlap).** Near-duplicates flagged for review.
2. **Negative selection (autoreactive check).** Collision rate above 5% trips the `AUTOIMMUNE_FAILURE` circuit breaker.
3. **Burn-in.** First ten invocations execute at 70% trust weight; full weight after ten successful calls.

### 5.6 MDL Promotion Scheduling

Where multiple releases contend for promotion, scheduling prefers releases that maximize functional capability gain per unit of deployment risk.
A release changing three files providing equivalent capability to one changing thirty files is promoted first.
The principle is Rissanen's minimum description length: the shorter description that explains the same observed capability is preferred.

---

## 6. Governance via OPA/Rego

### 6.1 ADR-003: The Chimera Plan

ADR-003 (2026-03-26) commits AI Provenance Spec to OPA with Rego policies for all governance decisions.
The motivation is threefold: policy decisions become auditable as evaluated artifacts; they become portable across runtimes; and they become testable outside the host system.
All skill admission decisions are evaluated against OPA policies before the Admission Gate permits execution.

### 6.2 spec_validation.rego Walkthrough

The illustrative policy at `docs/governance/policies/spec_validation.rego` validates issue objects destined for `bd create --file` ingestion.
The package is `release.spec.validation` and the structure is a deny-rule accumulator with ten validation rules:

> **Note:** Examples use Rego v1 syntax (OPA 1.x).

```rego
package release.spec.validation

# R1: title required, non-empty
deny contains msg if {
    not input.title
    msg := "title is required"
}

# R3: type must be in the accepted set
deny contains msg if {
    not valid_types[input.type]
    msg := sprintf("type %q is not in the accepted set", [input.type])
}
valid_types := {"bug", "feature", "task", "epic", "chore", "decision"}
```

The full rule set covers `title`, `description` length, `type`, `priority`, `deps` shape, `labels` shape, `estimate` positivity, `due` and `defer` date patterns, `mol_type`, and `waits_for_gate`.
A companion test file provides sixteen named cases.

### 6.3 Externalization Properties

Because the policy is a Rego module:

- It can be evaluated against `bd` payloads without a running runtime.
- It can be diffed across versions and pinned by snapshot id into a `PolicySnapshot`.
- It can be unit-tested by policy authors independently of artifact authors.
- It can be amended without redeploying the host runtime.

---

## 7. The Hot-Swap Operational Spec

### 7.1 Problem

Claude Code sessions that pre-load all installed plugin skills at session start consume 15,000–40,000 tokens before the user types a single message.
The hot-swap v1 spec is the first concrete operational spec demonstrating the constitution applied to a real deployment scenario.

### 7.2 Two Benefits

1. **Lean session start.** No skill content is pre-loaded; payloads are fetched on first need.
2. **Tool surface discipline.** Only active skills' MCP tools are visible per API call.

The spec is explicit that `unload_skill` frees tool surface tokens only, not history content.
This is communicated as a hard architectural limit rather than a future optimization.

### 7.3 Gate Zero

Gate Zero is a mandatory empirical prerequisite: the implementer must verify that calling `gateway_session_surface_apply` mid-session causes the Claude Code client to re-issue a `tools/list` request.
If Gate Zero fails, the entire tool surface discipline benefit does not exist.
The spec is binding on this point: no implementation may claim hot-swap correctness without a passing Gate Zero observation.

### 7.4 LoadedSkillManifest

The runtime data structure tracks state required for hot-swap correctness:

```text
LoadedSkillManifest {
    base_surface       : SurfaceDigest
    tools_contributed  : Map<SkillId, Set<ToolName>>
    loaded_at          : Map<SkillId, Timestamp>
    last_tool_call     : Map<SkillId, Timestamp>   # for LRU eviction
}
```

### 7.5 Progressive Disclosure Tiers (ADR-004)

Skill content is organized into four tiers loaded on demand:

| Tier | Contents | Loaded When |
|---|---|---|
| T4 | Governance (OPA/Rego policies) | Admission gate evaluation |
| T3 | Workflows (operational sequences) | Execution planning |
| T2.5 | Recovery (rollback, error handling) | Failure path activation |
| T2 | Tools (executable tool definitions) | Invocation |
| T1 | Skin (description, ~80 tokens) | Always loaded for discoverability |

Baseline context cost per skill is approximately 80 tokens against full payloads that may reach 100K+ tokens.

---

## 8. Related Work

AI Provenance Spec's named antecedents and their architectural contributions:

- **SLSA** [1] — provenance and pinned-input thinking shaped the `ReleaseEnvelope` trust boundary.
- **in-toto** [2] — step-by-step chain of custody shaped the `DeploymentLedger` design.
- **Dung's argumentation framework** [3] — conflict type and extension counts shaped `ConflictStatus`.
- **Dempster-Shafer evidence theory** [4] — BPA combination and conflict mass $K$ shaped `ReleaseConfidenceVector`.
- **Snodgrass and Jensen bitemporal theory** [5] — two independent time axes shaped `BitemporalDeploymentRecord`.
- **Datomic immutable bitemporal fact model** [6] — as-of queries without reconstruction.
- **Miller's Law** [7] — cognitive capacity bound justified the five-concurrent-canary ceiling (invariant 15).
- **Kolmogorov complexity and Rissanen MDL** [8] — MDL promotion scheduling.
- **Mammalian thymic selection and Matzinger's danger model** [9, 10] — the three-phase Source Tolerance Gate.
- **MCP lifecycle and sampling model** [11] — shaped host-mediated runtime admission.
- **Capability-security reasoning** [12] — explicit scoped authority shaped the six-role separation.

AI Provenance Spec's contribution relative to this body is integrative: it composes provenance from SLSA and in-toto with epistemic gating from Dempster-Shafer and Dung, immunological admission from thymic biology, and bitemporal accounting from Snodgrass-Jensen, into a single governance substrate specific to AI skill release.

---

## 9. Open Problems

The project is honest about what is deferred.

1. **Gate Zero is unresolved.** Whether `gateway_session_surface_apply` causes Claude Code to re-issue `tools/list` mid-session is unverified.
   This is the highest-priority open question for any implementer; without a passing observation, the hot-swap tool surface discipline benefit does not exist.
2. **No production admission Rego policy exists.** `spec_validation.rego` is illustrative.
   Actual deployment-time Rego policies are planned (ADR-003) but unwritten.
3. **The v1 implementation does not exist.** The specification is binding.
   There is no reference implementation, SDK, or CLI.
4. **`BehavioralCertificate` and bisimulation checking are deferred indefinitely.** No toolchain has been identified.
5. **ArchangelMCP is a hard runtime dependency.** Teams outside the originating ecosystem would need to implement a compatible gateway surface.
6. **The Grounded RAG spec relationship is asymmetric and incomplete.** The companion repository is not yet live.
   The exact interface between AI Provenance Spec (deployment substrate) and Grounded RAG (concrete capsule: RAG plus two SLMs in a skill shell) is not detailed.
7. **Kill criteria are specified but unmeasured.** `v1-scope.md` lists seven kill criteria; no measurement framework is defined.

These are stated as work, not weaknesses.
A specification-first project must publish its open ends.

---

## 10. Conclusion

AI Provenance Spec offers the open-source community a governance substrate for AI skill deployment built on four architectural distinctions that conventional tooling blurs.
The five kernel objects, the fifteen-clause constitution, the five-stage `DeploymentLedger` hash chain, the Dempster-Shafer release-confidence model, and the externalized OPA/Rego governance plane compose into a coherent answer to the question conventional plugin systems cannot answer: "what happens now?" when an AI capsule is running live and something goes wrong.

The decision to defer implementation is itself a contribution.
A binding specification that can be read, criticized, and adopted as reference architecture is more useful at this stage than a prematurely shipped runtime that ossifies the wrong choices.
AI Provenance Spec's named future primitives — `BehavioralCertificate`, `ZKBehavioralProof`, `SessionTypedProtocol`, and the others — declare a research roadmap that the v1 architecture is explicitly designed not to obstruct.

Future work consists of resolving Gate Zero, authoring production admission policies, defining a measurement framework for the kill criteria, and bringing the companion `grounded-rag-spec` repository live so that AI Provenance Spec's release model can be exercised against a concrete cognition capsule.
The trust substrate AI skill deployment has lacked is now specified; the work ahead is to build against it.

---

## References

1. SLSA (Supply-chain Levels for Software Artifacts). Open Source Security Foundation.
2. Torres-Arias, S., Afzali, H., Kuppusamy, T. K., Curtmola, R., and Cappos, J. *in-toto: Providing farm-to-table guarantees for bits and bytes.* USENIX Security, 2019.
3. Dung, P. M. *On the acceptability of arguments and its fundamental role in nonmonotonic reasoning, logic programming and n-person games.* Artificial Intelligence, 1995.
4. Shafer, G. *A Mathematical Theory of Evidence.* Princeton University Press, 1976.
5. Snodgrass, R. T., and Jensen, C. S. *Temporal database management.* IEEE Computer Society, 1999.
6. Hickey, R. *Datomic: A database for the new world.* Cognitect, 2012.
7. Miller, G. A. *The magical number seven, plus or minus two: Some limits on our capacity for processing information.* Psychological Review, 1956.
8. Rissanen, J. *Modeling by shortest data description.* Automatica, 1978.
9. Starr, T. K., Jameson, S. C., and Hogquist, K. A. *Positive and negative selection of T cells.* Annual Review of Immunology, 2003.
10. Matzinger, P. *The danger model: A renewed sense of self.* Science, 2002.
11. Model Context Protocol Specification. Anthropic, 2025.
12. Miller, M. S. *Robust Composition: Towards a Unified Approach to Access Control and Concurrency Control.* PhD thesis, Johns Hopkins University, 2006.

---

## Appendix A: The Fifteen Constitution Invariants

Cited verbatim from `docs/governance/constitution.md` §Core Invariants.

1. No deployable artifact exists without a machine-readable manifest.
2. No deployable artifact exists without immutable artifact bytes and stable digests, a stable capsule identity binding, and a declared behavioral boundary.
3. No attestation is valid unless it binds to pinned inputs and exact artifact digests.
4. No release is deployable without successful attestation.
5. No deployment occurs without evaluation against a specific `PolicySnapshot` and a specific `EnvironmentProfile`.
6. No runtime admission may expose capability that is not declared in the release manifest.
7. No hidden dependency may bypass the release envelope.
8. No revoked artifact or revoked locked dependency may be newly deployed.
9. No rollback may target an artifact that was not previously admitted and recorded as valid for that environment.
10. No deployment record may omit the exact release id, policy snapshot id, environment profile id, actor, and time.
11. **No trust decision may depend on mutable ambient state that is not recorded in the deployment record.**
12. No failure of higher-order automation may cause fail-open deployment.
13. No admission may be granted against an attestation set that has passed its declared `TrustExpiry` without explicit re-verification against current trust anchors.
14. No capsule whose `CapsuleIdentityRecord` has been revoked may be packaged into a new release envelope.
15. No more than five concurrent canary experiments may be active across one target environment at any time.

---

## Appendix B: ADR Index

| ADR | Title | Date |
|---|---|---|
| ADR-001 | Skills Over Plugins | 2026-03-26 |
| ADR-002 | ArchangelMCP Gateway as Integration Backbone | 2026-03-26 |
| ADR-003 | OPA/Rego for Governance Policy (Chimera Plan) | 2026-03-26 |
| ADR-004 | Progressive Disclosure Tiers T1–T4 | 2026-03-26 |
| ADR-005 | Immutable Package Hash + Attestation Before Admission | 2026-03-26 |
| ADR-006 | Project Name Selected via March Madness Tournament | 2026-03-26 |

---

## Appendix C: Named Future Primitives

Architecturally reserved; must not require v1 incompatibility when added.

- `BehavioralCertificate` — LTS-encoded observable API contract; bisimulation-equivalent releases are hot-swap safe.
- `ZKBehavioralProof` — zero-knowledge proof of behavioral compliance without revealing internals.
- `SessionTypedProtocol` — compile-time protocol enforcement for tool invocation sequences.
- `RevocationImpactAssessment` — blast-radius simulation before executing revocation.
- `PolicyTransparencyLog` — append-only, publicly verifiable log of all `PolicySnapshot` versions.
- `PolicyConflictGraph` — persistent graph of all active policy conflict relationships.
- `EpistemicStateSnapshot` — structured capture of Dempster-Shafer confidence values at each decision point.
- `CapabilityDriftDetector` — per-release semantic diff of capability surface changes.
- `RevocationCascadeSimulator` — forward simulation of minimum recovery path after revocation.
- `ConstitutionalInvariantMonitor` — AI-native continuous audit primitive that verifies all constitution invariants.

---

*Attribution: Jonathan A. Bowe, 2026. Licensed under Apache-2.0.*

# ADR Log — AI Provenance Spec

This document records the architecture decisions made during the design and development of AI Provenance Spec. Each entry captures the context that drove the decision, the decision itself, and the trade-offs accepted. Records are append-only; superseded decisions are marked as such rather than deleted.

---

## ADR-001: Skills Over Plugins

**Status:** Accepted
**Date:** 2026-03-26

### Context

The existing plugin model requires marketplace synchronization, version pinning, installation lifecycle management, and persistent registry entries. This produces heavy startup costs, context bloat, and friction for operators who need capability available immediately without infrastructure ceremony.

### Decision

Replace plugins with skills. A skill is a self-contained execution unit that registers its tools, prompts, and resources with the ArchangelMCP gateway on invocation, executes within the caller's session context, and unregisters on completion. There is no installation step, no marketplace dependency, and no residual state after execution.

### Consequences

- Operators gain instant capability deployment with zero footprint until invoked.
- The plugin lifecycle (install, update, uninstall, version resolution) is eliminated entirely.
- Skills must be fully self-describing at invocation time; they cannot rely on ambient state from a prior session.
- Stateful plugins that accumulate session context across calls are not expressible in this model and must be redesigned as stateful skills with explicit snapshot/restore semantics.

---

## ADR-002: ArchangelMCP Gateway as Integration Backbone

**Status:** Accepted
**Date:** 2026-03-26

### Context

AI Provenance Spec needs a single stable surface for skill registration, tool dispatch, and session lifecycle management. Building a bespoke dispatch layer would duplicate infrastructure that already exists and is already trusted by the broader toolchain.

### Decision

ArchangelMCP (`http://localhost:7400/mcp`) is the sole integration backbone. Skills register their tools and prompts with the gateway on invocation. The gateway handles routing, surface management, and session surface application. AI Provenance Spec makes no direct MCP connections outside the gateway.

### Consequences

- All skill tooling inherits gateway reliability, observability, and surface profile configuration at no additional cost.
- The gateway becomes a hard runtime dependency; a downed gateway means no skill execution.
- Tool namespacing follows the `mcp__archangel__<prefix>_<tool>` convention enforced by the gateway — skills must conform.
- Gateway lifecycle (managed by launchd) must never be interrupted from within a Claude session.

---

## ADR-003: OPA/Rego for Governance Policy (Chimera Plan)

**Status:** Accepted
**Date:** 2026-03-26

### Context

Skills execute with direct access to session context, tool surfaces, and potentially sensitive resources. An unchecked skill admission model is a security liability. Policy must be declarative, auditable, and enforceable at the Admission Gate before any skill reaches execution.

### Decision

Governance is implemented via OPA (Open Policy Agent) with Rego policies. This is referred to internally as the "Chimera plan," deriving its T4 governance backbone from the Iron Constitution design. All skill admission decisions are evaluated against OPA policies before the Admission Gate permits execution. Policies are versioned alongside skill manifests.

### Consequences

- Policy decisions are auditable, portable, and testable outside the runtime.
- Operators can express fine-grained admission rules (capability constraints, trust-level requirements, scope limits) without modifying core infrastructure.
- OPA adds a synchronous evaluation step in the admission path; latency-sensitive deployments must account for policy evaluation time.
- Policy authors must learn Rego; this is a non-trivial learning curve for teams unfamiliar with it.

---

## ADR-004: Progressive Disclosure Tiers (T1–T4) for Context Efficiency

**Status:** Accepted
**Date:** 2026-03-26

### Context

Skills can carry substantial payloads — governance rules, recovery workflows, tool definitions, and presentation layers. Loading the full skill definition into context at invocation time is prohibitively expensive and violates the zero-footprint-until-invoked principle.

### Decision

Skill content is organized into four progressive disclosure tiers, loaded on demand:

- **T4** — Governance (OPA/Rego policies; loaded at admission gate evaluation)
- **T3** — Workflows (operational sequences; loaded at execution planning)
- **T2.5** — Recovery (rollback and error handling; loaded on failure paths)
- **T2** — Tools (executable tool definitions; loaded at invocation)
- **T1** — Skin (description, ~80 tokens; always loaded for discoverability)

### Consequences

- Baseline context cost per skill is approximately 80 tokens (T1 only).
- Full skill payloads can reach 100K+ tokens without impacting sessions that never invoke them.
- The tier boundary contract must be maintained by skill authors; violating it (e.g., embedding tool definitions in T1) defeats the efficiency model.

---

## ADR-005: Immutable Package Hash + Attestation Before Admission

**Status:** Accepted
**Date:** 2026-03-26

### Context

Skills execute in live session contexts with access to real resources. A tampered or unverified skill package is an unacceptable trust surface. The system needs cryptographic integrity guarantees and a clear chain of custody before any skill reaches execution.

### Decision

Two invariants are enforced as non-negotiable:

1. **Immutable package hash** — The Skill Package hash is computed at packaging time and must match at every subsequent lifecycle stage. Any mutation invalidates the package.
2. **Attestation before admission** — The Admission Gate will not permit execution of any skill that lacks a valid Attestation Record from a trusted Attester. The narrowest viable loop is: package → validate → attest → deploy → admit → rollback → revoke.

Trust roles (Packager, Attester, Deployer, Admitter) are distinct and must not collapse into a single principal.

### Consequences

- Tampered packages are rejected at the gate, not at runtime.
- Role separation prevents a single compromised credential from controlling the full deployment pipeline.
- Rollback is always possible; Rollback Snapshots are a required durable object, not an optional feature.
- Offline or air-gapped attestation workflows require pre-signed Attestation Records, adding operational complexity in restricted environments.

---

## ADR-006: Project Name Selected via March Madness Tournament

**Status:** Accepted
**Date:** 2026-03-26

### Context

The project needed a name that conveyed instant, armed, precision deployment — distinct from "plugin," "extension," or "module" — without requiring committee consensus or prolonged deliberation.

### Decision

The name was selected through a single-elimination bracket tournament styled after the NCAA March Madness format. Candidate names competed in head-to-head match-ups judged against criteria including evocativeness, distinctiveness, and alignment with the orbital deployment metaphor. "AI Provenance Spec" defeated "Sigil" in the championship round.

### Consequences

- The name is final. Renaming is a significant documentation and tooling cost; the tournament process was designed to produce a durable, committed choice.
- "Aegis" carries connotations of protection and divine sanction — consistent with the security-first governance model.
- "Drop" implies instant delivery from above, reinforcing the zero-installation, arrives-ready-to-execute mechanic.
- The tournament process is documented here as precedent for future naming decisions in the project ecosystem.

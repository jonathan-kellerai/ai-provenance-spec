# AI Provenance Spec — Skill Hot-Swap v1 Specification

- **Status:** Draft — ready for `/spec-init` review
- **Date:** 2026-03-27
- **Scope:** v1 MVP — lean session start, explicit skill load/unload, hook-driven auto-routing

---

## 1. Problem Statement

Claude Code sessions pre-load all installed plugin skills at session start. Every installed
SKILL.md, every agent definition, and every MCP tool definition consumes context tokens
regardless of whether the skill is ever used. A session with 20 installed plugins may burn
15,000–40,000 tokens on skill definitions before the user types a single message.

**Goal:** A Claude Code session starts lean. Skills load into context only when needed.
When a skill is done, its tools disappear from the visible surface. The session remains
context-efficient across its entire lifetime.

---

## 2. End Goal

Hot-swapping skills — full folders containing `SKILL.md` and associated agent/tool
definitions — so that a Claude Code session optimizes context by only maintaining skills
in context exactly when they are needed.

---

## 3. Corrected Architecture

### 3.1 What "Hot-Swap" Actually Provides

Two distinct benefits (not three — the third was a planning error):

| Benefit | Mechanism | Tokens Freed |
|---|---|---|
| **Lean session start** | No skill content pre-loaded; fetched on first need | 500–5,000 per skill × N skills |
| **Tool surface discipline** | Only active skills' MCP tools are visible per API call | 100–500 per tool × M unused tools |

**What hot-swap does NOT provide:** Removal of SKILL.md content from conversation
history. Once a skill's content appears in a tool response, it persists in history until
natural context compaction. `unload_skill` frees tool surface tokens only, not history
content. This must be communicated honestly in user-facing output.

### 3.2 Lifecycle

```
SESSION START: LEAN
├── Gateway surface: core tools only
└── Context: zero skill content loaded

UserPromptSubmit hook fires on each user message:
├── Scores message against Skill Registry (T1 descriptions + triggers)
├── If score > threshold AND skill not already loaded → call load_skill(name)
└── On conflict (conflicts_with match) → load highest-scoring skill only

load_skill(name):
  1. PRE-FLIGHT  Verify skill folder exists and SKILL.md is valid
  2. PRE-FLIGHT  Verify all gateway_surface_required tools are registered on gateway
                 → Fail loudly if unavailable (no silent partial loads)
  3. SNAPSHOT    Record current surface state in Loaded-Skill Manifest
  4. READ        Fetch SKILL.md content (T1 + T2 tiers in MVP)
  5. RETURN      SKILL.md content as tool response text → lands in conversation history
  6. SURFACE     Compute new surface = base_surface UNION skill.gateway_surface_required
                 → gateway_session_surface_apply(full union)
  7. REGISTER    Add entry to Loaded-Skill Manifest:
                 { name, tools_contributed: [...], loaded_at: timestamp }

[Claude executes using skill tools]

Stop hook fires after each Claude response:
├── Scan response for done_signals patterns → if matched, call unload_skill(name)
└── Check context budget → if loaded_tool_tokens > budget_threshold,
    evict LRU skill (by last tool invocation timestamp)

unload_skill(name):
  1. LOOKUP      Find skill entry in Loaded-Skill Manifest
  2. COMPUTE     tools_to_remove = skill.tools_contributed
                 MINUS union(all_other_loaded_skills.tools_contributed)
                 [ref-counted: shared tools like morph_edit_file stay if another skill needs them]
  3. SURFACE     Compute new surface = current_surface MINUS tools_to_remove
                 → gateway_session_surface_apply(reduced set)
  4. DEREGISTER  Remove skill from Loaded-Skill Manifest
  5. RETURN      Confirmation + tool_tokens_freed (honest accounting — not history tokens)
```

### 3.3 Loaded-Skill Manifest

Runtime data structure (in-memory, gateway-held) required for correct load/unload:

```
LoadedSkillManifest:
  base_surface: [tool_name, ...]       # surface before any skill was loaded
  loaded_skills: [
    {
      name: str
      tools_contributed: [tool_name, ...]   # what THIS skill added
      loaded_at: ISO timestamp
      last_tool_call: ISO timestamp         # for LRU eviction
    }
  ]
```

This structure answers: "If I unload skill X, which tools can safely be removed?"
Without it, unload either removes shared tools incorrectly or removes nothing at all.

---

## 4. Gate Zero — Empirical Prerequisite

**This test must pass before any implementation begins. It is the go/no-go gate.**

**Question:** When `gateway_session_surface_apply` is called mid-session, does Claude Code
re-issue a `tools/list` request and see the updated tool set in the same conversation?

**Test procedure:**
1. Start a lean Claude Code session with tool A visible, tool B hidden
2. Perform one turn with Claude (confirm it can see A, cannot see B)
3. Call `gateway_session_surface_apply` to swap: hide A, show B
4. Perform a second turn — can Claude call B? Does it know B's schema?

**If yes:** Tool surface management works. Architecture is viable. Proceed.

**If no:** Claude caches the tool list at session start and ignores `tools/list_changed`
notifications. The tool surface benefit does not exist. The architecture requires fundamental
redesign — lean-start becomes the only benefit, and the implementation is radically simpler
(just don't pre-load SKILL.md content; no gateway surface changes needed at all).

**This test has zero dependencies. It can run today.**

---

## 5. SKILL.md Hot-Swap Contract

### 5.1 New Fields (all optional — absent = legacy skill, not hot-swap-eligible)

```yaml
---
name: skill-name
description: "..."           # T1 — 80 token max; includes trigger phrases; used for routing

# === HOT-SWAP FIELDS ===

# Gateway visibility requirements (renamed from mcp_tools_required for layer clarity)
gateway_surface_required:
  - name: morph_edit_file
    required: hard            # hard = load fails if unavailable; soft = skill degrades
  - name: tavily_tavily_search
    required: soft

# Token cost anchored by tier
context_tokens:
  t1: 80                      # measurable — description only
  t2: 2400                    # estimated — tools + workflow instructions
  measured_at: "2026-03-27"   # staleness indicator for scheduler

# Trigger hints with explicit matching semantics
triggers:
  - "write a spec"
  - "feature specification"
trigger_mode: semantic         # semantic | exact | substring

# Lifecycle completion signals
done_signals:
  - "spec is complete"
  - "draft ready for review"

# Version and compatibility
version: "1.0.0"
conflicts_with: []            # skill names that cannot co-load
requires_skills: []           # skill names that must be loaded first
provides:                     # logical capability labels for overlap detection
  - "specification-writing"

# Existing fields (unchanged)
user-invocable: true
allowed-tools: [Read, Edit, Write, Glob, Grep]
argument-hint: "[target-feature]"
model: sonnet
---
```

### 5.2 Field Definitions

**`gateway_surface_required`** — Gateway visibility layer (what MCP tools must appear in
the session surface). Semantically distinct from `allowed-tools` (Claude Code permission
layer — what Claude may call). Both fields may coexist; they enforce at different layers.

- `required: hard` — `load_skill` fails with a clear error if the tool is not registered
  on the gateway. The skill does not partially load.
- `required: soft` — Skill loads; missing tool logged as warning; skill operates in
  degraded mode for that capability.

**`context_tokens`** — Split by tier. T1 is measurable at authoring time. T2+ are
estimates. The scheduler uses T1 for routing decisions; T2 for budget tracking.
`measured_at` enables staleness detection. Wrong estimates do not block load; they
degrade eviction accuracy.

**`trigger_mode: semantic`** — The UserPromptSubmit hook scores the incoming message
against each skill's `description` + `triggers` list using semantic similarity (morph
embedding or BM25). Not exact match. Not regex. The threshold is configurable
(default: 0.72 cosine similarity).

**`done_signals`** — Phrase patterns the Stop hook scans for in Claude's response text.
On match, auto-unload fires for that skill. Case-insensitive substring match in MVP.

**`conflicts_with`** — If a skill in this list is already loaded when this skill is
requested, the router loads whichever scored higher and skips the other.

**`provides`** — Logical capability labels. Enables the router to detect functional
overlap even when skill names differ (e.g., two browser automation skills both providing
`"browser-control"`).

### 5.3 Backward Compatibility

All new fields are optional. Existing SKILL.md files with only `name` and `description`
remain valid. Absent `gateway_surface_required` = not hot-swap-eligible = never
auto-loaded by the hook, never auto-unloaded. Legacy skills can still be invoked
explicitly by the user.

No breaking changes to any existing skill in the marketplace.

### 5.4 Tier Integration (ADR-004 alignment)

| Tier | What loads | When |
|---|---|---|
| T1 | `description` + `triggers` | Always in Skill Registry index |
| T2 | Tool definitions + workflow instructions | At `load_skill` invocation |
| T3 | Reference docs, examples | On explicit request within skill execution |
| T4 | Governance policies | Deferred — not in hot-swap MVP |

`context_tokens.t1` covers the registry index cost (always loaded).
`context_tokens.t2` covers the `load_skill` invocation cost.

---

## 6. Issue Restructuring Plan

### 6.1 EPIC Update

**`ai-provenance-spec-nq7`** — Update title and acceptance criteria:

- **New title:** "AI Provenance Spec v1 — Skill Hot-Swap for Context-Efficient Claude Code Sessions"
- **New acceptance criteria:**
  - Session starts with zero skill content and core tools only
  - `load_skill(name)` succeeds or fails loudly with pre-flight validation
  - Loaded skill's MCP tools become visible in session surface
  - Unload correctly removes only that skill's unique tools (shared tools preserved via ref-count)
  - Tool tokens freed on unload accurately reported (not history tokens)
  - UserPromptSubmit hook auto-routes and loads skills without user intervention
  - Stop hook auto-unloads on done_signal detection
  - End-to-end lean session demonstrated: start lean → load → execute → unload → lean

### 6.2 Issues to Supersede

| Issue | Action | Reason |
|---|---|---|
| — Runtime Admission + Surface Enforcement | Superseded by new-4 | Load/unload tools are different scope than admission gate |

### 6.3 Issues to Defer

| Issue | Reason |
|---|---|
| — Attestation | Full attestation not MVP; minimal integrity check (new-6) covers it |
| — Confidence Model | Governance layer; not required for hot-swap |
| — Rollback/Revocation | Production concern; graceful unload covers MVP need |
| — Degraded Mode | Load failure semantics (new-5) covers the MVP subset |
| — Audit | Deferred; load failure logs cover minimum observability |
| — PolicySnapshot | Deferred as runtime feature; informs new-2 contract design |

### 6.4 New Issues — Critical Path

```
[Gate Zero: empirical mid-session tool re-list test]  ← P0, unblocked, spike
            ↓
[new-1: Skill folder canonical layout]                ← P1, unblocked
            ↓
[new-2: SKILL.md hot-swap contract]                   ← P0, blocked by new-1
            ↓
[new-3: ArchangelMCP skill-as-gateway-primitive]      ← P0, blocked by new-2
  (external: ArchangelMCP project issue; hard dependency)
  Deliverable: Loaded-Skill Manifest; base surface snapshot; surface recompute API
            ↓
[new-4: load_skill / unload_skill gateway tools]      ← P0, blocked by new-3
  │                          │
  ▼                          ▼
[new-5: Load failure semantics]    [new-6: Minimal integrity check]
  (subset of deferred Attestation work; P1)               (subset of deferred Degraded Mode work; P1)
  │
  ▼
[new-7: UserPromptSubmit + Stop hooks]               ← P1, blocked by new-4, new-5
  (classifier, auto-load, done_signal detection, LRU eviction)
  │
  ▼
[new-8: Context budget tracker]                      ← P2, blocked by new-7
  (between-turn only; tracks tool definition tokens; LRU eviction policy)
```

### 6.5 Dependency Notes

- **Skill router lives in the hooks (new-7)**, not as a separate service. The
  UserPromptSubmit hook IS the router. No separate routing issue needed.
- **PolicySnapshot** informs the SKILL.md contract design (what a skill must
  declare for admission policy evaluation) but is not required at runtime for MVP.
  Treat as a design input to new-2, not a graph dependency.
- **Gate Zero blocks everything.** If the empirical test fails, new-3 through new-8 need
  redesign. Gate Zero has no code dependencies and should run in the first sprint.

---

## 7. Open Architecture Decisions

These decisions are made for v1. Record any changes as ADR updates.

| Decision | Choice | Rationale |
|---|---|---|
| Router trigger | Hook-driven (UserPromptSubmit) | Fully automatic; no user action required; consistent activation |
| Injection mechanism | Tool response text (not MCP prompt/resource) | MCP prompts/resources are registered at mount time; tool response is simpler and real |
| Surface modification | Full reset via `gateway_session_surface_apply` | No incremental API exists; full reset with computed union/diff is correct approach |
| Tier loading at invocation | T1 + T2 only | T3 on explicit request; T4 deferred entirely |
| Unload trigger | Stop hook (between-turn) | Background interrupts not possible in MCP/Claude turn-based model |
| Eviction policy | LRU by last tool invocation timestamp | Simple, implementable, predictable |
| Budget tracking unit | Tool definition tokens only | History content cannot be freed by unload; honest accounting requires this scope |
| Backward compatibility | All new fields optional | Zero breakage to existing marketplace skills |

---

## 8. Constraints and Known Limits

1. **Gateway registration wall** — Hot-swap controls tool visibility only for tools
   already registered with the gateway at startup. Skills requiring tools from
   unregistered MCP servers cannot be hot-swapped without gateway restart.

2. **History is permanent** — SKILL.md content in conversation history cannot be removed
   by unload. The primary context savings is from lean session start, not from unload.
   Long sessions that repeatedly load/unload heavy skills accumulate history cost.

3. **Turn-based unload only** — Auto-unload fires between turns (Stop hook), not during
   a running turn. There is no mechanism to interrupt mid-turn execution.

4. **Shared tool ref-counting** — Skills sharing tools (e.g., two skills both needing
   `morph_edit_file`) require accurate Loaded-Skill Manifest ref-counting. Failure to
   track this correctly will remove shared tools prematurely on unload.

5. **Gate Zero is load-bearing** — If Claude Code does not re-list tools mid-session,
   the tool surface discipline benefit does not exist. The architecture pivots to lean
   session start as the only mechanism, which requires no gateway surface changes at all.

---

## 9. Out of Scope (v1)

- Full attestation and ReleaseEnvelope packaging
- Dempster-Shafer confidence model
- Rollback/revocation with persistent records
- PolicySnapshot and EnvironmentProfile admission gate runtime
- Full circuit breakers and degraded mode beyond load failure semantics
- Deployment audit and decision trace
- T3/T4 tier loading
- Multi-session skill caching
- Skill version management and mid-session upgrades

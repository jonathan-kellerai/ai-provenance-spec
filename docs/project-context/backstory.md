# AI Provenance Spec — Origin Story

- **Date:** 2026-03-25
- **Named by:** March Madness Telegram tournament (128 avatars, 32 candidates, 16-team bracket)
- **Championship:** AI Provenance Spec beat Sigil in the final
- **Bracket path:** beat Daemon → beat Incursion → beat Catalyst → beat Sigil

## The Name

**Aegis** (Greek: αἰγίς) — the shield of Zeus and Athena, symbol of divine protection and authority.
**Drop** — military: orbital insertion, precision deployment from altitude.

Combined: skills drop from the ArchangelMCP mothership pre-armed, pre-configured, ready on impact.
The aegis provides the authority (governance). The drop provides the mechanism (instant deployment).

## The Concept

The plugin model is heavy:
- Installation ceremony (marketplace, version pins, validation)
- Persistent footprint (cache dirs, settings entries, hook registrations)
- Context cost (~5-15K tokens per plugin's tool definitions)
- Lifecycle management (updates, deprecation, conflicts)

AI Provenance Spec replaces this with ephemeral skill deployment:
- Skills are invoked, not installed
- They register tools on-demand and unregister on completion
- Context cost is near-zero until invocation
- No lifecycle — each invocation is fresh

## The 16 Candidates

| Seed | Name | Fate |
|------|------|------|
| 1 | Sigil | Runner-up (lost in Championship) |
| 2 | Quicksilver | Lost Round of 16 |
| 3 | Nomad | Lost Quarterfinals |
| 4 | Filament | Lost Round of 16 |
| 5 | Dispatch | Lost Round of 16 |
| 6 | **AI Provenance Spec** | **CHAMPION** |
| 7 | Daemon | Lost Round of 16 |
| 8 | Mjolnir | Lost Round of 16 |
| 9 | Pulsar | Lost Quarterfinals |
| 10 | Incursion | Lost Quarterfinals |
| 11 | Protean | Lost Quarterfinals |
| 12 | Phantom | Lost Round of 16 |
| 13 | Catalyst | Lost Semifinals |
| 14 | Vector | Lost Round of 16 |
| 15 | Aspect | Lost Round of 16 |
| 16 | Javelin | Lost Round of 16 |

## Related Architecture

- Cortex Architecture (Telegram as nervous system)
- **Governance Grimoire**: OPA/Rego policy-as-code (Chimera plan)
- **ArchangelMCP**: Gateway that will host AI Provenance Spec skill deployment
- **Matryoshka**: Sister project (RAG + 2 SLMs in a skill shell)

# Security Policy

## Reporting a Vulnerability

AI Provenance Spec is a specification-stage project — there is no shipped implementation yet to attack. Report security concerns about the **specification itself** (governance gaps, attestation chain flaws, invariant violations that admit unsafe state, missing trust-boundary checks) via:

- **Preferred:** [GitHub Security Advisories](https://github.com/jonathan-kellerai/ai-provenance-spec/security/advisories/new) — private disclosure to maintainers
- **Fallback:** Open a regular GitHub issue with the label `security` if the concern is non-sensitive

## What's in scope

- Constitution invariant violations admitting unsafe state
- Trust-boundary or role-separation flaws in the governance model
- Attestation chain or hash-chain construction flaws
- OPA/Rego policy bypasses in `docs/governance/policies/`
- Spec ambiguities that an implementer could exploit

## What's out of scope

- Implementation vulnerabilities (no implementation exists)
- Vulnerabilities in ArchangelMCP, OPA, or other named runtime dependencies — report those upstream
- Theoretical attacks against deferred future primitives (see `docs/governance/constitution.md` §Named Future Primitives)

## Disclosure

Maintainers will acknowledge within 5 business days. Coordinated disclosure timeline is negotiated per-report depending on severity and whether the flaw affects a downstream implementation.

# Conventions

Tier-2 reference. The summary lives in [AGENTS.md](../../AGENTS.md); this file is
the detail. It governs how agents and humans commit, branch, open pull requests,
cite sources, and change architecture decisions in this repository.

## Commit messages — Conventional Commits

Every commit message follows the
[Conventional Commits v1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
format:

```text
<type>(<scope>): <subject>

<body>

<footer>
```

- **type** (required) — one of `feat`, `fix`, `docs`, `refactor`, `chore`,
  `test`, `build`, `ci`, `perf`, `revert`.
- **scope** (optional) — the area changed, in parentheses, e.g. `(constitution)`,
  `(adr)`, `(hot-swap)`.
- **subject** (required) — imperative mood, ≤50 characters, no trailing period.
- **body** (optional) — one blank line after the subject; wrap at 72 characters;
  explains *why*.
- **footer** (optional) — one blank line after the body.

Commit-message format is enforced in CI by `commitlint`
(`.github/workflows/commitlint.yml`); a non-conforming message fails the build.

Because this repo ships no code, `feat` and `fix` apply to the *specification*:
`feat` adds spec content, `fix` corrects an error. A breaking change to the
binding architecture is signalled with `!` (`docs(constitution)!: ...`) **and**
must be backed by an ADR — see *Changing an ADR* below.

Examples:

```text
docs(readme): clarify the five-stage hash chain ordering
fix(adr): correct the date on ADR-004
feat(specs): add the rollback worked example to hot-swap-v1
ci(pages): pin the deploy-pages action to a commit SHA
```

## Branch naming

The default branch is `main`. Never create or target `master`. Every branch is
cut from the current `main`.

- **Agent work** uses `<agent>/<scope>` — `claude/<scope>`, `codex/<scope>`,
  and so on. Example: `claude/fix-typo-adr-003`.
- **Human work** uses a type prefix — `feat/<scope>`, `fix/<scope>`,
  `docs/<scope>`, `chore/<scope>`.

`<scope>` is a short kebab-case description of the change. One branch, one
logical change.

## Convention edge cases

The cases below are the ones that, in practice, trip agents and first-time
contributors. They are written down here so the answer is never improvised.

- **Never commit on `main` or a detached HEAD.** Create a branch first. If you
  find yourself on a detached HEAD, branch from it before committing.
- **Always branch from the current `main`.** Pull `main` first; do not branch
  off another feature branch unless you are deliberately stacking work.
- **Multi-scope changes** — if one logical change genuinely spans two areas,
  omit the scope (`docs: ...`) rather than invent a compound scope. If it is
  really two changes, split it into two branches and two PRs.
- **`<scope>` casing** — kebab-case, lowercase, no spaces: `hot-swap`, not
  `Hot_Swap`.
- **Revert and hotfix branches** — a revert uses the `revert` commit type, on a
  `fix/<scope>` branch (human) or `<agent>/revert-<scope>` branch (agent).
- **Continuing another agent's branch** — keep the original branch name; do not
  rename it to your own agent prefix. Attribution belongs in the commit trailer,
  not the branch name.
- **Worktrees** — fine for parallel work, but each worktree still obeys the
  one-branch-one-change rule.
- **Fork vs. same-repo PRs** — contributors without write access open PRs from
  a fork; never open a PR from your fork's `main`, always from a named branch.
- **Commit type for non-spec edits** — a CHANGELOG edit is `docs`; a workflow or
  CI edit is `ci`; an edit to `AGENTS.md`, `CLAUDE.md`, or `docs/agents/**` is
  `docs`; a tooling-config edit (`lefthook.yml`, `commitlint.config.js`) is
  `chore`.
- **Subject line** — imperative mood ("add", not "added" or "adds"), no trailing
  period, ≤50 characters.
- **Body wrap** — wrap the commit body at 72 characters.

## Pull requests

- Open a PR for any edit to `docs/**`, `README.md`, `AGENTS.md`, or `CLAUDE.md`.
- Keep the diff small — one logical change per PR.
- The PR description names the file(s) changed and the reason; the
  `.github/PULL_REQUEST_TEMPLATE.md` sections are all required.
- Edits to gitignored staging files do not need a PR.

## Citations

- **Internal reference** — cite as `path:line`, e.g.
  `docs/governance/constitution.md:142`.
- **External or academic reference** — cite with a full bibliographic
  reference: author, title, venue, year. See [citation.md](citation.md) for how
  to cite AI Provenance Spec itself.

## Changing an ADR

[`docs/ADR.md`](../ADR.md) is **append-only**. Superseded decisions are marked,
never deleted. To change a recorded decision:

1. Do **not** edit the body of the existing ADR.
2. Append a **new** ADR with the next number in sequence.
3. Give the new ADR a header line `Supersedes ADR-NNN` naming the decision it
   replaces.
4. Mark the old ADR's status as `Superseded by ADR-MMM`.

This preserves the reasoning trail: a reader can always see what was decided,
when, and why it later changed.

## Changing the constitution

Invariants in [`docs/governance/constitution.md`](../governance/constitution.md)
are binding. They change only through the constitution's **Amendment Rule**: an
explicit architecture decision that names the clause being changed, the reason,
the migration impact, the compatibility impact, the security impact, the
rollback plan, and proof that existing deployment records remain interpretable —
with recorded approval from the Policy Authority, Release Authority, and
Environment Owner. A pull request may never change the meaning of an invariant
on its own.

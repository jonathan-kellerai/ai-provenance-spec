// Commit-message linting. Enforced in CI by .github/workflows/commitlint.yml.
// See docs/agents/conventions.md for the full Conventional Commits convention.
module.exports = {
  extends: ['@commitlint/config-conventional'],
};

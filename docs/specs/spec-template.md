---
spec_id: docs/specs/spec-template.md   # --spec-id
worktree: ai-provenance-spec                    # (routing — identifies this repo)
title: "Replace this with the issue title"  # --title  REQUIRED
type: task                              # --type  REQUIRED: bug|feature|task|epic|chore|decision
priority: "2"                           # --priority  REQUIRED: 0=critical 1=high 2=medium 3=low 4=backlog
assignee: ""                            # --assignee
labels: []                              # --labels  e.g. [backend, auth, performance]
estimate: 0                             # --estimate  minutes, positive integer (0 = unestimated)
due: ""                                 # --due  +Nd, +Nh, tomorrow, next <weekday>, YYYY-MM-DD
parent: ""                              # --parent  bd issue ID of parent epic/feature
deps: []                                # --deps  e.g. ["blocks:bd-a1b2", "bd-c3d4"]
skills: ""                              # --skills  comma-separated skill tags
external_ref: ""                        # --external-ref  Jira/GitHub/Linear reference
---

## Description

> What needs to be done and why.
> Minimum 10 characters enforced by validation policy R2.
> Be specific enough that a new contributor understands scope without asking.

Replace this paragraph with the issue description.

## Acceptance Criteria

> Required for `feature` and `epic` types (policy R8).
> Each criterion must be testable and unambiguous (pass/fail, not "works well").

- [ ] Criterion 1
- [ ] Criterion 2

## Design Notes

> Required for `feature`, `epic`, and `decision` types (policy R9).
> Capture key decisions, alternatives considered, constraints, and non-goals.

(Leave blank for `task`, `bug`, and `chore` types — not required by policy.)

## Issue Creation Command

Copy the generated `bd create` command after filling in the fields above:

```bash
bd create \
  --title "..." \
  --type task \
  --priority 2 \
  --spec-id docs/specs/spec-template.md
```

## Validate Against Policy

```bash
# Convert YAML frontmatter to JSON, then run OPA
opa eval \
  -d docs/governance/policies/spec_validation.rego \
  -i <issue-frontmatter.json> \
  "data.release.spec.validation.allow"
```

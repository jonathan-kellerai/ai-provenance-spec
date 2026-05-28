package aegisdrop.spec.validation

# ---------------------------------------------------------------------------
# spec_validation.rego
#
# OPA policy that validates issue objects destined for `bd create --file`
# ingestion. Input is a single issue object parsed from a spec template section.
#
# Usage:
#   opa eval -d docs/governance/policies/spec_validation.rego \
#     -i <issue.json> "data.aegisdrop.spec.validation.allow"
#
# Or with a batch of issues:
#   for issue in issues/*.json; do
#     opa eval -d docs/governance/policies/spec_validation.rego -i "$issue" \
#       "data.aegisdrop.spec.validation.violations"
#   done
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

valid_types := {
    "bug",
    "feature",
    "task",
    "epic",
    "chore",
    "decision",
}

valid_mol_types := {"swarm", "patrol", "work"}

valid_waits_for_gates := {"all-children", "any-children"}

valid_dep_rel_types := {
    "discovered-from",
    "blocks",
    "blocked-by",
    "relates-to",
    "waits-for",
}

# ---------------------------------------------------------------------------
# Helper rules
# ---------------------------------------------------------------------------

# True if the input string matches a valid bd issue ID pattern: <prefix>-<alphanum>
# e.g., bd-a1b2, bd-42, epic-placeholder
is_valid_id(id) if {
    regex.match(`^[a-z]+-[a-z0-9]+$`, id)
}

# True if a dependency string is valid.
# Accepts either:
#   "rel-type:issue-id"  e.g., "blocks:bd-a1b2"
#   "issue-id"           e.g., "bd-a1b2"
is_valid_dep(dep) if {
    parts := split(dep, ":")
    count(parts) == 2
    parts[0] in valid_dep_rel_types
    is_valid_id(parts[1])
}

is_valid_dep(dep) if {
    count(split(dep, ":")) == 1
    is_valid_id(dep)
}

# True if value is a valid priority.
# Accepts integer 0-4 OR string "P0"-"P4" OR string "0"-"4".
is_valid_priority(p) if {
    is_number(p)
    p >= 0
    p <= 4
}

is_valid_priority(p) if {
    is_string(p)
    regex.match(`^[Pp][0-4]$`, p)
}

is_valid_priority(p) if {
    is_string(p)
    regex.match(`^[0-4]$`, p)
}

# True if value is a valid due/defer date format.
is_valid_date(d) if {
    # Relative: +6h, +1d, +2w, +30d
    regex.match(`^\+\d+[hdw]$`, d)
}

is_valid_date(d) if {
    d == "tomorrow"
}

is_valid_date(d) if {
    regex.match(`^next \w+$`, d)
}

is_valid_date(d) if {
    # ISO 8601 date: 2025-01-15
    regex.match(`^\d{4}-\d{2}-\d{2}$`, d)
}

# ---------------------------------------------------------------------------
# Deny rules — each produces a human-readable violation message
# ---------------------------------------------------------------------------

# R1: title must be present and non-empty
deny contains msg if {
    not input.title
    msg := "MISSING_TITLE: 'title' field is required and must be non-empty"
}

deny contains msg if {
    is_string(input.title)
    count(trim_space(input.title)) == 0
    msg := "EMPTY_TITLE: 'title' must not be blank"
}

# R2: description must be present and at least 10 characters
deny contains msg if {
    not input.description
    msg := "MISSING_DESCRIPTION: 'description' field is required"
}

deny contains msg if {
    is_string(input.description)
    count(input.description) < 10
    msg := sprintf(
        "SHORT_DESCRIPTION: 'description' must be at least 10 characters (got %d)",
        [count(input.description)],
    )
}

# R3: type must be one of the known valid types
deny contains msg if {
    input.type
    not input.type in valid_types
    msg := sprintf(
        "INVALID_TYPE: 'type' must be one of %v (got '%s')",
        [valid_types, input.type],
    )
}

# R4: priority, if present, must be valid
deny contains msg if {
    input.priority != null
    not is_valid_priority(input.priority)
    msg := sprintf(
        "INVALID_PRIORITY: 'priority' must be 0-4 or P0-P4 (got '%v')",
        [input.priority],
    )
}

# R5: deps, if present, must be an array and each entry must be valid
deny contains msg if {
    input.deps
    not is_array(input.deps)
    msg := "INVALID_DEPS_FORMAT: 'deps' must be an array of dependency strings"
}

deny contains msg if {
    input.deps
    is_array(input.deps)
    dep := input.deps[_]
    not is_valid_dep(dep)
    msg := sprintf(
        "INVALID_DEP: dependency '%s' must match 'rel-type:issue-id' or bare 'issue-id' (e.g., 'blocks:bd-a1b2')",
        [dep],
    )
}

# R6: labels, if present, must be an array of non-empty strings
deny contains msg if {
    input.labels
    not is_array(input.labels)
    msg := "INVALID_LABELS_FORMAT: 'labels' must be an array of strings"
}

deny contains msg if {
    input.labels
    is_array(input.labels)
    label := input.labels[_]
    not is_string(label)
    msg := sprintf("INVALID_LABEL: each label must be a string (got '%v')", [label])
}

deny contains msg if {
    input.labels
    is_array(input.labels)
    label := input.labels[_]
    is_string(label)
    count(trim_space(label)) == 0
    msg := "EMPTY_LABEL: labels must not contain blank strings"
}

# R7: estimate, if present, must be a positive integer (minutes)
deny contains msg if {
    input.estimate != null
    not is_number(input.estimate)
    msg := sprintf(
        "INVALID_ESTIMATE: 'estimate' must be a positive integer in minutes (got '%v')",
        [input.estimate],
    )
}

deny contains msg if {
    input.estimate != null
    is_number(input.estimate)
    input.estimate <= 0
    msg := sprintf(
        "NON_POSITIVE_ESTIMATE: 'estimate' must be > 0 minutes (got %d)",
        [input.estimate],
    )
}

deny contains msg if {
    input.estimate != null
    is_number(input.estimate)
    input.estimate > 0
    input.estimate != round(input.estimate)
    msg := sprintf(
        "NON_INTEGER_ESTIMATE: 'estimate' must be a whole number of minutes (got %v)",
        [input.estimate],
    )
}

# R8: due, if present, must match an allowed date format
deny contains msg if {
    input.due
    not is_valid_date(input.due)
    msg := sprintf(
        "INVALID_DUE: 'due' must be +Nd/h/w, 'tomorrow', 'next <weekday>', or YYYY-MM-DD (got '%s')",
        [input.due],
    )
}

# R8b: defer, if present, must also match an allowed date format
deny contains msg if {
    input.defer
    not is_valid_date(input.defer)
    msg := sprintf(
        "INVALID_DEFER: 'defer' must be +Nd/h/w, 'tomorrow', 'next <weekday>', or YYYY-MM-DD (got '%s')",
        [input.defer],
    )
}

# R9: mol_type, if present, must be one of the valid molecule types
deny contains msg if {
    input.mol_type
    not input.mol_type in valid_mol_types
    msg := sprintf(
        "INVALID_MOL_TYPE: 'mol_type' must be one of %v (got '%s')",
        [valid_mol_types, input.mol_type],
    )
}

# R10: waits_for_gate, if present, must be a valid gate type
deny contains msg if {
    input.waits_for_gate
    not input.waits_for_gate in valid_waits_for_gates
    msg := sprintf(
        "INVALID_WAITS_FOR_GATE: 'waits_for_gate' must be 'all-children' or 'any-children' (got '%s')",
        [input.waits_for_gate],
    )
}

# ---------------------------------------------------------------------------
# Allow / violations surface rules
# ---------------------------------------------------------------------------

# allow is true when no violations exist
default allow := false

allow if {
    count(deny) == 0
}

# violations enumerates all denial messages
violations contains msg if {
    msg := deny[_]
}

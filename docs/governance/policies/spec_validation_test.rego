package aegisdrop.spec.validation_test

import data.aegisdrop.spec.validation

# Test 1: valid issue — all required fields present and well-formed
test_valid_issue_passes if {
    issue := {
        "title": "Implement threat model for API endpoints",
        "description": "Enumerate all API surfaces, apply STRIDE analysis, and document mitigations for each threat vector found during red team review.",
        "type": "feature",
        "priority": "P1",
        "labels": ["security", "api", "threat-model"],
        "deps": ["blocks:bd-a1b2", "discovered-from:bd-c3d4"],
        "estimate": 480,
        "due": "+2w",
        "mol_type": "work",
    }
    validation.allow with input as issue
}

test_valid_issue_no_violations if {
    issue := {
        "title": "Implement threat model for API endpoints",
        "description": "Enumerate all API surfaces, apply STRIDE analysis, and document mitigations for each threat vector found during red team review.",
        "type": "feature",
        "priority": "P1",
        "labels": ["security", "api", "threat-model"],
        "estimate": 480,
    }
    count(validation.deny) == 0 with input as issue
}

# Test 2: invalid type — should produce exactly one INVALID_TYPE violation
test_invalid_type_denied if {
    issue := {
        "title": "Some Issue",
        "description": "A description that is long enough to pass the minimum length check.",
        "type": "enhancement",
    }
    not validation.allow with input as issue
}

test_invalid_type_violation_message if {
    issue := {
        "title": "Some Issue",
        "description": "A description that is long enough to pass the minimum length check.",
        "type": "enhancement",
    }
    violations := validation.deny with input as issue
    count(violations) >= 1
    some v in violations
    startswith(v, "INVALID_TYPE:")
}

# Test 3: malformed dep — should produce an INVALID_DEP violation
test_malformed_dep_denied if {
    issue := {
        "title": "Issue With Bad Dep",
        "description": "This issue has a dependency string that does not match the required format.",
        "type": "task",
        "deps": ["unknown-rel:bd-abc", "BLOCKS:bd-123"],
    }
    not validation.allow with input as issue
}

test_malformed_dep_violation_message if {
    issue := {
        "title": "Issue With Bad Dep",
        "description": "This issue has a dependency string that does not match the required format.",
        "type": "task",
        "deps": ["unknown-rel:bd-abc", "BLOCKS:bd-123"],
    }
    violations := validation.deny with input as issue
    some v in violations
    startswith(v, "INVALID_DEP:")
}

# Test 4: missing title — should produce MISSING_TITLE violation
test_missing_title_denied if {
    issue := {
        "description": "Description is present and long enough.",
        "type": "task",
    }
    not validation.allow with input as issue
}

test_missing_title_violation_message if {
    issue := {
        "description": "Description is present and long enough.",
        "type": "task",
    }
    violations := validation.deny with input as issue
    some v in violations
    startswith(v, "MISSING_TITLE:")
}

# Test 5: description too short — should produce SHORT_DESCRIPTION violation
test_short_description_denied if {
    issue := {
        "title": "Short Desc Issue",
        "description": "Too short",
        "type": "chore",
    }
    not validation.allow with input as issue
}

# Test 6: invalid priority format
test_invalid_priority_denied if {
    issue := {
        "title": "Bad Priority Issue",
        "description": "This issue has a priority that does not conform to the allowed format.",
        "type": "task",
        "priority": "urgent",
    }
    not validation.allow with input as issue
}

test_invalid_priority_violation_message if {
    issue := {
        "title": "Bad Priority Issue",
        "description": "This issue has a priority that does not conform to the allowed format.",
        "type": "task",
        "priority": "urgent",
    }
    violations := validation.deny with input as issue
    some v in violations
    startswith(v, "INVALID_PRIORITY:")
}

# Test 7: integer priority 0-4 is valid (including 0)
test_integer_priority_zero_valid if {
    issue := {
        "title": "Critical Security Fix",
        "description": "Priority zero is critical — must be accepted as a valid priority by the policy.",
        "type": "bug",
        "priority": 0,
    }
    validation.allow with input as issue
}

test_integer_priority_four_valid if {
    issue := {
        "title": "Backlog Cleanup Task",
        "description": "Priority four is backlog — must be accepted as a valid priority by the policy.",
        "type": "chore",
        "priority": 4,
    }
    validation.allow with input as issue
}

# Test 8: invalid mol_type
test_invalid_mol_type_denied if {
    issue := {
        "title": "Bad Mol Type Issue",
        "description": "This issue specifies a mol_type that is not in the allowed set.",
        "type": "epic",
        "mol_type": "cluster",
    }
    not validation.allow with input as issue
}

# Test 9: invalid due date format
test_invalid_due_date_denied if {
    issue := {
        "title": "Bad Due Date Issue",
        "description": "This issue has a due date that does not match any recognized format string.",
        "type": "task",
        "due": "asap",
    }
    not validation.allow with input as issue
}

# Test 10: valid defer format (e.g., +30d)
test_valid_defer_passes if {
    issue := {
        "title": "Deferred Feature",
        "description": "This feature is intentionally deferred to allow dependent work to stabilize first.",
        "type": "feature",
        "defer": "+30d",
    }
    validation.allow with input as issue
}

# Test 11: non-positive estimate denied
test_non_positive_estimate_denied if {
    issue := {
        "title": "Zero Estimate Issue",
        "description": "This issue has an estimate of zero which is not a valid positive integer.",
        "type": "task",
        "estimate": 0,
    }
    not validation.allow with input as issue
}

# Test 12: decision type is valid
test_decision_type_valid if {
    issue := {
        "title": "Permission Model ADR",
        "description": "Architectural decision record for the drop zone isolation and access control permission model.",
        "type": "decision",
        "priority": "P0",
    }
    validation.allow with input as issue
}

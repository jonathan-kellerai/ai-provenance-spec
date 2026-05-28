#!/usr/bin/env bash
#
# Sanitization regression gate.
#
# Fails if any internal term reaches the tracked, publishable tree. Both CI
# (.github/workflows/ci.yml) and the local pre-commit hook (lefthook.yml) run
# this script.
#
# The denylist is base64-encoded on purpose: a plaintext list of the internal
# terms would itself republish those strings into the public repository and be
# indexed by GitHub code search. Encoding the list closes that gap.
#
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# base64-encoded, newline-separated denylist of internal terms.
DENYLIST_B64="S2VsbGVyQUkKa2VsbGVyYWktZGV2LW1hcmtldHBsYWNlCm1lcmxpbi1jb25kb3IKc29uLW9mLWFudG9uCnRoZWJhY2tlbmQuY2FzaApqb25hdGhhbnNfbWFjYm9vawo="

fail=0
while IFS= read -r term; do
  [ -z "$term" ] && continue
  hits=$(git ls-files -z \
    | xargs -0 grep -lFI -e "$term" /dev/null 2>/dev/null || true)
  if [ -n "$hits" ]; then
    fail=1
    echo "SANITIZATION FAILURE: an internal term appears in these tracked files:"
    printf '%s\n' "$hits" | sed 's/^/  /'
  fi
done < <(printf '%s' "$DENYLIST_B64" | base64 --decode)

if [ "$fail" -ne 0 ]; then
  echo
  echo "Sanitization gate FAILED. Remove the flagged content before committing."
  exit 1
fi
echo "Sanitization gate passed: no internal terms in tracked files."

#!/usr/bin/env bash
# check-publish-gate.sh — verify publish prerequisites before `gh repo create`.
#
# Aegis Drop's README cross-links the companion repo `matryoshka-spec`.
# Publishing Aegis Drop while that link 404s gives every cold-landing reader
# a broken first impression. This script enforces the gate.
#
# Exit codes:
#   0 = publish-safe (companion repo is live)
#   1 = blocked (companion repo not yet live, or other gate failure)
#   2 = configuration error (curl missing, etc.)

set -euo pipefail

COMPANION_URL="https://github.com/jonathan-kellerai/matryoshka-spec"

command -v curl >/dev/null || { echo "ERROR: curl not found" >&2; exit 2; }

http_status=$(curl -sS -o /dev/null -w "%{http_code}" -L "$COMPANION_URL" || echo "000")

case "$http_status" in
  200)
    echo "OK: companion repo is live ($COMPANION_URL)"
    echo "Publish gate cleared. Safe to run \`gh repo create\`."
    exit 0
    ;;
  404)
    echo "BLOCKED: companion repo not yet live ($COMPANION_URL returns 404)"
    echo "Publish matryoshka-spec first, then re-run this gate." >&2
    exit 1
    ;;
  000)
    echo "ERROR: could not reach github.com — check network" >&2
    exit 2
    ;;
  *)
    echo "BLOCKED: unexpected HTTP $http_status from $COMPANION_URL" >&2
    exit 1
    ;;
esac

#!/usr/bin/env bash
set -euo pipefail

# Lockstep guard: the four behavior files must be byte-identical across
# the claude/ and codex/ variants. Variant-specific material lives only
# in the per-variant README.md and codex/devplan/agents/.
# Run: bash tests/test_lockstep.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

echo "=== Lockstep tests ==="

for f in SKILL.md DESIGN.md TDD.md IDD.md; do
    if diff -q "$REPO_ROOT/claude/devplan/$f" "$REPO_ROOT/codex/devplan/$f" >/dev/null 2>&1; then
        echo "  PASS: $f identical across variants"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $f differs between claude/ and codex/ — edit once, sync both:"
        diff "$REPO_ROOT/claude/devplan/$f" "$REPO_ROOT/codex/devplan/$f" | head -10
        FAIL=$((FAIL + 1))
    fi
done

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
    exit 1
fi

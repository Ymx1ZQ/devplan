#!/usr/bin/env bash
set -euo pipefail

# Test suite for install.sh — local mode and remote mode
# Run: bash tests/test_install.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SH="$REPO_ROOT/install.sh"
PASS=0
FAIL=0

# --- helpers ---

setup_fake_home() {
    local dir
    dir="$(mktemp -d)"
    echo "$dir"
}

cleanup() {
    local dir="$1"
    rm -rf "$dir"
}

create_snapshot_repo() {
    local snapshot_root snapshot_repo
    snapshot_root="$(mktemp -d)"
    snapshot_repo="$snapshot_root/repo"
    cp -R "$REPO_ROOT" "$snapshot_repo"
    rm -rf "$snapshot_repo/.git"
    (
        cd "$snapshot_repo"
        git init -q
        git config user.name "devplan-test"
        git config user.email "devplan-test@example.com"
        git add -A
        git commit -qm "snapshot"
    )
    echo "$snapshot_root"
}

assert_dir_exists() {
    local path="$1" label="$2"
    if [ -d "$path" ]; then
        echo "  PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label — directory not found: $path"
        FAIL=$((FAIL + 1))
    fi
}

assert_file_exists() {
    local path="$1" label="$2"
    if [ -f "$path" ]; then
        echo "  PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label — file not found: $path"
        FAIL=$((FAIL + 1))
    fi
}

assert_file_not_exists() {
    local path="$1" label="$2"
    if [ ! -f "$path" ]; then
        echo "  PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label — file should not exist: $path"
        FAIL=$((FAIL + 1))
    fi
}

assert_files_identical() {
    local dir1="$1" dir2="$2" label="$3"
    local diff_out
    diff_out="$(diff -rq "$dir1" "$dir2" 2>&1)" || true
    if [ -z "$diff_out" ]; then
        echo "  PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label — differences found:"
        echo "$diff_out" | head -10
        FAIL=$((FAIL + 1))
    fi
}

assert_exit_zero() {
    local label="$1"
    shift
    if "$@" >/dev/null 2>&1; then
        echo "  PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label — command exited non-zero"
        FAIL=$((FAIL + 1))
    fi
}

assert_cmd_output() {
    # Run a command, assert expected exit code AND that output contains a string.
    local expected_exit="$1" needle="$2" label="$3"
    shift 3
    local out rc=0
    out="$("$@" 2>&1)" || rc=$?
    if [ "$rc" -eq "$expected_exit" ] && printf "%s" "$out" | grep -q "$needle"; then
        echo "  PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label — exit=$rc (expected $expected_exit), output:"
        printf "%s\n" "$out" | head -5
        FAIL=$((FAIL + 1))
    fi
}

assert_no_temp_dirs() {
    local pattern="$1" label="$2"
    local found
    found="$(find /tmp -maxdepth 1 -name "$pattern" -type d 2>/dev/null | head -1)"
    if [ -z "$found" ]; then
        echo "  PASS: $label"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $label — temp dir still exists: $found"
        FAIL=$((FAIL + 1))
    fi
}

# --- LOCAL MODE tests ---

echo "=== Local mode tests ==="

echo "--- T1: local install claude ---"
FAKE_HOME="$(setup_fake_home)"
HOME="$FAKE_HOME" bash "$INSTALL_SH" --force claude
assert_dir_exists "$FAKE_HOME/.claude/skills/devplan" "claude dir installed"
assert_file_exists "$FAKE_HOME/.claude/skills/devplan/SKILL.md" "SKILL.md present"
assert_file_exists "$FAKE_HOME/.claude/skills/devplan/TDD.md" "TDD.md present"
assert_file_exists "$FAKE_HOME/.claude/skills/devplan/IDD.md" "IDD.md present"
assert_file_exists "$FAKE_HOME/.claude/skills/devplan/DESIGN.md" "DESIGN.md present"
assert_file_exists "$FAKE_HOME/.claude/skills/devplan/README.md" "README.md present"
cleanup "$FAKE_HOME"

echo "--- T2: local install codex ---"
FAKE_HOME="$(setup_fake_home)"
HOME="$FAKE_HOME" bash "$INSTALL_SH" --force codex
assert_dir_exists "$FAKE_HOME/.codex/skills/devplan" "codex dir installed"
assert_file_exists "$FAKE_HOME/.codex/skills/devplan/SKILL.md" "SKILL.md present"
assert_file_exists "$FAKE_HOME/.codex/skills/devplan/agents/openai.yaml" "agents/openai.yaml present"
cleanup "$FAKE_HOME"

echo "--- T3: local install all ---"
FAKE_HOME="$(setup_fake_home)"
HOME="$FAKE_HOME" bash "$INSTALL_SH" --force all
assert_dir_exists "$FAKE_HOME/.claude/skills/devplan" "claude dir installed"
assert_dir_exists "$FAKE_HOME/.codex/skills/devplan" "codex dir installed"
cleanup "$FAKE_HOME"

echo "--- T4: local install default (no target = all) ---"
FAKE_HOME="$(setup_fake_home)"
HOME="$FAKE_HOME" bash "$INSTALL_SH" --force
assert_dir_exists "$FAKE_HOME/.claude/skills/devplan" "claude dir installed (default)"
assert_dir_exists "$FAKE_HOME/.codex/skills/devplan" "codex dir installed (default)"
cleanup "$FAKE_HOME"

# --- REMOTE MODE tests ---
# Simulate remote mode by copying install.sh to an isolated dir (no source dirs nearby)
# and pointing DEVPLAN_REPO_URL at the local repo so git clone works without network.

echo ""
echo "=== Remote mode tests ==="

SNAPSHOT_ROOT="$(create_snapshot_repo)"
SNAPSHOT_REPO="$SNAPSHOT_ROOT/repo"

echo "--- T5: remote mode detects missing source dirs and clones ---"
FAKE_HOME="$(setup_fake_home)"
ISOLATED="$(mktemp -d)"
cp "$INSTALL_SH" "$ISOLATED/install.sh"
HOME="$FAKE_HOME" DEVPLAN_REPO_URL="$SNAPSHOT_REPO" bash "$ISOLATED/install.sh" --force claude
assert_dir_exists "$FAKE_HOME/.claude/skills/devplan" "claude dir installed via remote mode"
assert_file_exists "$FAKE_HOME/.claude/skills/devplan/SKILL.md" "SKILL.md present (remote)"
assert_file_exists "$FAKE_HOME/.claude/skills/devplan/TDD.md" "TDD.md present (remote)"
cleanup "$FAKE_HOME"
cleanup "$ISOLATED"

echo "--- T6: remote mode installs all ---"
FAKE_HOME="$(setup_fake_home)"
ISOLATED="$(mktemp -d)"
cp "$INSTALL_SH" "$ISOLATED/install.sh"
HOME="$FAKE_HOME" DEVPLAN_REPO_URL="$SNAPSHOT_REPO" bash "$ISOLATED/install.sh" --force all
assert_dir_exists "$FAKE_HOME/.claude/skills/devplan" "claude dir installed (remote all)"
assert_dir_exists "$FAKE_HOME/.codex/skills/devplan" "codex dir installed (remote all)"
cleanup "$FAKE_HOME"
cleanup "$ISOLATED"

echo "--- T7: remote mode cleans up temp dir ---"
# Pre-clean any leftover dirs from prior failed runs to avoid false positives
find "${TMPDIR:-/tmp}" -maxdepth 1 -name "devplan-install-*" -type d -exec rm -rf {} + 2>/dev/null || true
FAKE_HOME="$(setup_fake_home)"
ISOLATED="$(mktemp -d)"
cp "$INSTALL_SH" "$ISOLATED/install.sh"
HOME="$FAKE_HOME" DEVPLAN_REPO_URL="$SNAPSHOT_REPO" bash "$ISOLATED/install.sh" --force claude
# The script should not leave devplan-install-* dirs in /tmp
assert_no_temp_dirs "devplan-install-*" "no temp dirs left behind"
cleanup "$FAKE_HOME"
cleanup "$ISOLATED"

echo "--- T8: local and remote produce identical file trees ---"
LOCAL_HOME="$(setup_fake_home)"
REMOTE_HOME="$(setup_fake_home)"
ISOLATED="$(mktemp -d)"
cp "$INSTALL_SH" "$ISOLATED/install.sh"
HOME="$LOCAL_HOME" bash "$INSTALL_SH" --force all
HOME="$REMOTE_HOME" DEVPLAN_REPO_URL="$SNAPSHOT_REPO" bash "$ISOLATED/install.sh" --force all
assert_files_identical \
    "$LOCAL_HOME/.claude/skills/devplan" \
    "$REMOTE_HOME/.claude/skills/devplan" \
    "claude variant identical (local vs remote)"
assert_files_identical \
    "$LOCAL_HOME/.codex/skills/devplan" \
    "$REMOTE_HOME/.codex/skills/devplan" \
    "codex variant identical (local vs remote)"
cleanup "$LOCAL_HOME"
cleanup "$REMOTE_HOME"
cleanup "$ISOLATED"
cleanup "$SNAPSHOT_ROOT"

# --- DRIFT CHECK tests (--check) ---

echo ""
echo "=== Drift check tests ==="

echo "--- T9: --check clean after fresh install ---"
FAKE_HOME="$(setup_fake_home)"
HOME="$FAKE_HOME" bash "$INSTALL_SH" --force all
assert_cmd_output 0 "OK" "--check exits 0 and reports OK on a fresh install" \
    env HOME="$FAKE_HOME" bash "$INSTALL_SH" --check all
cleanup "$FAKE_HOME"

echo "--- T10: --check detects a modified installed file ---"
FAKE_HOME="$(setup_fake_home)"
HOME="$FAKE_HOME" bash "$INSTALL_SH" --force all
echo "local hand-edit" >> "$FAKE_HOME/.claude/skills/devplan/TDD.md"
assert_cmd_output 1 "DRIFT" "--check exits 1 and reports DRIFT on a hand-edited file" \
    env HOME="$FAKE_HOME" bash "$INSTALL_SH" --check all
cleanup "$FAKE_HOME"

echo "--- T11: --check reports a missing install ---"
FAKE_HOME="$(setup_fake_home)"
assert_cmd_output 1 "DRIFT" "--check exits 1 when the skill is not installed" \
    env HOME="$FAKE_HOME" bash "$INSTALL_SH" --check claude
cleanup "$FAKE_HOME"

# --- summary ---

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
    exit 1
fi

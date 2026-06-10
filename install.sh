#!/usr/bin/env bash
set -euo pipefail

# devplan skill installer
# Copies the skill files into the target tool's skill directory.
#
# Local mode:  ./install.sh [OPTIONS] [TARGET]
# Remote mode: bash <(curl -fsSL https://raw.githubusercontent.com/OWNER/devplan/main/install.sh)

REPO_URL="${DEVPLAN_REPO_URL:-https://github.com/kiso-run/devplan.git}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FORCE=false
CLEANUP_DIR=""

cleanup_temp() {
    if [ -n "$CLEANUP_DIR" ] && [ -d "$CLEANUP_DIR" ]; then
        rm -rf "$CLEANUP_DIR"
    fi
}
trap cleanup_temp EXIT

# Detect local vs remote mode
if [ -d "$SCRIPT_DIR/claude/devplan" ] && [ -d "$SCRIPT_DIR/codex/devplan" ]; then
    # Local mode — source dirs exist next to the script
    SRC_ROOT="$SCRIPT_DIR"
else
    # Remote mode — clone the repo into a temp dir
    if ! command -v git >/dev/null 2>&1; then
        echo "Error: git is required for remote install." >&2
        exit 1
    fi
    CLEANUP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/devplan-install-XXXXXX")"
    echo "Cloning devplan into temporary directory..."
    git clone --depth 1 --quiet "$REPO_URL" "$CLEANUP_DIR/devplan"
    SRC_ROOT="$CLEANUP_DIR/devplan"
fi

CLAUDE_SRC="$SRC_ROOT/claude/devplan"
CODEX_SRC="$SRC_ROOT/codex/devplan"

CLAUDE_DEST="$HOME/.claude/skills/devplan"
CODEX_DEST="$HOME/.codex/skills/devplan"

usage() {
    cat <<'EOF'
Usage: ./install.sh [OPTIONS] [TARGET]

TARGET:
  claude    Install the Claude Code variant only
  codex     Install the Codex variant only
  all       Install both variants (default)

OPTIONS:
  --force   Overwrite existing installation without prompting
  --check   Compare installed copies against the source tree (no writes);
            exits 1 and reports DRIFT if they differ or are missing
  --help    Show this help message
EOF
}

check_variant() {
    local src="$1"
    local dest="$2"
    local name="$3"

    if [ ! -d "$dest" ]; then
        echo "DRIFT: $name is not installed at $dest"
        return 1
    fi

    local diff_out
    diff_out="$(diff -r "$src" "$dest" 2>&1)" || true
    if [ -n "$diff_out" ]; then
        echo "DRIFT: $name at $dest differs from the source tree:"
        echo "$diff_out" | head -10
        return 1
    fi

    echo "OK: $name matches the source tree ($dest)"
    return 0
}

confirm_overwrite() {
    local dest="$1"
    local name="$2"
    if [ -d "$dest" ] && [ "$FORCE" != true ]; then
        printf "%s already exists at %s\nOverwrite? [y/N] " "$name" "$dest"
        read -r reply
        if [[ ! "$reply" =~ ^[Yy]$ ]]; then
            echo "Skipping $name."
            return 1
        fi
    fi
    return 0
}

install_variant() {
    local src="$1"
    local dest="$2"
    local name="$3"

    if [ ! -d "$src" ]; then
        echo "Error: source directory not found: $src" >&2
        return 1
    fi

    if ! confirm_overwrite "$dest" "$name"; then
        return 0
    fi

    mkdir -p "$(dirname "$dest")"
    rm -rf "$dest"
    cp -r "$src" "$dest"

    echo "Installed $name → $dest"
}

# Parse arguments
TARGET="all"
CHECK=false
for arg in "$@"; do
    case "$arg" in
        --force)  FORCE=true ;;
        --check)  CHECK=true ;;
        --help)   usage; exit 0 ;;
        claude)   TARGET="claude" ;;
        codex)    TARGET="codex" ;;
        all)      TARGET="all" ;;
        *)
            echo "Unknown argument: $arg" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [ "$CHECK" = true ]; then
    STATUS=0
    case "$TARGET" in
        claude)
            check_variant "$CLAUDE_SRC" "$CLAUDE_DEST" "devplan (Claude Code)" || STATUS=1
            ;;
        codex)
            check_variant "$CODEX_SRC" "$CODEX_DEST" "devplan (Codex)" || STATUS=1
            ;;
        all)
            check_variant "$CLAUDE_SRC" "$CLAUDE_DEST" "devplan (Claude Code)" || STATUS=1
            check_variant "$CODEX_SRC" "$CODEX_DEST" "devplan (Codex)" || STATUS=1
            ;;
    esac
    exit "$STATUS"
fi

# Install
case "$TARGET" in
    claude)
        install_variant "$CLAUDE_SRC" "$CLAUDE_DEST" "devplan (Claude Code)"
        ;;
    codex)
        install_variant "$CODEX_SRC" "$CODEX_DEST" "devplan (Codex)"
        ;;
    all)
        install_variant "$CLAUDE_SRC" "$CLAUDE_DEST" "devplan (Claude Code)"
        install_variant "$CODEX_SRC" "$CODEX_DEST" "devplan (Codex)"
        ;;
esac

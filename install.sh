#!/usr/bin/env bash
set -euo pipefail

# devplan skill installer
# Copies the skill files into the target tool's skill directory.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CLAUDE_SRC="$SCRIPT_DIR/claude/devplan"
CODEX_SRC="$SCRIPT_DIR/codex/devplan"

CLAUDE_DEST="$HOME/.claude/skills/devplan"
CODEX_DEST="$HOME/.codex/skills/devplan"

FORCE=false

usage() {
    cat <<'EOF'
Usage: ./install.sh [OPTIONS] [TARGET]

TARGET:
  claude    Install the Claude Code variant only
  codex     Install the Codex variant only
  all       Install both variants (default)

OPTIONS:
  --force   Overwrite existing installation without prompting
  --help    Show this help message
EOF
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
for arg in "$@"; do
    case "$arg" in
        --force)  FORCE=true ;;
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

#!/bin/bash
# Bootstrap Claude Code configuration on a new machine
# Usage: ~/.agents/bootstrap.sh [profile]
#   Profiles: local (default), vps, production

set -e

AGENTS_DIR="$HOME/.agents"
CLAUDE_DIR="$HOME/.claude"
PROFILE="${1:-local}"

echo "==> Setting up Claude Code configuration..."
echo "    Profile: $PROFILE"

# Validate profile
if [[ ! -f "$AGENTS_DIR/claude/profiles/$PROFILE.md" ]]; then
  echo "ERROR: Profile '$PROFILE' not found."
  echo "Available profiles:"
  ls -1 "$AGENTS_DIR/claude/profiles/" 2>/dev/null | sed 's/.md$//' | sed 's/^/  - /'
  exit 1
fi

# Clone or update agents repo
if [ -d "$AGENTS_DIR" ]; then
  echo "    Agents repo exists, pulling latest..."
  (cd "$AGENTS_DIR" && git pull --ff-only 2>/dev/null || echo "    (pull skipped - local changes)")
else
  echo "    Cloning agents repo..."
  git clone git@github.com:johnx25bd/.agents.git "$AGENTS_DIR"
fi

# Create ~/.claude directory if it doesn't exist
echo "==> Creating $CLAUDE_DIR directory..."
mkdir -p "$CLAUDE_DIR"

# Backup existing files if they're not already symlinks
backup_if_exists() {
  local path="$1"
  if [ -e "$path" ] && [ ! -L "$path" ]; then
    echo "    Backing up existing $(basename $path)..."
    mv "$path" "${path}.bak.$(date +%Y%m%d%H%M%S)"
  fi
}

backup_if_exists "$CLAUDE_DIR/CLAUDE.md"
backup_if_exists "$CLAUDE_DIR/commands"
backup_if_exists "$CLAUDE_DIR/rules"
backup_if_exists "$CLAUDE_DIR/profile"

# Create symlinks
echo "==> Creating symlinks..."
ln -sf "$AGENTS_DIR/claude/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
ln -sf "$AGENTS_DIR/claude/commands" "$CLAUDE_DIR/commands"
ln -sf "$AGENTS_DIR/rules" "$CLAUDE_DIR/rules"
ln -sf "$AGENTS_DIR/claude/profiles/$PROFILE.md" "$CLAUDE_DIR/profile"
ln -sf "$AGENTS_DIR/claude/hooks" "$CLAUDE_DIR/hooks"

# Copy settings.json if it doesn't exist (don't overwrite local customizations)
if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
  echo "==> Copying base settings.json..."
  cp "$AGENTS_DIR/claude/settings.json" "$CLAUDE_DIR/settings.json"
else
  echo "    settings.json exists, skipping (merge manually if needed)"
fi

echo ""
echo "==> Done! Claude Code is configured with profile: $PROFILE"
echo ""
echo "    Symlinks created:"
echo "      $CLAUDE_DIR/CLAUDE.md -> $AGENTS_DIR/claude/CLAUDE.md"
echo "      $CLAUDE_DIR/commands/ -> $AGENTS_DIR/claude/commands/"
echo "      $CLAUDE_DIR/rules/    -> $AGENTS_DIR/rules/"
echo "      $CLAUDE_DIR/profile   -> $AGENTS_DIR/claude/profiles/$PROFILE.md"
echo "      $CLAUDE_DIR/hooks/    -> $AGENTS_DIR/claude/hooks/"
echo ""
echo "    To switch profiles: ~/.agents/bootstrap.sh [local|vps|production]"
echo "    Run 'claude /memory' to verify configuration is loaded."

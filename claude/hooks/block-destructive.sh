#!/bin/bash
# Block Destructive Commands Hook
# Blocks dangerous commands that could cause irreversible damage
# Place in hooks.PreToolUse with tool_name: Bash

# Commands that are ALWAYS blocked (user must run manually)
BLOCKED_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \$HOME"
  "git reset --hard"
  "git clean -fd"
  "git push.*--force"
  "git push -f"
  "DROP DATABASE"
  "DROP TABLE"
  "TRUNCATE"
  ":(){ :|:& };:"  # fork bomb
)

# Commands that require explicit confirmation (printed as warning)
WARN_PATTERNS=(
  "rm -rf"
  "rm -r"
  "git push"
  "docker system prune"
  "docker volume rm"
  "docker container prune"
  "sudo rm"
  "sudo systemctl stop"
  "sudo systemctl disable"
)

COMMAND="$1"

# Check blocked patterns
for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "BLOCKED: This command matches a blocked destructive pattern: $pattern" >&2
    echo "If you need to run this, do it manually in a terminal." >&2
    exit 2
  fi
done

# Check warning patterns (just log, don't block)
for pattern in "${WARN_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$pattern"; then
    echo "⚠️  CAUTION: Potentially destructive command detected: $pattern" >&2
    # Don't exit - let it through with warning
    break
  fi
done

exit 0

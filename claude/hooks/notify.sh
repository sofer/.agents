#!/bin/bash
# Notification hook for Claude Code
# Fires when Claude stops and needs user input
# Environment-aware: uses native notifications on macOS, terminal bell on headless
#
# Receives JSON on stdin with: session_id, cwd, notification_type, message, title

# Dependency check — at minimum ring the bell
if ! command -v jq &>/dev/null; then
  printf '\a'
  exit 1
fi

# Parse JSON from stdin
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type // empty')
MESSAGE=$(echo "$INPUT" | jq -r '.message // "Needs your attention"')

if [[ -z "$CWD" ]]; then
  PROJECT="unknown"
else
  PROJECT=$(basename "$CWD")
fi

SUBTITLE="$PROJECT"
if [[ -n "$NOTIFICATION_TYPE" ]]; then
  SUBTITLE="$PROJECT ($NOTIFICATION_TYPE)"
fi

# macOS — try native notifications (works even over SSH if GUI session exists)
if [[ "$(uname)" == "Darwin" ]]; then

  if command -v terminal-notifier &>/dev/null; then
    terminal-notifier \
      -title "Claude Code" \
      -subtitle "$SUBTITLE" \
      -message "$MESSAGE" \
      -sound default \
      -activate "com.mitchellh.ghostty" \
      2>/dev/null && exit 0
  fi

  # Fallback: osascript. Escape quotes to prevent injection.
  MSG_ESCAPED="${MESSAGE//\\/\\\\}"
  MSG_ESCAPED="${MSG_ESCAPED//\"/\\\"}"
  SUB_ESCAPED="${SUBTITLE//\\/\\\\}"
  SUB_ESCAPED="${SUB_ESCAPED//\"/\\\"}"

  if osascript -e "display notification \"$MSG_ESCAPED\" with title \"Claude Code\" subtitle \"$SUB_ESCAPED\"" 2>/dev/null; then
    exit 0
  fi
fi

# Inside tmux — show message in status bar (escape # for tmux)
if [[ -n "$TMUX" ]]; then
  TMUX_MSG=$(printf '%s' "Claude [$PROJECT]: $MESSAGE" | tr '\n' ' ' | sed 's/#/##/g')
  tmux display-message "$TMUX_MSG" 2>/dev/null
fi

# Terminal bell — works over SSH if client supports it
printf '\a'

# ntfy.sh (uncomment and set your topic to get push notifications on phone)
# NTFY_TOPIC="your-private-topic"
# curl -s -d "[$PROJECT] $MESSAGE" "https://ntfy.sh/$NTFY_TOPIC" >/dev/null 2>&1

exit 0

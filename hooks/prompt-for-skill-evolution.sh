#!/usr/bin/env bash
# Throttled reminder for the skill-evolution skill.
# Fires no more than once per THROTTLE_SECS to avoid noise.

set -uo pipefail

STATE_FILE="$HOME/.agents/.last-skill-evolution-prompt"
THROTTLE_SECS=300

cat > /dev/null

now=$(date +%s)
last=0
if [ -f "$STATE_FILE" ]; then
  last=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
fi

if (( now - last < THROTTLE_SECS )); then
  exit 0
fi

echo "$now" > "$STATE_FILE"

cat <<'JSON'
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Reminder: if the recent exchange revealed reusable workflow friction, a user correction about agent behaviour, or a possible skill improvement, briefly mention it and offer to log it with the skill-evolution skill. Otherwise stay silent."
  }
}
JSON

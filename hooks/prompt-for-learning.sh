#!/usr/bin/env bash
# Throttled reminder for the /learning skill.
# Fires no more than once per THROTTLE_SECS to avoid noise.

set -uo pipefail

STATE_FILE="$HOME/.agents/.last-learning-prompt"
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
    "additionalContext": "Reminder: if the most recent exchange surfaced anything genuinely worth remembering, such as a non-obvious fix, a tool quirk, a useful pattern, or an insight, briefly mention it to the user and offer to capture it via the /learning skill. Otherwise stay silent on this. Do not capture trivia, routine progress, or things obvious from reading the code."
  }
}
JSON

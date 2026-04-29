#!/bin/bash
# Pre-commit code review hook
# Runs as a separate review process with no access to current context.
# Sees only the staged diff and can read the repo.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only intercept git commit commands
if [[ "$COMMAND" != *"git commit"* ]]; then
    exit 0
fi

# Skip if --no-verify flag (user explicitly bypassing)
if [[ "$COMMAND" == *"--no-verify"* ]]; then
    exit 0
fi

# Get staged diff
DIFF=$(git diff --cached)
if [[ -z "$DIFF" ]]; then
    exit 0
fi

# Truncate very large diffs to avoid token limits
DIFF_LINES=$(echo "$DIFF" | wc -l)
if [[ "$DIFF_LINES" -gt 500 ]]; then
    DIFF=$(echo "$DIFF" | head -500)
    DIFF="$DIFF

... (truncated, ${DIFF_LINES} total lines)"
fi

PROMPT="You are a code reviewer. Review this git diff for:
1. Security vulnerabilities (injection, exposed secrets, unsafe operations)
2. Bugs (logic errors, off-by-one, null handling, race conditions)
3. Obvious mistakes (typos in logic, wrong variable names, missing imports)

Do NOT comment on style, formatting, naming conventions, or documentation.
Only flag genuine problems that would cause incorrect behaviour or security issues.

If the code looks good, respond with exactly: LGTM
If there are real issues, describe each one briefly (one line per issue)."

run_review() {
    if [[ -n "${AGENT_REVIEW_COMMAND:-}" ]]; then
        echo "$DIFF" | $AGENT_REVIEW_COMMAND "$PROMPT"
        return
    fi

    if command -v claude >/dev/null 2>&1; then
        echo "$DIFF" | CLAUDECODE= claude -p "$PROMPT"
        return
    fi

    echo "LGTM"
}

REVIEW=$(run_review 2>/dev/null || true)

# Check result
if echo "$REVIEW" | grep -q "LGTM"; then
    echo "Code review passed." >&2
    exit 0
else
    echo "Code review found issues:" >&2
    echo "$REVIEW" >&2
    echo "" >&2
    echo "Fix the issues above, or use --no-verify to bypass." >&2
    exit 2
fi

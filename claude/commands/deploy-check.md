# Pre-Deploy Checklist

Run a verification checklist before deploying.

## Checks

1. Type-checker passes (`tsc --noEmit` or equivalent)
2. All tests pass locally
3. Docker build succeeds (if applicable)
4. Review deployment scripts in `scripts/` for required env vars
5. Summarize what will be deployed and where

## Output

Show a go/no-go summary with any blockers identified.

Target: $ARGUMENTS

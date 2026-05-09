# Command permission policy

This is the shared source of truth for command-permission intent across agent providers. Provider-specific runtime permissions are the enforcement layer. If this policy conflicts with a provider permission file, sandbox, or session approval state, the provider-specific rule wins.

Keep provider adapters aligned with this policy where possible, but do not bypass provider safety checks. Use `agent-config-audit` to check drift between this policy and provider-specific config.

## Default allow for local development

Agents may proceed without repeated permission for ordinary local work needed to complete an agreed task:

- Inspect files, git state, package scripts, logs, and local process state.
- Edit files inside the agreed scope.
- Run tests, builds, typechecks, linters, formatters, and local smoke checks.
- Start, stop, and inspect local dev servers and local Docker Compose services.
- Use non-destructive local git operations, including branch creation, checkout, merge, add, commit, and amend.
- Update local task-tracking records when the user has asked for the task to be completed and the update is non-sensitive.

## Ask before

Agents should pause before actions with external side effects, high risk, or ambiguous ownership:

- Push to shared branches, unless the agreed plan explicitly includes that push.
- Deploy, restart, or change production infrastructure.
- Write to production data or shared external systems.
- Send real emails, messages, notifications, comments, or customer-facing requests.
- Install, remove, or upgrade dependencies.
- Change secrets, auth, payments, permissions, or billing.
- Edit global agent resources, hooks, skills, provider config, or this policy, unless the user explicitly requested agent-resource work.
- Cross repo ownership boundaries not implied by the task.

## Require explicit confirmation

Agents must get explicit confirmation for irreversible or destructive actions:

- Force push or rewrite shared history.
- `git reset --hard`, checkout/revert that discards user work, or branch deletion.
- Broad deletion commands.
- Commands that could expose, print, commit, or transmit secrets.
- Production data deletion, bulk mutation, or migration outside an agreed deploy plan.

## Plan interpretation

If an agent proposes a clear numbered plan and the user says "go for it", that authorises every step explicitly listed in the plan. If the plan includes a push to a shared branch, that counts as push permission. If the plan does not mention pushing, ask before pushing.

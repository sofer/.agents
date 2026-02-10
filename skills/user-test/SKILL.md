---
name: user-test
description: Reformat code-review manual test script for human or agent execution, run user testing checkpoint, and record pass/fail results. Gates progression to commit:pr.
---

# User test

Reformat the manual test script from code-review into an executable format, present it for testing, and record the results. Sits between commit:commit(refactor) and commit:pr in the pipeline.

## Purpose

Code-review produces a `manual_test_script` (structured action/expect pairs per scenario). That format is useful for reading in a table, but not optimised for pasting into a browser or CLI agent. This skill reformats the test script for the user's preferred executor without coupling code-review to any specific tool.

## Input

Expect from orchestrator:
- `manual_test_script` from code-review output (YAML with setup, scenarios, steps)
- Story ID and title
- Project run config (from `.sdlc/manifest.yaml`)

## Format selection

Ask the user which format they prefer:

- **human** (default) — markdown checklist the user works through manually
- **agent** — natural-language prose instructions that can be pasted into any AI agent (browser extension, CLI agent, etc.)

If the project run config specifies `user_test_format`, use that value without asking.

## Formatting rules

### Human format

Convert each scenario into a markdown checklist with setup instructions at the top:

```markdown
## Manual test: {story-id} - {story-title}

### Setup
{setup instructions from manual_test_script}

### Scenario: {scenario name}
- [ ] {action} — expected: {expected result}
- [ ] {action} — expected: {expected result}

### Scenario: {scenario name}
- [ ] {action} — expected: {expected result}
```

### Agent format

Convert each scenario into continuous prose. Do not name specific tools or agents. The output should read as a sequence of instructions any agent can follow:

```
Test the following for story {story-id} ({story-title}).

Setup: {setup instructions}

Scenario: {scenario name}
{action sentence}. {expect sentence}. {action sentence}. {expect sentence}.

Scenario: {scenario name}
{action sentence}. {expect sentence}.
```

Example transformation from structured data:

```yaml
- action: "Click Login in the navigation bar"
  expect: "Login form appears"
- action: "Enter user@example.com in email and password123 in password"
  expect: "Fields are populated"
- action: "Click Submit"
  expect: "Redirected to dashboard with name in header"
```

Becomes:

> Click "Login" in the navigation bar. Verify that the login form appears. Enter "user@example.com" in the email field and "password123" in the password field. Verify that the fields are populated. Click "Submit". Verify that you are redirected to the dashboard and your name appears in the header.

Key rules for agent format:
- Join actions and expectations into flowing sentences
- Prefix expected outcomes with "Verify that" to distinguish observations from actions
- Keep all detail (URLs, credentials, field names) from the original steps
- Do not reference any specific tool, browser extension, or agent by name

## Process

1. Load `manual_test_script` from code-review output
2. Determine format (from config or by asking user)
3. Reformat test script into chosen format
4. Present formatted test script to user
5. Wait for user to complete testing
6. Record pass/fail per scenario
7. Determine overall gate status

## Output

Store results at `.sdlc/stories/{story-id}/user-test-results.yaml`:

```yaml
user_test:
  story_id: "US-001"
  format: "human | agent"
  scenarios:
    - name: "Happy path login"
      status: "pass | fail"
      notes: ""
    - name: "Invalid credentials"
      status: "pass | fail"
      notes: ""
  verdict: "pass | fail"
  tested_by: "user"
  timestamp: "2024-01-15T10:30:00Z"
```

## Gate condition

All scenarios must pass before advancing to commit:pr. If any scenario fails, the story returns to implement for fixes.

## Checkpoint behaviour

This phase is a configured checkpoint. After testing:

1. Present results summary to user
2. If all pass: proceed to commit:pr
3. If any fail: return to implement with failure details
4. User may re-run specific scenarios after fixes

### Results prompt

```
## User test results: {story-id} - {story-title}

| Scenario | Status | Notes |
|----------|--------|-------|
| {name}   | {pass/fail} | {notes} |

**Verdict:** {pass/fail}

{If pass:} Ready to create PR. Proceed? [y/n]
{If fail:} {count} scenario(s) failed. Returning to implement phase with details.
```

## Tips

- Derive setup from the project README rather than duplicating it
- For agent format, keep instructions tool-agnostic so they work with any executor
- If no manual test script exists in code-review output, fall back to the story's acceptance criteria to build test steps
- Record notes for failed scenarios to provide context when returning to implement

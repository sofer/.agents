---
name: end-to-end-verification
description: Verify public-facing user flows before release or production push, especially flows involving email, authentication links, multi-step forms, generated links, or records that users will interact with.
---

# End-to-end verification

## Purpose

Verify the complete user chain, not just the individual pieces.

## When to use

Use before release or production push for:
- Email delivery, invitations, notifications, or magic links.
- Authentication links or token-based access.
- Multi-step flows where one step creates input for the next.
- Public-facing forms or workflows used by people outside the team.
- Features that create records, links, drafts, or messages that users will interact with.

## Safety

- Ask before sending real emails, using real customer data, touching production data, or calling customer-facing APIs.
- Prefer local or staging verification first.
- Use a real email address controlled by the user when feasible.
- If production verification is required, define the smallest safe test and get explicit confirmation before running it.

## Process

1. Write the complete chain from trigger to final user outcome.
2. Identify the systems involved: frontend, API, worker, database, email provider, auth, external services.
3. Create or reuse a safe test account and test data.
4. Walk the chain exactly as a user would.
5. Verify side effects after each step, including database state, generated links, tokens, email content, redirects, and final page state.
6. Record what was verified, what could not be verified, and what remains risky.
7. If any step fails or cannot be meaningfully verified, do not call the feature ready.

## Red flags

Stop if you catch yourself thinking:
- "The email template looks correct, so it will work."
- "The API creates the record, so the rest is standard."
- "I tested the UI and API separately, so the chain works."
- "The worker will handle it in production."
- "I cannot test this locally, but it should be fine."

## Output

Report:
- Chain tested.
- Environment used.
- Test account or fixture used, without exposing sensitive details.
- Steps passed.
- Steps failed or unverified.
- Remaining release or deploy risk.


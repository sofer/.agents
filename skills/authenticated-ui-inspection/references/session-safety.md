# Authenticated session safety

Use this reference when a site requires cookies, magic links, or tokens.

## Preferred authentication methods

1. User completes login manually in the in-app browser.
2. Existing local browser profile is used by an approved browser tool.
3. User approves reading a local cookie store or env file. Do not print values.

Avoid pasting secrets into chat. Avoid storing copied cookies in repo files, reports, screenshots, or logs.

## Verification

After authentication, verify with a low-risk page:

- dashboard
- account page
- "me" endpoint
- page header showing user role or name

Record only non-secret facts, such as role, visible page title, and target URL.

## Reporting

Separate:

- observed UI facts
- data-derived facts
- code-derived inferences
- unverified hypotheses

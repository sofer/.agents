# Agent resources

Help the user use AI agents deliberately: build effective workflows, collaborate on high-quality software, and preserve lessons that improve future work.

## Agent-agnostic content

- Keep this file provider-neutral: refer to `AGENTS.md`, never provider-specific instruction files, paths, assistants, or boilerplate.
- If provider-specific content is found in this file, remove it as part of the edit.
- Keep durable operating rules here; put long explanations, tool-specific setup, and detailed procedures in skills or linked docs.
- Do not modify `~/.agents/AGENTS.md`, global skills, hooks, or config unless the user explicitly asks to work on agent resources.

## Default workflow

- Before non-trivial work, inspect relevant repo instructions, README files, package scripts, existing tests, and available skills.
- For non-trivial work, inspect first, then grill the user until the goal, scope, non-goals, risks, ownership boundaries, and verification plan are clear enough to build safely.
- Use minimum viable grilling for ordinary work, and full grilling for ambiguous, high-risk, architectural, data, auth, email, payment, production, public API, or cross-app work.
- Record the shared understanding before implementation: use chat for small work, a lightweight repo plan/spec for non-trivial platform work or major personal work, and a fuller spec for cross-cutting work.
- Ask only when the answer affects correctness, risk, scope, ownership, external side effects, or irreversible choices; otherwise make a reasonable assumption, state it briefly if relevant, and proceed.
- When the user asks to move quickly, take the narrowest safe path, avoid broad changes, verify the result, and still stop for high-risk or external side-effect decisions.

## Skill use

- Review available skills before responding when a skill may be relevant.
- For substantive use of a non-system skill, record usage with `skill-usage`; do not log sensitive content.
- Use `problem-statement` when the request is vague or would fail if handed directly to an executor.
- Use `constrain` when failure modes, delegation, platform safety, or technically-correct-but-wrong outcomes matter.
- Use `decompose` when the work is too large for one coherent implementation slice.
- Use `evaluate` when defining done, test strategy, or a reusable quality check.
- Announce skill use briefly when it affects the workflow; do not make routine skill selection noisy.

## Engineering principles

- Prefer Ousterhout-style deep modules: solve substantial problems behind small, stable interfaces, and avoid leaking complexity across boundaries.
- Prefer repo conventions, local package scripts, structured APIs, and fast search tools such as `rg`.
- Avoid unrelated refactors, broad formatting churn, file moves, and dependency changes unless they are part of the agreed task.
- Do not add, remove, or upgrade dependencies without explicit approval unless the user specifically requested that dependency change.
- For behaviour changes and bug fixes, prefer test-first or regression-test-first work where practical.
- Preserve existing user work: inspect git status before edits, do not revert or overwrite changes you did not make, and ask if existing changes block the task.

## Platform mode: `~/code/fac-cra/`

- In `~/code/fac-cra/`, prioritise minimising disruption to the CTO's fast-moving work: avoid broad changes, preserve shared workflows, verify heavily, and surface shared-boundary impact.
- The user's current autonomous edit areas are `apps/distribution/`, `apps/partners/`, `api/domains/distribution/`, and `api/domains/partners/`.
- Treat `api/schema.gql`, API registration, migrations, package config, shared packages, deployment config, auth, and shared abstractions as shared-boundary work: touch only when directly required, explain why, and verify heavily.
- Ask before editing outside Distribution or Partners ownership boundaries unless the user explicitly requested that area.
- For platform work, prioritise improving the test harness when verification is weak, including focused fixtures, mocks, regression tests, and end-to-end coverage.
- For registration, email, authentication links, or multi-step user flows, use the `end-to-end-verification` skill before release or production push; test the complete chain with a real email address when feasible.
- Before calling platform work done, run relevant unit tests, typecheck/lint, app build, Playwright or end-to-end smoke tests, and browser checks when feasible.
- Never push to production or shared protected branches without explicit confirmation.
- Platform final responses must state whether the change stayed within Distribution/Partners boundaries, list any shared files touched and why, summarise verification, and note remaining deploy risk.

## Personal projects

- For personal projects, optimise by default for learning, secure foundations, maintainability, and clean design over raw speed.
- Allow the user to choose a faster or more exploratory path when they say so.
- Use pragmatic verification for prototypes, and strengthen tests as behaviour becomes important or persistent.

## Safety and side effects

- Treat auth, secrets, permissions, payments, email, personal data, production data, and deployment as high-risk.
- Ask before changing high-risk flows unless the user explicitly requested that exact change.
- Never expose secrets, commit credentials, or use real customer data unnecessarily.
- Ask before running workflows that affect external systems: sending emails, charging money, deploying, changing production or shared data, posting comments, creating PRs/issues, or calling real customer-facing APIs.
- For autonomous runs, establish an explicit operating envelope before starting: scope, allowed files, permitted commands, verification expectations, external side-effect limits, and stop conditions.
- Ask before installing dependencies or generating large outputs; run relevant local tests and dev servers without asking unless they are known to be slow or disruptive.

## Stop conditions

- Stop if requirements conflict or the goal no longer matches the requested implementation.
- Stop before touching high-risk areas outside the agreed scope.
- Stop before production deploys, production data changes, real emails, secrets, billing, or other external side effects.
- Stop if meaningful verification is impossible and the change is risky.
- Stop if ownership boundaries are unclear in platform mode.

## Learning and memory

- Surface consequential tradeoffs briefly when they affect implementation, scope, risk, or verification.
- Do not turn routine edits into tutorials; when the user is learning, unsure, or asks why, slow down and explain the reasoning.
- At the end of substantial work, include one short "What to notice" note only when there is a reusable lesson.
- Offer to capture reusable personal preferences in `learning-log.md` or `~/.agents/AGENTS.md`, and repo-specific lessons in repo docs or repo `AGENTS.md`; ask before writing long-term memory.
- Consider turning repeated executable workflows into skills after they have proved useful more than once.

## Git workflow

- Check the repo's `AGENTS.md` for commit strategy before starting work.
- Repo-local instructions control project specifics, but global safety rules still apply.
- Never push directly to main or production unless the repo's `AGENTS.md` explicitly permits it and the user has confirmed it for this task.
- Never add `Co-Authored-By` or AI-tool attribution footers to commit messages or PR descriptions.

## Response behaviour

- Be concise in ordinary responses, and be more explicit during grilling, planning, risky changes, and learning mode.
- Challenge the requested approach when there is material risk of wasted work, security issues, product confusion, or a simpler path.
- For code work, final responses should include a concise summary, files changed, verification run, verification gaps, and any reusable lesson worth noticing.

## Writing style

- Use British English.
- Never use em dashes. Use commas, parentheses, full stops, or colons instead.
- Use sentence case for headers.

## Standards

- Follow [https://agentskills.io/](https://agentskills.io/) and [https://agents.md/](https://agents.md/).

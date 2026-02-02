---
name: spec
description: Define contracts, schemas, and behaviours for a single user story. Use after a story is selected from the backlog to create a detailed specification before design. Produces testable specifications.
---

# Specification

Define the contracts, schemas, and behaviours for a single user story before design begins.

## Input

Expect from orchestrator:
- Story ID and full details from backlog
- Intent output (for broader context)
- Project standards (paradigm, patterns, naming)
- Existing specs from related stories (if any)

## Process

### 1. Analyse the story

Review the user story and acceptance criteria:
- Identify the core capability being delivered
- Note the user persona and their goal
- Extract testable conditions from acceptance criteria

### 2. Define contracts

Identify all interfaces this story requires:

**API contracts** (if applicable):
```yaml
contracts:
  - name: "CreateUser"
    type: "api"
    method: "POST"
    path: "/users"
    request:
      body:
        email: "string (required)"
        name: "string (required)"
    response:
      success:
        status: 201
        body:
          id: "string"
          email: "string"
          name: "string"
          created_at: "datetime"
      errors:
        - status: 400
          condition: "Invalid email format"
        - status: 409
          condition: "Email already exists"
```

**Event contracts** (if applicable):
```yaml
  - name: "UserCreated"
    type: "event"
    payload:
      user_id: "string"
      email: "string"
      timestamp: "datetime"
    producer: "UserService"
    consumers: ["NotificationService", "AnalyticsService"]
```

**Internal contracts** (service boundaries):
```yaml
  - name: "UserRepository"
    type: "internal"
    methods:
      - name: "save"
        input: "User"
        output: "User"
        errors: ["DuplicateEmail", "ValidationError"]
      - name: "findByEmail"
        input: "string"
        output: "User | null"
```

### 3. Define data schemas

Specify all data structures:

```yaml
data_schemas:
  - name: "User"
    fields:
      - name: "id"
        type: "string (UUID)"
        required: true
        generated: true
      - name: "email"
        type: "string"
        required: true
        validation: "RFC 5322 email format"
        unique: true
      - name: "name"
        type: "string"
        required: true
        validation: "1-100 characters"
      - name: "created_at"
        type: "datetime (UTC)"
        required: true
        generated: true
    invariants:
      - "email must be lowercase"
      - "id is immutable after creation"
```

### 4. Define behaviours

Transform acceptance criteria into detailed behaviour specifications:

```yaml
behaviours:
  - scenario: "Successful user creation"
    given:
      - "No user exists with email 'test@example.com'"
    when:
      - "POST /users with valid email and name"
    then:
      - "Returns 201 with user object"
      - "User is persisted to database"
      - "UserCreated event is published"
      - "Response includes generated id and created_at"

  - scenario: "Duplicate email rejection"
    given:
      - "User exists with email 'existing@example.com'"
    when:
      - "POST /users with email 'existing@example.com'"
    then:
      - "Returns 409 Conflict"
      - "No new user is created"
      - "No event is published"
      - "Error message indicates email is taken"
```

### 5. Identify edge cases

Document edge cases and expected handling:

```yaml
edge_cases:
  - case: "Email with uppercase letters"
    input: "Test@Example.COM"
    expected: "Normalise to lowercase before validation and storage"

  - case: "Very long name at boundary"
    input: "100 character name..."
    expected: "Accept and store successfully"

  - case: "Name exceeds maximum"
    input: "101 character name..."
    expected: "Reject with 400 and validation error"

  - case: "Concurrent creation with same email"
    scenario: "Two requests arrive simultaneously"
    expected: "One succeeds, one fails with 409 (database constraint)"
```

### 6. Note assumptions and open questions

```yaml
assumptions:
  - "Email verification is handled by a separate story"
  - "Password/authentication is out of scope for this story"

open_questions:
  - question: "Should we support bulk user creation?"
    recommendation: "Defer to separate story if needed"
  - question: "What is the retention policy for user data?"
    recommendation: "Clarify with stakeholder"
```

## Output

Save specification to `.sdlc/stories/{story-id}/spec.md`:

```markdown
# Specification: US-001 - User Registration

## Story
As a new user, I want to create an account so that I can access the system.

## Contracts
[contracts as defined above]

## Data schemas
[schemas as defined above]

## Behaviours
[behaviours as defined above]

## Edge cases
[edge cases as defined above]

## Assumptions
[assumptions]

## Open questions
[questions requiring resolution]
```

Also update manifest:

```yaml
stories:
  US-001:
    artifacts:
      spec: ".sdlc/stories/US-001/spec.md"
```

## Validation

Before completing:

- [ ] Every acceptance criterion has at least one behaviour
- [ ] All data structures are fully specified with types and validations
- [ ] Error conditions are documented for all contracts
- [ ] Edge cases cover boundary conditions
- [ ] No implementation details (how) - only specifications (what)

## Tips

- Specs should be implementation-agnostic
- If you find yourself writing code, step back to "what" not "how"
- Behaviours map directly to test cases
- When uncertain about a detail, add it to open questions rather than assuming
- Contracts at service boundaries enable parallel development

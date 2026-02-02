---
name: design
description: Plan architecture and components for a single user story. Use after spec phase to create a technical design before implementation. Produces design documents that guide stubs and implementation.
---

# Design

Plan the architecture and components for implementing a user story.

## Input

Expect from orchestrator:
- Spec output (contracts, schemas, behaviours)
- Project standards (paradigm, patterns, forbidden patterns, naming)
- Existing codebase structure (file tree, key modules)
- Related designs from other stories (if applicable)

## Process

### 1. Analyse the spec

Review the specification:
- Identify all contracts to implement
- Note data schemas and their relationships
- List behaviours that must be supported
- Understand edge cases to handle

### 2. Survey existing code

Examine the codebase:
- Identify existing patterns in use
- Find related modules to integrate with
- Note naming conventions in practice
- Understand the current architecture

### 3. Select architecture pattern

Choose an appropriate pattern based on:
- Project standards (if specified)
- Complexity of the feature
- Integration requirements
- Team familiarity

Common patterns:
- **Layered**: Controller → Service → Repository
- **Hexagonal**: Ports and adapters, domain at centre
- **Clean**: Use cases, entities, interfaces
- **Event-driven**: Publishers, subscribers, handlers
- **CQRS**: Separate read and write models

Document rationale for selection.

### 4. Design components

For each component:

```yaml
components:
  - name: "UserController"
    type: "controller"
    responsibility: "Handle HTTP requests for user operations"
    location: "src/controllers/user.controller.ts"
    dependencies:
      - "UserService"
      - "ValidationMiddleware"
    public_interface:
      - "POST /users → createUser()"
      - "GET /users/:id → getUser()"

  - name: "UserService"
    type: "service"
    responsibility: "Orchestrate user business logic"
    location: "src/services/user.service.ts"
    dependencies:
      - "UserRepository"
      - "EventPublisher"
    public_interface:
      - "createUser(input: CreateUserInput): Promise<User>"
      - "findById(id: string): Promise<User | null>"

  - name: "UserRepository"
    type: "repository"
    responsibility: "Persist and retrieve user data"
    location: "src/repositories/user.repository.ts"
    dependencies:
      - "Database"
    public_interface:
      - "save(user: User): Promise<User>"
      - "findByEmail(email: string): Promise<User | null>"
```

### 5. Define interfaces

Specify precise interface definitions:

```yaml
interfaces:
  - name: "CreateUserInput"
    location: "src/types/user.types.ts"
    definition: |
      interface CreateUserInput {
        email: string;
        name: string;
      }

  - name: "UserService"
    location: "src/services/user.service.ts"
    definition: |
      interface UserService {
        createUser(input: CreateUserInput): Promise<User>;
        findById(id: string): Promise<User | null>;
        findByEmail(email: string): Promise<User | null>;
      }
```

### 6. Map data flow

Document how data moves through the system:

```yaml
data_flow:
  scenario: "User registration"
  steps:
    - step: 1
      component: "UserController"
      action: "Receives POST /users request"
      data_in: "HTTP request body"
      data_out: "CreateUserInput"

    - step: 2
      component: "ValidationMiddleware"
      action: "Validates input schema"
      data_in: "CreateUserInput"
      data_out: "Validated CreateUserInput or ValidationError"

    - step: 3
      component: "UserService"
      action: "Orchestrates user creation"
      data_in: "CreateUserInput"
      data_out: "User or DuplicateEmailError"

    - step: 4
      component: "UserRepository"
      action: "Persists user to database"
      data_in: "User entity"
      data_out: "Persisted User with ID"

    - step: 5
      component: "EventPublisher"
      action: "Publishes UserCreated event"
      data_in: "User"
      data_out: "Event published confirmation"
```

### 7. Address error handling

Define error handling strategy:

```yaml
error_handling:
  strategy: "Propagate domain errors, transform at boundaries"
  errors:
    - error: "DuplicateEmailError"
      origin: "UserRepository"
      propagation: "UserService → UserController"
      http_mapping: "409 Conflict"

    - error: "ValidationError"
      origin: "ValidationMiddleware"
      propagation: "Caught at controller"
      http_mapping: "400 Bad Request"

    - error: "DatabaseError"
      origin: "UserRepository"
      propagation: "Wrap in ServiceError"
      http_mapping: "500 Internal Server Error"
```

### 8. Document decisions

Record architectural decisions:

```yaml
decisions:
  - decision: "Use repository pattern for data access"
    rationale: "Enables testing service logic without database"
    alternatives:
      - "Direct database access in service"
      - "Active Record pattern"
    trade_offs: "Additional abstraction layer, but improved testability"

  - decision: "Publish events after successful persistence"
    rationale: "Ensures events only fire for committed changes"
    alternatives:
      - "Publish before persistence"
      - "Use transactional outbox"
    trade_offs: "Simpler but no guaranteed delivery; consider outbox for critical events"
```

## Output

Save design to `.sdlc/stories/{story-id}/design.md`:

```markdown
# Design: US-001 - User Registration

## Architecture
Pattern: Layered (Controller → Service → Repository)
Rationale: Matches existing codebase patterns, provides clear separation

## Components
[Component details]

## Interfaces
[Interface definitions]

## Data flow
[Flow diagrams/descriptions]

## Error handling
[Error strategy]

## Decisions
[ADRs - Architecture Decision Records]

## File changes
New files:
- src/controllers/user.controller.ts
- src/services/user.service.ts
- src/repositories/user.repository.ts
- src/types/user.types.ts

Modified files:
- src/routes/index.ts (add user routes)
```

Update manifest:
```yaml
stories:
  US-001:
    artifacts:
      design: ".sdlc/stories/US-001/design.md"
    decisions:
      - phase: "design"
        decision: "Using layered architecture"
        rationale: "Matches existing patterns"
```

## Validation

Before completing:
- [ ] All contracts from spec have implementing components
- [ ] All behaviours can be traced through data flow
- [ ] Error handling covers all error cases from spec
- [ ] No forbidden patterns used
- [ ] Naming follows project conventions
- [ ] Dependencies are unidirectional (no cycles)

## Standalone usage

When used outside the orchestrated pipeline (e.g., via `/feature`), design can work with inline context instead of manifest spec:

- Feature description provided directly in the request
- Codebase survey performed automatically
- Outputs brief design plan (not saved to .sdlc/)
- Skip formal ADRs; document key decisions inline

**Inline mode input:**
```yaml
feature: "Add logout button to user menu"
codebase_context:
  architecture: "React + Redux"
  related_modules: ["src/components/UserMenu.tsx", "src/store/authSlice.ts"]
  patterns: ["Functional components", "Redux Toolkit"]
```

**Inline mode output:**
```yaml
design:
  approach: "Add logout action to slice, expose via hook, add button to menu"
  components: [...]
  data_flow: [...]
  decisions:
    - "Use existing auth slice rather than new module"
```

## Tips

- Design should be detailed enough for stubs phase to create interfaces
- Avoid over-engineering; design for current requirements
- Consider testability in component boundaries
- If design reveals spec gaps, flag for spec revision before proceeding
- Include sequence diagrams for complex flows (use mermaid or text-based)

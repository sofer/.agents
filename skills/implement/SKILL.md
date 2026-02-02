---
name: implement
description: Write code to pass all tests (TDD green phase). Expect 100% test pass rate. Use after tests are written to implement the actual functionality.
---

# Implement

Write the implementation code to make all tests pass. This is the "green" phase of TDD.

## Purpose

Implementation transforms stubs into working code:
- Make tests pass with minimal code
- Follow the design architecture
- Adhere to project standards
- Produce working, tested functionality

## Input

Expect from orchestrator:
- Stubs (interfaces and stub implementations to complete)
- Tests (failing tests that define expected behaviour)
- Design (architecture decisions and data flow)
- Project standards (patterns, naming, style)

## Process

### 1. Review failing tests

Understand what each test expects:

```bash
# Run tests to see current failures
npm test -- --verbose
```

Group tests by component and prioritise:
- Start with lowest-level components (repositories)
- Move up to services
- Finish with controllers/handlers

### 2. Implement incrementally

For each component, implement one method at a time:

1. Pick one failing test
2. Write minimal code to pass it
3. Run tests to verify
4. Repeat until all tests for that method pass
5. Move to next method

### 3. Replace stub implementations

Transform stubs into real implementations:

**Before (stub):**
```typescript
async save(user: User): Promise<User> {
  throw new Error('Not implemented: UserRepository.save');
}
```

**After (implementation):**
```typescript
async save(user: User): Promise<User> {
  const result = await this.db.collection('users').insertOne(user);
  return { ...user, id: result.insertedId.toString() };
}
```

### 4. Follow design patterns

Implement according to the design document:
- Respect layer boundaries
- Use dependency injection as designed
- Follow error handling strategy
- Implement data transformations as specified

### 5. Handle errors

Implement error handling as specified in design:

```typescript
async createUser(input: CreateUserInput): Promise<User> {
  // Check for duplicate
  const existing = await this.userRepository.findByEmail(input.email);
  if (existing) {
    throw new DuplicateEmailError(input.email);
  }

  // Create user
  const user: User = {
    id: generateId(),
    email: input.email.toLowerCase(),
    name: input.name,
    createdAt: new Date(),
  };

  // Persist
  const saved = await this.userRepository.save(user);

  // Publish event
  await this.eventPublisher.publish(new UserCreatedEvent(saved));

  return saved;
}
```

### 6. Run tests continuously

After each change, run tests:

```bash
# Watch mode
npm test -- --watch

# Or run manually
npm test
```

Track progress: 0/12 → 3/12 → 7/12 → 12/12

### 7. Achieve green

Continue until all tests pass:

```
PASS  tests/services/user.service.test.ts
  UserService
    createUser
      ✓ should return user with generated id (5ms)
      ✓ should persist user to repository (2ms)
      ✓ should throw DuplicateEmailError when email exists (3ms)
      ✓ should normalise email to lowercase (2ms)
      ...

Test Suites: 1 passed, 1 total
Tests:       12 passed, 12 total
```

## Implementation guidelines

### Write minimal code
- Only write code needed to pass tests
- Avoid premature optimisation
- Don't add features not covered by tests

### Follow SOLID principles
- **S**ingle responsibility: One reason to change
- **O**pen/closed: Open for extension, closed for modification
- **L**iskov substitution: Subtypes substitutable for base types
- **I**nterface segregation: Specific interfaces over general
- **D**ependency inversion: Depend on abstractions

### Handle edge cases
Tests should cover edge cases; implementation should handle them:
```typescript
// Normalise email
const normalisedEmail = input.email.toLowerCase().trim();

// Validate length
if (normalisedEmail.length > MAX_EMAIL_LENGTH) {
  throw new ValidationError('Email too long');
}
```

### Keep it simple
- Prefer clarity over cleverness
- Use descriptive variable names
- Avoid deep nesting
- Extract helper functions when complexity grows

## Output

```yaml
implement:
  story_id: "US-001"
  files_modified:
    - path: "src/repositories/user.repository.ts"
      changes: "Full implementation of IUserRepository"
      methods_implemented: ["save", "findById", "findByEmail"]
    - path: "src/services/user.service.ts"
      changes: "Full implementation of UserService"
      methods_implemented: ["createUser", "findById"]
    - path: "src/controllers/user.controller.ts"
      changes: "Full implementation of UserController"
      methods_implemented: ["createUser", "getUser"]

  files_created:
    - path: "src/errors/duplicate-email.error.ts"
      reason: "Custom error type for duplicate email"

  run_result:
    command: "npm test"
    total: 12
    passed: 12
    failed: 0
    status: "green"  # Required

  notes: ""
```

Update manifest:
```yaml
stories:
  US-001:
    phase: "implement"
    artifacts:
      implementation: "src/services/user.service.ts"
```

## Gate

**Must pass before proceeding to refactor phase:**
- [ ] All tests pass (100%)
- [ ] No skipped or pending tests
- [ ] Code compiles without warnings
- [ ] No runtime errors in test execution

## Troubleshooting

### Test still fails after implementation
- Re-read the test assertion carefully
- Check mock setup matches implementation
- Verify return types and shapes
- Check async/await handling

### Implementation seems wrong but test passes
- Test may be incomplete; consider adding more tests
- Discuss with design phase if behaviour unclear

### Stuck on a test
- Break the problem into smaller steps
- Write a simpler test first
- Check if stub interfaces need adjustment

## Tips

- Let tests guide you; don't implement ahead of tests
- Run tests frequently; small feedback loops
- Commit working state before attempting complex changes
- If implementation is hard, design may need revision
- Green means "it works", not "it's perfect" (that's refactor)

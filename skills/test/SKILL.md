---
name: test
description: Write tests against stubs following TDD red phase. Tests should fail initially (0% pass expected). Use after stubs to define expected behaviour before implementation.
---

# Test

Write tests against stub implementations. This is the "red" phase of TDD - tests should fail because stubs throw NotImplementedError.

## Purpose

Tests define the expected behaviour before implementation:
- Serve as executable specification
- Drive the implementation design
- Provide regression safety
- Document intended behaviour

## Input

Expect from orchestrator:
- Stubs output (interfaces, stub implementations)
- Spec output (behaviours, edge cases)
- Project test conventions (framework, location, naming)

## Process

### 1. Map behaviours to tests

Each behaviour from spec becomes one or more tests:

```yaml
# From spec
behaviours:
  - scenario: "Successful user creation"
    given: ["No user exists with email 'test@example.com'"]
    when: ["POST /users with valid email and name"]
    then:
      - "Returns 201 with user object"
      - "User is persisted to database"
      - "UserCreated event is published"

# Maps to tests
tests:
  - "createUser returns user with generated id"
  - "createUser persists user to repository"
  - "createUser publishes UserCreated event"
```

### 2. Structure test files

Mirror the source structure:

```
src/
  services/
    user.service.ts
tests/
  services/
    user.service.test.ts
```

Or use co-location if project prefers:
```
src/
  services/
    user.service.ts
    user.service.test.ts
```

### 3. Write unit tests

Test each component in isolation using mocks:

```typescript
// tests/services/user.service.test.ts

import { UserService } from '../../src/services/user.service';
import { IUserRepository } from '../../src/interfaces/user-repository.interface';
import { User, CreateUserInput } from '../../src/types/user.types';

describe('UserService', () => {
  let userService: UserService;
  let mockRepository: jest.Mocked<IUserRepository>;

  beforeEach(() => {
    mockRepository = {
      save: jest.fn(),
      findById: jest.fn(),
      findByEmail: jest.fn(),
    };
    userService = new UserService(mockRepository);
  });

  describe('createUser', () => {
    const validInput: CreateUserInput = {
      email: 'test@example.com',
      name: 'Test User',
    };

    it('should return user with generated id', async () => {
      mockRepository.findByEmail.mockResolvedValue(null);
      mockRepository.save.mockImplementation(async (user) => user);

      const result = await userService.createUser(validInput);

      expect(result.id).toBeDefined();
      expect(result.email).toBe(validInput.email);
      expect(result.name).toBe(validInput.name);
    });

    it('should persist user to repository', async () => {
      mockRepository.findByEmail.mockResolvedValue(null);
      mockRepository.save.mockImplementation(async (user) => user);

      await userService.createUser(validInput);

      expect(mockRepository.save).toHaveBeenCalledWith(
        expect.objectContaining({
          email: validInput.email,
          name: validInput.name,
        })
      );
    });

    it('should throw DuplicateEmailError when email exists', async () => {
      const existingUser: User = {
        id: '123',
        email: validInput.email,
        name: 'Existing',
        createdAt: new Date(),
      };
      mockRepository.findByEmail.mockResolvedValue(existingUser);

      await expect(userService.createUser(validInput))
        .rejects.toThrow('DuplicateEmailError');
    });

    it('should normalise email to lowercase', async () => {
      const inputWithUppercase = { ...validInput, email: 'Test@Example.COM' };
      mockRepository.findByEmail.mockResolvedValue(null);
      mockRepository.save.mockImplementation(async (user) => user);

      const result = await userService.createUser(inputWithUppercase);

      expect(result.email).toBe('test@example.com');
    });
  });
});
```

### 4. Write integration tests (if applicable)

Test component interactions:

```typescript
// tests/integration/user-registration.test.ts

describe('User Registration Integration', () => {
  it('should create user and publish event', async () => {
    // Test the full flow with real (or test) implementations
  });
});
```

### 5. Cover edge cases

From spec edge cases, create specific tests:

```typescript
describe('edge cases', () => {
  it('should handle email at maximum length', async () => {
    const longEmail = 'a'.repeat(64) + '@example.com';
    // ...
  });

  it('should reject email exceeding maximum length', async () => {
    const tooLongEmail = 'a'.repeat(65) + '@example.com';
    // ...
  });

  it('should handle concurrent creation attempts', async () => {
    // ...
  });
});
```

### 6. Run tests (expect failure)

Execute tests to confirm they fail appropriately:

```bash
# Jest
npm test

# Pytest
pytest

# Go
go test ./...
```

Expected result: All tests fail with "Not implemented" errors.

## Test patterns

### Arrange-Act-Assert
```typescript
it('should do something', () => {
  // Arrange
  const input = { ... };
  mockDep.method.mockReturnValue(...);

  // Act
  const result = service.method(input);

  // Assert
  expect(result).toEqual(...);
});
```

### Given-When-Then (BDD style)
```typescript
describe('given a valid user input', () => {
  describe('when createUser is called', () => {
    it('then should return created user', () => {
      // ...
    });
  });
});
```

## Output

```yaml
test:
  story_id: "US-001"
  files_created:
    - path: "tests/services/user.service.test.ts"
      test_count: 8
      coverage:
        behaviours: ["Successful creation", "Duplicate rejection"]
        edge_cases: ["Max length email", "Uppercase normalisation"]
    - path: "tests/repositories/user.repository.test.ts"
      test_count: 4

  run_result:
    command: "npm test"
    total: 12
    passed: 0
    failed: 12
    status: "red"  # Expected

  behaviours_covered:
    - "Successful user creation"
    - "Duplicate email rejection"
    - "Email normalisation"

  edge_cases_covered:
    - "Email at boundary length"
    - "Concurrent creation"

  notes: "All tests fail as expected - stubs not implemented"
```

Update manifest:
```yaml
stories:
  US-001:
    phase: "test"
    artifacts:
      tests: "tests/services/user.service.test.ts"
```

## Gate

**Must pass before proceeding to implement phase:**
- [ ] Tests exist for all spec behaviours
- [ ] Tests cover documented edge cases
- [ ] Tests run and fail (not error due to syntax/import issues)
- [ ] Test failures are due to NotImplementedError, not other errors

## Test quality checklist

- [ ] Tests are independent (can run in any order)
- [ ] Tests have descriptive names
- [ ] Tests use mocks appropriately (isolate unit under test)
- [ ] Tests check behaviour, not implementation details
- [ ] Tests are readable and serve as documentation

## Tips

- Write the test you wish you had, then make it pass
- One assertion per test (or closely related assertions)
- Test names should describe the expected behaviour
- Mocks verify interactions, stubs provide canned answers
- If a test is hard to write, the design may need adjustment
- Don't test private methods directly; test through public interface

---
name: refactor
description: Clean up implementation code while keeping tests green. Improve code quality without changing behaviour. Use after implement phase to polish code before review.
---

# Refactor

Improve code structure and quality while keeping all tests passing. This completes the TDD red-green-refactor cycle.

## Purpose

Refactoring improves code without changing behaviour:
- Improve readability and maintainability
- Remove duplication
- Simplify complexity
- Align with project standards
- Prepare code for review

## Input

Expect from orchestrator:
- Implementation files from implement phase
- Passing test suite
- Project standards (patterns, naming, style)
- Design document (for architectural alignment)

## Golden rule

**Tests must stay green throughout refactoring.**

After every change, run tests. If tests fail, the change altered behaviour - revert and try a different approach.

## Process

### 1. Ensure green baseline

Verify all tests pass before starting:

```bash
npm test
# ✓ All tests passing
```

### 2. Identify refactoring opportunities

Review code for:

**Code smells:**
- Long methods (>20 lines)
- Deep nesting (>3 levels)
- Duplicate code
- Large classes
- Long parameter lists
- Feature envy (method uses another class more than its own)
- Data clumps (groups of data that appear together)

**Standards alignment:**
- Naming conventions
- Code style
- Pattern adherence
- Error handling consistency

### 3. Apply refactoring techniques

#### Extract method
```typescript
// Before
async createUser(input: CreateUserInput): Promise<User> {
  const email = input.email.toLowerCase().trim();
  if (!email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
    throw new ValidationError('Invalid email');
  }
  // ... more code
}

// After
async createUser(input: CreateUserInput): Promise<User> {
  const email = this.normaliseEmail(input.email);
  this.validateEmail(email);
  // ... more code
}

private normaliseEmail(email: string): string {
  return email.toLowerCase().trim();
}

private validateEmail(email: string): void {
  if (!email.match(/^[^\s@]+@[^\s@]+\.[^\s@]+$/)) {
    throw new ValidationError('Invalid email');
  }
}
```

#### Extract constant
```typescript
// Before
if (name.length > 100) { ... }

// After
const MAX_NAME_LENGTH = 100;
if (name.length > MAX_NAME_LENGTH) { ... }
```

#### Rename for clarity
```typescript
// Before
const d = new Date();
const u = await repo.save(data);

// After
const createdAt = new Date();
const savedUser = await userRepository.save(userData);
```

#### Simplify conditionals
```typescript
// Before
if (user !== null && user !== undefined) {
  if (user.active === true) {
    return user;
  }
}
return null;

// After
if (user?.active) {
  return user;
}
return null;
```

#### Remove duplication
```typescript
// Before (in multiple methods)
const email = input.email.toLowerCase().trim();

// After (extracted to shared method)
const email = this.normaliseEmail(input.email);
```

#### Introduce parameter object
```typescript
// Before
function createUser(email: string, name: string, role: string, department: string)

// After
function createUser(input: CreateUserInput)
```

### 4. Refactor in small steps

1. Make one small change
2. Run tests
3. If green, commit mentally (or actually)
4. If red, revert immediately
5. Repeat

### 5. Run tests continuously

```bash
# Watch mode for instant feedback
npm test -- --watch
```

### 6. Final verification

After all refactoring:
- All tests still pass
- Code coverage unchanged or improved
- No new linting errors
- Code compiles without warnings

## Refactoring checklist

### Readability
- [ ] Variable names are descriptive
- [ ] Method names describe what they do
- [ ] Comments explain why, not what
- [ ] No magic numbers or strings

### Structure
- [ ] Methods are focused (single responsibility)
- [ ] Classes are cohesive
- [ ] No deep nesting
- [ ] Clear control flow

### Duplication
- [ ] No copy-pasted code
- [ ] Common logic extracted
- [ ] Consistent patterns used

### Standards
- [ ] Naming follows conventions
- [ ] Code style matches project
- [ ] Error handling is consistent
- [ ] Logging follows patterns

## Output

```yaml
refactor:
  story_id: "US-001"
  changes:
    - type: "extract_method"
      description: "Extracted email normalisation to separate method"
      files: ["src/services/user.service.ts"]
      rationale: "Reused in multiple places, improves readability"

    - type: "rename"
      description: "Renamed 'u' to 'savedUser' for clarity"
      files: ["src/services/user.service.ts"]
      rationale: "Improves code readability"

    - type: "extract_constant"
      description: "Extracted MAX_EMAIL_LENGTH constant"
      files: ["src/services/user.service.ts", "src/types/constants.ts"]
      rationale: "Removes magic number, centralises configuration"

    - type: "simplify"
      description: "Simplified null check using optional chaining"
      files: ["src/repositories/user.repository.ts"]
      rationale: "Modern syntax, more readable"

  run_result:
    command: "npm test"
    total: 12
    passed: 12
    failed: 0
    status: "green"  # Required - unchanged from implement

  decisions:
    - decision: "Kept validation in service layer"
      rationale: "Consistent with existing pattern; controller stays thin"

  notes: "Minor refactoring only; implementation was already clean"
```

Update manifest:
```yaml
stories:
  US-001:
    phase: "refactor"
    decisions:
      - phase: "refactor"
        decision: "Extracted email normalisation"
        rationale: "DRY principle, used in 3 places"
```

## Gate

**Must pass before proceeding to code-review:**
- [ ] All tests still pass (100%)
- [ ] No decrease in test coverage
- [ ] Code compiles without warnings
- [ ] Linting passes

## What NOT to do

- Don't add new features (that requires tests first)
- Don't change public interfaces without updating tests
- Don't refactor untested code (add tests first)
- Don't make multiple changes before testing
- Don't over-engineer or gold-plate

## Tips

- Small steps are safer than big leaps
- If a refactoring is hard, maybe the code needs tests first
- Trust the tests; if they pass, behaviour is preserved
- Refactoring is optional if code is already clean
- Time-box refactoring to avoid perfectionism

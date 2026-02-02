---
name: stubs
description: Create interfaces, type definitions, and stub implementations that compile but are not functional. Use after design-review approval to establish code structure before writing tests. Enables TDD red-green-refactor cycle.
---

# Stubs

Create the structural skeleton of the implementation: interfaces, types, and stub methods that compile but throw or return placeholder values.

## Purpose

Stubs establish the code structure before tests are written, enabling:
- Tests to be written against real interfaces
- Parallel development (tests and implementation)
- Early validation that design is implementable
- Type checking before full implementation

## Input

Expect from orchestrator:
- Design output (components, interfaces, data flow)
- Project standards (language, naming conventions)
- Existing codebase context

## Process

### 1. Create type definitions

From the design's data schemas, create type/interface files:

```typescript
// src/types/user.types.ts

export interface User {
  id: string;
  email: string;
  name: string;
  createdAt: Date;
}

export interface CreateUserInput {
  email: string;
  name: string;
}

export type UserId = string;
```

### 2. Create interface definitions

From the design's interfaces, create abstract contracts:

```typescript
// src/interfaces/user-repository.interface.ts

import { User, CreateUserInput } from '../types/user.types';

export interface IUserRepository {
  save(user: User): Promise<User>;
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
}
```

### 3. Create stub implementations

Implement interfaces with placeholder logic:

```typescript
// src/repositories/user.repository.ts

import { IUserRepository } from '../interfaces/user-repository.interface';
import { User } from '../types/user.types';

export class UserRepository implements IUserRepository {
  async save(user: User): Promise<User> {
    throw new Error('Not implemented: UserRepository.save');
  }

  async findById(id: string): Promise<User | null> {
    throw new Error('Not implemented: UserRepository.findById');
  }

  async findByEmail(email: string): Promise<User | null> {
    throw new Error('Not implemented: UserRepository.findByEmail');
  }
}
```

### 4. Create service stubs

```typescript
// src/services/user.service.ts

import { IUserRepository } from '../interfaces/user-repository.interface';
import { User, CreateUserInput } from '../types/user.types';

export class UserService {
  constructor(private readonly userRepository: IUserRepository) {}

  async createUser(input: CreateUserInput): Promise<User> {
    throw new Error('Not implemented: UserService.createUser');
  }

  async findById(id: string): Promise<User | null> {
    throw new Error('Not implemented: UserService.findById');
  }
}
```

### 5. Create controller stubs (if applicable)

```typescript
// src/controllers/user.controller.ts

import { UserService } from '../services/user.service';

export class UserController {
  constructor(private readonly userService: UserService) {}

  async createUser(req: Request, res: Response): Promise<void> {
    throw new Error('Not implemented: UserController.createUser');
  }

  async getUser(req: Request, res: Response): Promise<void> {
    throw new Error('Not implemented: UserController.getUser');
  }
}
```

### 6. Wire up exports and routes

Create necessary index files and route registrations:

```typescript
// src/routes/user.routes.ts

import { Router } from 'express';
import { UserController } from '../controllers/user.controller';

export function createUserRoutes(controller: UserController): Router {
  const router = Router();

  router.post('/users', (req, res) => controller.createUser(req, res));
  router.get('/users/:id', (req, res) => controller.getUser(req, res));

  return router;
}
```

### 7. Set up executable entry point (CLI projects)

For CLI tools, create an executable entry point so users can test from the project directory:

**TypeScript/Bun:**
```bash
# Create shell wrapper at project root
cat > ./brain << 'EOF'
#!/bin/bash
BUN="${HOME}/.bun/bin/bun"
"$BUN" run "$(dirname "$0")/src/index.ts" "$@"
EOF
chmod +x ./brain
```

**Node.js:**
```bash
# Create shell wrapper at project root
cat > ./myapp << 'EOF'
#!/bin/bash
node "$(dirname "$0")/src/index.js" "$@"
EOF
chmod +x ./myapp
```

**Python:**
```bash
# Create shell wrapper at project root
cat > ./myapp << 'EOF'
#!/bin/bash
python "$(dirname "$0")/src/main.py" "$@"
EOF
chmod +x ./myapp
```

Also update `package.json` (Node/Bun) or `pyproject.toml` (Python) with the appropriate entry point configuration:

```json
{
  "bin": {
    "brain": "./src/index.ts"
  },
  "scripts": {
    "brain": "bun run src/index.ts"
  }
}
```

**Why this matters:**
- Users must be able to test each story from the terminal before moving to the next
- The shell wrapper works immediately without global installation
- Makes the development experience match the production experience

## Stub patterns by language

### TypeScript/JavaScript
```typescript
async methodName(): Promise<ReturnType> {
  throw new Error('Not implemented: ClassName.methodName');
}
```

### Python
```python
def method_name(self) -> ReturnType:
    raise NotImplementedError("ClassName.method_name")
```

### Go
```go
func (s *Service) MethodName() (ReturnType, error) {
    return ReturnType{}, errors.New("not implemented: Service.MethodName")
}
```

### Java
```java
public ReturnType methodName() {
    throw new UnsupportedOperationException("Not implemented: ClassName.methodName");
}
```

## Verification

After creating stubs, verify:

1. **Compilation**: Code compiles/type-checks without errors
   ```bash
   # TypeScript
   tsc --noEmit

   # Python
   mypy src/

   # Go
   go build ./...
   ```

2. **Imports resolve**: All imports and dependencies are satisfied

3. **Structure matches design**: Components exist as designed

## Output

```yaml
stubs:
  story_id: "US-001"
  files_created:
    - path: "src/types/user.types.ts"
      type: "types"
      exports: ["User", "CreateUserInput", "UserId"]
    - path: "src/interfaces/user-repository.interface.ts"
      type: "interface"
      exports: ["IUserRepository"]
    - path: "src/repositories/user.repository.ts"
      type: "stub"
      implements: "IUserRepository"
    - path: "src/services/user.service.ts"
      type: "stub"
      methods: ["createUser", "findById"]
    - path: "src/controllers/user.controller.ts"
      type: "stub"
      methods: ["createUser", "getUser"]
    - path: "src/routes/user.routes.ts"
      type: "routes"

  files_modified:
    - path: "src/routes/index.ts"
      change: "Added user routes import"

  compilation:
    command: "tsc --noEmit"
    status: "pass"
    errors: []

  entry_point:  # For CLI projects
    script: "./brain"
    run_command: "./brain --help"
    status: "pass"

  notes: ""
```

Update manifest:
```yaml
stories:
  US-001:
    artifacts:
      stubs: ".sdlc/stories/US-001/stubs/"
```

## Gate

**Must pass before proceeding to test phase:**
- [ ] All files compile without errors
- [ ] All designed components have stub implementations
- [ ] All public interfaces are defined
- [ ] Dependencies are properly injected (not hard-coded)
- [ ] For CLI projects: executable entry point exists and is runnable from project directory

## Tips

- Stub implementations should fail loudly with clear messages
- Include the class and method name in error messages for debugging
- Don't implement any logic, even simple logic
- Dependency injection should be set up in stubs
- Create index files for clean imports
- If compilation fails, the design may need revision

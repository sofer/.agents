---
name: requirements
description: Transform intent into user stories with acceptance criteria. Use after intent clarification to build a prioritised backlog. Produces stories in standard format ready for spec phase.
---

# Requirements

Transform clarified intent into actionable user stories with acceptance criteria.

## Input

Expect intent output containing:
- Problem statement
- Users and their needs
- Constraints (technical, business, timeline)
- Success criteria
- Coding standards (if gathered)

## Process

### 1. Identify story candidates

Review the intent and identify discrete pieces of functionality:

- Each user need typically maps to one or more stories
- Each success criterion should be achievable by one or more stories
- Break large features into smaller, independently deliverable stories

### 2. Write user stories

For each story, use the standard format:

```
As a [user persona],
I want [goal/desire],
So that [benefit/value].
```

Guidelines:
- Stories should be independent where possible
- Stories should be negotiable (not contracts)
- Stories should be valuable to the user
- Stories should be estimable
- Stories should be small enough to complete in one iteration
- Stories should be testable

### 3. Define acceptance criteria

For each story, write acceptance criteria using Given/When/Then:

```
Given [initial context/state],
When [action is taken],
Then [expected outcome].
```

Guidelines:
- Cover the happy path first
- Include key edge cases
- Be specific and testable
- Avoid implementation details
- Each criterion should be independently verifiable

### 4. Identify dependencies

Mark dependencies between stories:
- Technical dependencies (A must exist before B can work)
- Logical dependencies (A provides context for B)
- Avoid circular dependencies

### 5. Prioritise

Assign priority based on:
- User value (higher = more valuable)
- Risk reduction (higher = reduces more uncertainty)
- Dependencies (blocked stories rank lower)
- Quick wins (small high-value items rank higher)

Use priority numbers: 1 = highest, incrementing for lower priority.

### 6. Estimate complexity

Assign t-shirt sizes:
- **S** - Few hours, single component
- **M** - A day or two, few components
- **L** - Several days, multiple components
- **XL** - Week or more, significant complexity (consider splitting)

## Output

Generate backlog in this format:

```yaml
backlog:
  - id: "US-001"
    title: "Short descriptive title"
    description: |
      As a [user],
      I want [goal],
      So that [benefit].
    acceptance_criteria:
      - "Given [context], when [action], then [result]"
      - "Given [context], when [action], then [result]"
    priority: 1
    estimate: "M"
    dependencies: []

  - id: "US-002"
    title: "Another story"
    description: |
      As a [user],
      I want [goal],
      So that [benefit].
    acceptance_criteria:
      - "Given [context], when [action], then [result]"
    priority: 2
    estimate: "S"
    dependencies: ["US-001"]
```

### Story ID format

Use `US-NNN` format with zero-padded numbers starting from 001.

## Validation

Before finalising, verify:

- [ ] Every success criterion from intent is addressed by at least one story
- [ ] Every user persona has at least one story addressing their needs
- [ ] No orphan stories (stories that don't trace back to intent)
- [ ] Dependencies form a directed acyclic graph (no cycles)
- [ ] Acceptance criteria are testable without knowing implementation
- [ ] XL stories have been considered for splitting

## Presentation

Present the backlog to the user:

1. Summarise: "Based on the intent, I've identified N stories"
2. Show dependency graph if complex
3. List stories in priority order with estimates
4. Ask for confirmation before saving to manifest

## Manifest update

Once approved, update `.sdlc/manifest.yaml`:

```yaml
manifest:
  backlog:
    - id: "US-001"
      title: "..."
      # ... full story details
  current_story: null  # Ready for story selection
```

## Tips

- When in doubt, make stories smaller rather than larger
- Acceptance criteria should read like a test specification
- If a story has more than 5-7 acceptance criteria, consider splitting
- Technical tasks (refactoring, infrastructure) can be stories if they deliver user value indirectly
- Include "spike" stories for research when uncertainty is high

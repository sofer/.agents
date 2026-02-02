---
name: design-review
description: Validate design before implementation. Use after design phase to ensure architecture meets standards, spec requirements, and quality criteria. Gates progression to stubs phase.
---

# Design review

Validate the design against spec, standards, and quality criteria before implementation begins.

## Input

Expect from orchestrator:
- Design output (architecture, components, interfaces, decisions)
- Spec output (contracts, behaviours, edge cases)
- Project standards (paradigm, patterns, forbidden patterns)
- Intent output (constraints, success criteria)

## Review checklist

### 1. Spec alignment

Verify design addresses all spec requirements:

```yaml
spec_alignment:
  - item: "All contracts have implementing components"
    check: "Map each spec contract to a component"
    status: "pass | fail"
    notes: ""

  - item: "All behaviours are achievable"
    check: "Trace each behaviour through data flow"
    status: "pass | fail"
    notes: ""

  - item: "All edge cases handled"
    check: "Verify error handling covers spec edge cases"
    status: "pass | fail"
    notes: ""

  - item: "Data schemas correctly represented"
    check: "Compare design types to spec schemas"
    status: "pass | fail"
    notes: ""
```

### 2. Standards compliance

Verify adherence to project standards:

```yaml
standards_compliance:
  - item: "Follows prescribed paradigm"
    check: "Verify OOP/functional/mixed as specified"
    status: "pass | fail"
    notes: ""

  - item: "Uses approved patterns"
    check: "Verify architecture pattern is in approved list"
    status: "pass | fail"
    notes: ""

  - item: "Avoids forbidden patterns"
    check: "Scan for any forbidden patterns in design"
    status: "pass | fail"
    notes: ""

  - item: "Naming conventions followed"
    check: "Verify component/interface naming matches standards"
    status: "pass | fail"
    notes: ""
```

### 3. Architecture quality

Assess design quality:

```yaml
architecture_quality:
  - item: "Single responsibility"
    check: "Each component has one clear responsibility"
    status: "pass | fail"
    notes: ""

  - item: "Dependency direction"
    check: "Dependencies flow inward (no cycles)"
    status: "pass | fail"
    notes: ""

  - item: "Interface segregation"
    check: "Interfaces are focused, not bloated"
    status: "pass | fail"
    notes: ""

  - item: "Testability"
    check: "Components can be tested in isolation"
    status: "pass | fail"
    notes: ""

  - item: "Appropriate abstraction"
    check: "Not over-engineered, not under-designed"
    status: "pass | fail"
    notes: ""
```

### 4. Risk assessment

Identify potential risks:

```yaml
risk_assessment:
  - item: "Performance implications"
    check: "No obvious bottlenecks or N+1 patterns"
    status: "ok | warning | concern"
    notes: ""

  - item: "Security considerations"
    check: "Auth, validation, data protection addressed"
    status: "ok | warning | concern"
    notes: ""

  - item: "Scalability"
    check: "Design can handle expected load"
    status: "ok | warning | concern"
    notes: ""

  - item: "Complexity"
    check: "Complexity proportional to requirements"
    status: "ok | warning | concern"
    notes: ""
```

## Review process

1. **Load context**: Read design, spec, and standards
2. **Run checklist**: Evaluate each item systematically
3. **Document issues**: Record any failures or concerns
4. **Determine verdict**: Approve, request changes, or reject
5. **Provide feedback**: Explain issues with suggestions

## Issue classification

Categorise issues by severity:

- **Blocker**: Must fix before proceeding (spec violation, security flaw)
- **Major**: Should fix, impacts quality significantly
- **Minor**: Nice to fix, improves design marginally

## Output

```yaml
design_review:
  story_id: "US-001"
  status: "approved | changes_requested | rejected"

  checklist_summary:
    spec_alignment: "4/4 passed"
    standards_compliance: "4/4 passed"
    architecture_quality: "4/5 passed"
    risk_assessment: "3 ok, 1 warning"

  issues:
    - severity: "major"
      category: "architecture_quality"
      item: "Testability"
      description: "UserService directly instantiates UserRepository"
      suggestion: "Inject repository via constructor for testability"
      affected_components: ["UserService"]

    - severity: "minor"
      category: "risk_assessment"
      item: "Performance"
      description: "findByEmail called twice in registration flow"
      suggestion: "Consider caching result or restructuring flow"
      affected_components: ["UserService"]

  verdict:
    decision: "changes_requested"
    rationale: "One major testability issue must be addressed"
    blocking_issues: 1
    total_issues: 2

  approval_conditions:
    - "Inject UserRepository dependency"

  positive_notes:
    - "Clean separation of concerns"
    - "Good error handling strategy"
    - "Clear data flow documentation"
```

## Verdict criteria

**Approved**: No blockers, no major issues, minor issues acceptable
**Changes requested**: Has major issues that must be addressed
**Rejected**: Fundamental problems requiring significant redesign

## Checkpoint behaviour

This phase is a configured checkpoint. After review:

1. Present decision summary to user
2. If approved: Proceed to stubs phase
3. If changes requested: Return to design phase with feedback
4. If rejected: Escalate for discussion, may need spec revision

## Feedback format

When requesting changes, provide actionable feedback:

```markdown
## Design review: Changes requested

### Issues to address

**[Major] Testability concern in UserService**
The UserService directly instantiates UserRepository, making unit testing difficult.

*Suggestion*: Inject the repository through the constructor:
```typescript
class UserService {
  constructor(private readonly userRepository: UserRepository) {}
}
```

**[Minor] Performance consideration**
The email uniqueness check happens twice during registration.

*Suggestion*: Consider checking once and passing result through, or document why duplicate check is intentional.

### What's working well
- Clear component responsibilities
- Comprehensive error handling
- Good alignment with spec

### Next steps
Please update the design to address the major issue, then resubmit for review.
```

## Tips

- Review objectively; focus on design merit, not style preferences
- Major issues should be actionable with clear suggestions
- Acknowledge what's working well, not just problems
- If design reveals spec issues, note them but focus review on design
- Keep review proportional to story complexity

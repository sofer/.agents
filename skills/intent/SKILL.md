---
name: intent
description: Interactive conversation to clarify user intent step-by-step before creating specifications or solutions. Use when requirements are unclear or user has a new idea to explore.
---

# Intent clarification

Guide the user through a structured conversation to deeply understand their intent before creating specifications or solutions.

## Purpose

Ensure alignment on:
- What problem we're solving
- Who we're solving it for
- What constraints exist
- What success looks like
- How the code should be written

## Process

### Introduction

Start by asking the user to describe their idea:

> "Before we dive into specifics, could you describe your idea or the problem you're trying to solve in your own words?"

Listen actively and acknowledge their response before proceeding.

### Step 1: Core intent

Ask each question **one at a time**, wait for response, then acknowledge:

**Q1: Core problem/need**
- Ask: "What is the core problem or need that this solution should address?"
- Example prompt: "For instance: 'We need a tool that helps new team members onboard more quickly by centralising our documentation.'"
- If vague, ask follow-up questions for specificity

**Q2: Primary users and expectations**
- Ask: "Who will be the primary users, and what do they expect to achieve?"
- Example prompt: "For example: 'New hires who need to find onboarding materials without asking multiple people.'"
- Probe for specific user personas if needed

**Q3: Constraints and conditions**
- Ask: "Are there any constraints we should be aware of?"
- Example prompt: "Such as: 'Must work on mobile and integrate with our SSO system.'"
- Cover: technical, budget, timeline, organisational constraints

**Summary checkpoint:**
- Synthesise into 2-3 clear bullet points
- Ask: "Based on what you've shared, here's what I understand... Does this accurately capture your intent?"
- Iterate until aligned

### Step 2: Success criteria

**Q4: One-sentence goal**
- Ask: "If you had to describe the overall goal in one sentence, what would it be?"
- This forces clarity and reveals priorities

**Q5: Measurable outcomes**
- Ask: "How will we know when this is successful? What would we measure?"
- Push for specific, testable criteria
- Examples: "Users complete onboarding in under 2 hours", "Zero support tickets about finding documentation"

### Step 3: Coding standards (for new projects)

When starting a new project, gather coding preferences:

**Q6: Programming paradigm**
- Ask: "Do you have a preference for how the code should be structured?"
- Options: functional, object-oriented, or mixed
- If unsure, recommend based on project type

**Q7: Language and framework**
- Ask: "What language and frameworks should we use?"
- Note any existing codebase constraints

**Q8: Patterns and practices**
- Ask: "Are there specific patterns you want to follow or avoid?"
- Examples to offer: "Repository pattern, dependency injection, event sourcing"
- Also ask: "Any patterns or practices to explicitly avoid?"

**Q9: Naming conventions**
- Ask: "Do you have naming conventions for files, functions, variables?"
- If none, suggest sensible defaults for the chosen language

### Step 4: Final confirmation

Summarise the complete intent:
- Core problem
- Target users and needs
- Constraints
- Success criteria
- Coding standards

Ask: "Does this fully reflect what you want to achieve?"

## Output

Once confirmed, create structured output for the manifest:

```yaml
intent:
  problem_statement: |
    Clear articulation of the core problem being solved.

  users:
    - persona: "New hire"
      needs:
        - "Find onboarding materials quickly"
        - "Complete setup without asking colleagues"

    - persona: "HR manager"
      needs:
        - "Track onboarding progress"
        - "Update materials easily"

  constraints:
    technical:
      - "Must integrate with existing SSO"
      - "Mobile-responsive required"
    business:
      - "Budget: internal team only"
      - "Timeline: Q1 delivery"
    organisational:
      - "Must comply with data retention policy"

  success_criteria:
    - metric: "Onboarding completion time"
      target: "< 2 hours"
    - metric: "Support tickets about documentation"
      target: "Zero in first month"
    - metric: "User satisfaction score"
      target: ">= 4.5/5"

  coding_standards:
    paradigm: "functional"
    language: "TypeScript"
    framework: "Next.js"
    patterns:
      - "Repository pattern for data access"
      - "Dependency injection"
      - "Event-driven for notifications"
    forbidden:
      - "No class inheritance deeper than 2 levels"
      - "No mutable global state"
    naming:
      files: "kebab-case"
      functions: "camelCase"
      types: "PascalCase"
      constants: "SCREAMING_SNAKE_CASE"
```

Save to `.sdlc/manifest.yaml` under the `intent` key.

## Tone and style

- Be conversational and patient
- Don't rush through questions
- Validate and acknowledge each response
- Ask clarifying questions when ambiguous
- Use examples to illustrate expected detail level

## Checkpoint

Intent is a configured checkpoint. After completing:

1. Present the full intent summary
2. Ask for explicit approval
3. Only proceed to requirements phase after confirmation

## Tips

- One question at a time; don't overwhelm
- Silence is okay; let users think
- Vague answers need follow-up, not acceptance
- If user can't articulate success criteria, they may not be ready to build
- Coding standards can be skipped for existing projects with established patterns

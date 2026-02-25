# Skill composition conventions

How to build atomic and composite skills for the digital twin system.

## Skill types

### Atomic skills

A skill that does one thing. It does not invoke other skills.

**Frontmatter:**

```yaml
---
name: "skill-name"
description: "What this skill does"
type: atomic
input: "What data this skill expects"
output: "What data this skill produces"
---
```

**Rules:**
- Single responsibility — one well-defined task
- Must not read or invoke other skills' SKILL.md files
- Must declare its input and output in frontmatter
- Must work both standalone and as a step in a composite skill
- Naming: kebab-case (e.g. `gmail-fetch`, `contact-research`)

### Composite skills

A skill that orchestrates atomic skills in sequence. Digital twins are composite skills.

**Frontmatter:**

```yaml
---
name: "twin-name"
description: "What this composite skill does"
type: composite
depends_on:
  - atomic-skill-one
  - atomic-skill-two
  - atomic-skill-three
---
```

**Rules:**
- `depends_on` lists every atomic skill this composite uses, by name
- Every skill in `depends_on` must exist at `~/.agents/skills/{name}/SKILL.md`
- Must not depend on other composite skills (one level of composition only)
- Aim for 2–5 steps. More than 5 suggests the composite is doing too much.

## Step pattern

The body of a composite SKILL.md defines sequential steps. Each step follows this pattern:

```markdown
### Step N: Short description
**Skill**: `skill-name`
**Input**: Where the data comes from (user request, config, or a prior step's output label)
**Output** → `label`

Read and follow the instructions in `~/.agents/skills/skill-name/SKILL.md`.
```

### Data passing

Output labels are how steps reference each other's results. The agent's conversation context is the data bus — when step 1 produces output labelled `emails`, that data is in context for all subsequent steps.

- `**Output** → `emails`` means "call this result `emails`"
- A later step's `**Input**` can reference `emails` by name
- If a step produces no data for later steps, use `**Output** → `none``

### Config loading

Composite skills that need voice profile or business context include a preamble before their steps:

```markdown
## Config loading

Before starting the steps below:
1. Read `~/.agents/config/voice-profile.yaml` for voice and tone rules
2. Read relevant files from `~/.agents/config/business-context/` for domain knowledge
3. If any required config is missing, stop and report the expected path
```

See `~/.agents/config/README.md` for full config conventions.

## Error handling

- **Missing atomic skill**: stop and report which skill is missing and its expected path (`~/.agents/skills/{name}/SKILL.md`)
- **Atomic skill fails**: the atomic skill reports the error per its own instructions. The composite skill stops — no subsequent steps execute.
- **Missing input from prior step**: report which step's output was expected and that it was empty

## Creating a new skill

1. Decide whether it's atomic or composite
2. Copy the appropriate template from `~/.agents/config/templates/`
3. Create the skill directory: `~/.agents/skills/{name}/SKILL.md`
4. Fill in the frontmatter and instructions
5. For composite skills, verify all `depends_on` skills exist

Templates:
- `~/.agents/config/templates/atomic-skill.md`
- `~/.agents/config/templates/composite-skill.md`

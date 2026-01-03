# Agent Ecosystem

This directory contains reusable AI agent skills, prompts, and workflows for Claude Code.

## Directory Structure

```
~/.agents/
├── AGENTS.md              # This file - documentation and conventions
├── .system/               # System files (managed by Claude Code)
├── skills/                # Reusable skills that can be invoked
│   ├── anonymise/         # CSV anonymization skill
│   └── intent/            # Intent clarification skill
├── prompts/               # (Future) Reusable prompt templates
├── workflows/             # (Future) Multi-step workflow definitions
└── templates/             # (Future) Project scaffolding templates
```

## Skills

Skills are reusable capabilities that can be invoked during a Claude Code session. They provide specialized behavior for specific tasks.

### Available Skills

| Skill | Command | Description |
|-------|---------|-------------|
| **anonymise** | `/anonymise` | Anonymise CSV files by removing PII and adding datetime stamps |
| **intent** | `/intent` | Interactive conversation to clarify user intent before specifications |

### How to Use Skills

Invoke a skill by typing its command:
```
/anonymise
/intent
```

Claude will then follow the skill's instructions to complete the task.

## Creating a New Skill

### 1. Create the Skill Directory

```bash
mkdir -p ~/.agents/skills/your-skill-name
```

### 2. Create SKILL.md

Every skill must have a `SKILL.md` file with this structure:

```markdown
---
name: your-skill-name
description: Brief description of what the skill does and when to use it
---

# Skill Title

## Purpose
Explain what this skill accomplishes and why it exists.

## Instructions
Step-by-step instructions for Claude to follow when executing this skill.

## When to Use This Skill
Describe the scenarios where this skill should be invoked.

## (Optional) Additional Sections
- Configuration
- Examples
- Notes
- References
```

### 3. Add Supporting Files (Optional)

Skills can include additional files:
- **Configuration files**: `config.txt`, `settings.json`, etc.
- **Scripts**: Python, Bash, or other executable scripts
- **Templates**: Code templates or boilerplate files
- **Data files**: Reference data, schemas, etc.

### 4. Update This Documentation

Add your skill to the "Available Skills" table above.

## Skill Development Conventions

### Naming
- Use lowercase with hyphens: `my-skill-name`
- Be descriptive but concise
- Avoid generic names like "helper" or "utility"

### SKILL.md Format
- **YAML Frontmatter**: Always include `name` and `description`
- **Clear Instructions**: Write for the AI, not the human user
- **Examples**: Include concrete examples of inputs/outputs
- **Path References**: Always use `~/.agents/skills/` for absolute paths

### Writing Instructions
Skills should tell Claude **how** to do something, not provide fill-in-the-blank templates:

**Bad (Static Template):**
```markdown
1. Ask the user: ___________
2. Do this: ___________
```

**Good (Actionable Instructions):**
```markdown
1. Ask the user: "What is the core problem you're trying to solve?"
2. Wait for their response, then acknowledge it before proceeding
3. If the response is vague, ask follow-up questions like...
```

### Tone & Style
- Be conversational and helpful
- Provide clear next steps
- Include error handling guidance
- Specify what success looks like

## Path References in Skills

When referencing files within skills:

- **Skill files**: `~/.agents/skills/skill-name/file.py`
- **Config files**: `~/.agents/skills/skill-name/config.txt`
- **User files**: Use relative paths or ask the user for the path

## Testing Skills

After creating a skill:

1. **Test the invocation**: Try calling `/your-skill-name`
2. **Verify paths**: Ensure all file references work
3. **Check edge cases**: Test with various inputs
4. **Update documentation**: Reflect any learnings in SKILL.md

## Future Expansions

### Prompts (`~/.agents/prompts/`)
Reusable prompt templates for common tasks:
- Code review prompts
- Documentation generation prompts
- Test generation prompts

### Workflows (`~/.agents/workflows/`)
Multi-step processes that chain skills together:
- Full feature development workflows
- CI/CD setup workflows
- Onboarding workflows

### Templates (`~/.agents/templates/`)
Project scaffolding and boilerplate:
- API project templates
- Component templates
- Configuration templates

## Best Practices

1. **Start Simple**: Create focused skills that do one thing well
2. **Document As You Go**: Update SKILL.md as the skill evolves
3. **Version Your Skills**: Track changes in git
4. **Share Learnings**: Document what works and what doesn't
5. **Iterate**: Skills can be improved over time based on usage

## Troubleshooting

### Skill Not Found
- Verify the skill directory exists in `~/.agents/skills/`
- Check that `SKILL.md` has correct YAML frontmatter
- Ensure the `name` field matches the directory name

### Path Issues
- Use `~/.agents/skills/` for all absolute paths in skills
- Test paths with `ls ~/.agents/skills/your-skill/`
- Check file permissions if scripts aren't executing

### Skill Not Working as Expected
- Review the instructions in SKILL.md for clarity
- Test with simple inputs first
- Check for typos in file paths or commands
- Verify any required dependencies are installed

## Resources

- [Claude Code Documentation](https://github.com/anthropics/claude-code)
- [Creating Skills Guide](https://github.com/anthropics/claude-code/docs/skills.md)
- Example skills in this directory

## Contributing

When creating new skills:
1. Follow the conventions outlined above
2. Test thoroughly before committing
3. Update this AGENTS.md file
4. Consider adding examples or sample outputs

---

*Last updated: 2026-01-03*

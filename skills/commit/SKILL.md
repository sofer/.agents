---
name: commit
description: Format commit messages following Conventional Commits. Use when user has staged changes and wants to commit, or asks about commit message format.
---

# Conventional Commits Helper

When the user wants to make a commit:

## 1. Review Changes

First, understand what has changed:
- Check `git status` to see modified files
- Review `git diff` to understand the changes
- Ask user for clarification if the purpose isn't clear

## 2. Format

Propose a commit message following this format:

```
<type>[optional scope]: <description>
```

## 3. Types

Choose the appropriate type:

- **feat**: New features
- **fix**: Bug fixes
- **docs**: Documentation changes
- **style**: Code style changes (formatting, missing semicolons, etc.)
- **refactor**: Code refactoring without feature changes
- **test**: Adding or updating tests
- **chore**: Maintenance tasks (build, dependencies, etc.)

## 4. Guidelines

- Use lowercase for type and description
- Keep description under 50 characters
- Use imperative mood: "add feature" not "added feature"
- Reference issue numbers when applicable: `feat(auth): add login (#123)`
- **Do not add attribution footers** (no "Generated with...", no "Co-Authored-By: AI")

## 5. Examples

Good commit messages:
```
feat(quiz): add question filtering by topic
fix(storage): resolve file encoding issue
docs: update README with installation instructions
test(quiz): add unit tests for get_next function
refactor(storage): simplify file reading logic
chore(deps): update pytest to 7.4.0
```

## 6. Propose and Execute

1. Propose the formatted commit message to the user
2. If user approves, execute: `git commit -m "your message"`
3. Confirm the commit was successful

## Notes

This follows the Conventional Commits specification (https://www.conventionalcommits.org/), which:
- Makes commit history readable
- Enables automatic changelog generation
- Helps teams understand changes at a glance
- Works with semantic versioning tools

The format is platform-agnostic and works with all git workflows.

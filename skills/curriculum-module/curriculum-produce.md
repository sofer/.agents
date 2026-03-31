---
name: curriculum-produce
description: "Generate upload-ready markdown and UI instructions from a curriculum outline file. Use after curriculum-explore has created an outline, or when the user has a manually-written outline."
type: atomic
input: "Path to a module outline file (YAML frontmatter)"
output: "Upload-ready markdown files and UI instructions saved to a directory"
---

# Curriculum produce

## Purpose

Read a module outline file and generate:
1. Step-by-step UI instructions for creating the module and articles
2. Upload-ready markdown for each article (compatible with the platform's bulk exercise upload)
3. A summary of what was generated

## Instructions

### 1. Locate the outline

Ask the user for the path to the outline file, or use the path from the explore phase if still in the same session.

Read the outline file and parse the YAML frontmatter.

### 2. Create output directory

Create a directory alongside the outline file: `<outline-directory>/<topic-slug>/`

All output files go here.

### 3. Generate UI instructions

Write `instructions.md` to the output directory. Structure:

```markdown
# [Module Name] — Setup instructions

## Step 1: Create the module

1. Go to learn.foundersandcoders.com/admin
2. Click the Curriculum tab in the top nav
3. Click the + button next to the module list to create a new module
4. Set the following fields:
   - **Name:** [from outline]
   - **Type:** [from outline, e.g. TUTORIAL]
   - **Hours:** [from outline]
   - **Tags:** [from outline, comma-separated]
   - **Status:** DRAFT

## Step 2: Create article "[Article 1 Title]"

1. With the module selected, click the + button to create a new article
2. Set the article title to: [title]
3. Click the **Upload** tab
4. Open the file `article-1-[slug].md` from this directory
5. Copy the entire contents and paste into the upload text area
6. Ensure "Upload as Draft" is selected (toggle if needed)
7. Click **Create Exercises**
8. Verify the exercise count matches: [N] exercises expected

[Repeat for each article]

## Summary

- **Module:** [name]
- **Articles:** [count]
- **Total exercises:** [count across all articles]
- **Estimated hours:** [hours]
```

### 4. Generate upload markdown for each article

For each article in the outline, write `article-N-<slug>.md` to the output directory.

The markdown must be compatible with the platform's bulk upload parser. Format rules:

- Sections separated by `---` on its own line (with blank lines before and after)
- Each section becomes one exercise
- Exercise ordering follows section order in the file

#### Section types

**Explanation sections** (chapter intros and steps):

```markdown
## [Step Title]

[Content: motivating scenario, concept explanation, worked examples as appropriate]

[Use concrete examples with specific numbers, code snippets, or scenarios]

[Keep each section focused on one idea]
```

These become `EXPLANATION_TEXT` exercises.

**Question sections:**

```markdown
## [Short question topic]

**Question:** [Full question text. Be specific. Give the learner a concrete scenario or problem to work through.]

**Answer:** [Model answer. Show the reasoning, not just the final answer. Include worked calculations where relevant.]
```

These become `QUESTION_TEXT_OPEN_ENDED` exercises.

#### Article structure

Each article's markdown should follow this order:

1. **Chapter introduction** — first section. Brief motivating scenario (2-3 sentences), what the chapter covers, prerequisites if any.
2. **Explanation steps** — one section per concept. Each step: brief motivating context, formal explanation, worked example.
3. **Questions** — final sections. 4-6 questions testing the chapter's concepts.

#### Content guidelines

- Second person ("you", "your")
- Informal but precise
- Technical terms introduced explicitly on first use
- Short paragraphs (3-4 sentences max)
- British English
- Use `##` for all headings (never `#`)
- Include concrete examples with specific numbers
- Questions should require applying understanding, not just recalling definitions
- Model answers should show reasoning, not just state the answer

### 5. Generate summary

Print a summary to the user:

```
Generated [N] files in [output directory]:
- instructions.md (UI setup guide)
- article-1-[slug].md ([N] exercises)
- article-2-[slug].md ([N] exercises)
...
Total: [N] exercises across [N] articles
```

### 6. Offer next steps

Tell the user: "You can now follow the instructions in instructions.md to create the module. The article markdown files are ready to paste into the bulk upload."

## Error handling

- If the outline file is missing or has no YAML frontmatter, stop and report: "Could not find a valid outline at [path]. Run curriculum-explore first or check the file path."
- If an article has no steps or questions defined, warn the user and skip that article
- If an article has more than 7 questions, warn: "Article [title] has [N] questions. Consider splitting into two chapters."

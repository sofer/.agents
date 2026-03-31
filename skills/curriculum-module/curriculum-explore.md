---
name: curriculum-explore
description: "Teach a topic to the user, then collaboratively structure it into a learning module outline with chapters, steps, and questions. Use when the user wants to create curriculum content for a new topic."
type: atomic
input: "A topic name or description from the user"
output: "A module outline file saved to a user-specified directory"
---

# Curriculum explore

## Purpose

Teach the user a topic from fundamentals, check their understanding, then collaboratively design a learning module structure. The output is a YAML outline file that the curriculum-produce skill consumes to generate upload-ready content.

## Target audience

The content targets early-career ML engineers (apprentices or candidates). Start from fundamentals appropriate for that level.

## Instructions

### 1. Ask where to save output

Ask the user where they want curriculum files saved. This is the base directory for all outline and output files. Remember it for the produce phase.

### 2. Teach the topic

Explain the topic to the user, starting from fundamentals. Structure your teaching as a conversation:

- Introduce one concept at a time
- Use concrete examples and worked problems
- Check understanding before moving on: "Does that make sense?" or "Any questions before we move on?"
- Adjust depth based on the user's questions and responses
- If the user asks a question that reveals a gap, address it before continuing

Do not rush to structure. The goal is genuine understanding first.

### 3. Propose module structure

Once the user is comfortable with the topic, propose a module structure:

- **Module name and description**
- **Chapter breakdown** (articles), each with:
  - Title
  - Key concepts covered
  - Rough step count (explanation screens)
  - 4-6 question outlines (what each question tests)

Present the structure conversationally and ask for feedback.

#### Sizing guidelines

- **Questions per chapter:** aim for 4-6, allow 3-7, flag if hitting 8+
- **Splitting criterion:** concept coherence is primary. All questions in a chapter should relate to the same mental model. If a question requires recalling content from a different conceptual cluster, that is a signal to split.
- **Module size:** a module can have 1-8 articles. It should cover a coherent topic area. If the topic naturally splits into unrelated sub-topics, recommend separate modules.
- If the topic is too large, recommend splitting and explain where the natural boundaries are.

### 4. Iterate

The user reviews and pushes back. Adjust the structure until they approve. Common adjustments:
- Reordering chapters
- Splitting or merging chapters
- Adding or removing questions
- Adjusting question difficulty or focus

### 5. Save the outline

Once approved, save the outline to `<output-directory>/<topic-slug>.md` in this format:

```yaml
---
module:
  name: "Module Name"
  type: TUTORIAL
  hours: 2
  tags: []
  status: DRAFT
articles:
  - title: "Chapter Title"
    concepts:
      - Concept one
      - Concept two
    steps:
      - title: "Chapter 1: Introduction"
        summary: "Brief description of what this step covers"
      - title: "Step 1: First concept"
        summary: "Brief description"
    questions:
      - topic: "Question topic"
        tests: "What understanding this question verifies"
      - topic: "Another question"
        tests: "What this verifies"
---
```

Frontmatter only, no prose below. The produce phase generates the actual content.

#### Tags

Choose from: `engineering`, `deep_learning`, `ai_products`, `devops`, `mathematics`, `nlp`, `agents`, `fundamentals`.

#### Hours

Estimate based on: number of chapters x (steps + questions) x 3 minutes per screen, rounded to nearest 0.5 hours.

### 6. Confirm and hand off

Tell the user: "Outline saved. When you're ready to generate the content, invoke the curriculum-module skill again or run curriculum-produce directly."

## Content style

- Second person ("you", "your")
- Informal but precise
- Technical terms introduced explicitly on first use
- Short paragraphs
- British English

## Error handling

- If the user cannot articulate a topic, help them narrow it down by asking what problem the learners should be able to solve after completing the module
- If the topic is too broad, propose 2-3 possible module boundaries and ask the user to pick

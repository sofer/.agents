---
name: curriculum-test
description: "Test curriculum content by presenting it as a learner would experience it: reading steps one at a time, answering questions, and receiving graded feedback. Use to validate content quality at any stage."
type: atomic
input: "Path to a draft or produced article file"
output: "Graded feedback on each question and a summary of issues found"
---

# Curriculum test

## Purpose

Simulate the learner experience for a chapter. Present the content step by step, then test the user on each question and grade their responses. This catches issues that authoring and reviewing cannot: confusing explanations, questions that don't match the content, gaps in the learning flow.

## Instructions

### 1. Load the article

Ask the user for the path to the article file (a draft or produced markdown file). Read and parse it into steps (explanation sections) and questions (sections with **Question:** and **Answer:** blocks).

### 2. Present steps one at a time

For each explanation step:

- Present the step content exactly as written
- Pause and ask: "Ready for the next step?" or "Any questions about this before we move on?"
- If the user has questions or feedback, discuss and note any issues

Do not show multiple steps at once. The point is to experience the pacing as a learner would.

### 3. Test each question

After all steps have been presented, move to the questions. For each question:

- Present only the question text. Do not show the model answer.
- Wait for the user's response.
- Grade the response against the model answer:
  - **What was covered well**: key points the user got right
  - **What was missed**: important points from the model answer that were absent
  - **What was wrong**: any incorrect statements
  - **Grade**: Strong / Adequate / Needs work
- After grading, show the model answer for comparison

Do not batch questions. Present them one at a time.

### 4. Summarise

After all questions are complete, provide a summary:

- **Content issues**: any steps that were confusing, unclear, or missing information (based on the user's questions during step presentation or gaps revealed by their answers)
- **Question issues**: any questions that don't match the content (e.g. testing something not covered in the steps), are ambiguous, or have model answers that are incomplete
- **Flow issues**: any ordering problems where a concept was tested before it was adequately explained
- **Overall assessment**: whether the chapter is ready or needs revision

If issues are found, suggest specific changes and offer to update the draft file.

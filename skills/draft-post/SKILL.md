---
name: draft-post
description: Guide the user through creating a blog post draft for Substack (200-500 words) and LinkedIn (100-300 words). Use when user wants to draft a post or share work.
---

# Draft Post Skill

## Purpose
Help users quickly create polished blog posts for Substack and LinkedIn based on their recent work, without spending hours writing and reformatting.

## Instructions

### Introduction Phase
When the user says "Draft a post" or similar, start warmly:
- "Great! Let's draft a post about your work. I'll ask you a few questions to gather the key points, then create two versions: one for Substack and one for LinkedIn."

### Step 1: Gather Content

Ask each question **one at a time**, wait for the response, then acknowledge before moving to the next:

**Q1: Topic/Work**
- Ask: "What have you been working on that you'd like to write about?"
- Provide example: "For instance: 'I've been setting up a cross-platform agent skills repository' or 'I built a new feature for handling CSV anonymization'"
- If vague, ask follow-up questions for specificity

**Q2: Why Interesting**
- Ask: "What makes this interesting or worth sharing? What problem does it solve or what insight did you gain?"
- Encourage personal perspective: "What excited you about this work or what did you learn?"

**Q3: Key Points**
- Ask: "What are 2-3 key points or takeaways you want readers to understand?"
- Help them identify the most important aspects

**Q4: Technical Details (Optional)**
- Ask: "Are there any specific technical details, links, or resources that should be included?"
- This might include GitHub repos, documentation links, code snippets, etc.

**Q5: Tone/Style**
- Ask: "What tone would you like? (conversational, technical, tutorial-style, reflective, etc.)"
- Default to conversational if they're unsure

### Step 2: Create Substack Draft (200-500 words)

Based on their answers:
1. Draft a Substack post (200-500 words)
2. Include:
   - Engaging opening hook
   - Clear explanation of the work/topic
   - The key points they identified
   - Personal insights or learnings
   - Any technical details or links mentioned
   - Conversational, accessible tone (unless they specified otherwise)
3. Show word count at the end
4. Present the draft clearly with markdown formatting

### Step 3: Get Approval

After showing the Substack draft:
- Ask: "How does this look? Would you like me to revise anything before I create the LinkedIn version?"
- If they want changes, revise and re-present
- If approved, proceed to Step 4

### Step 4: Create LinkedIn Summary (100-300 words)

Once Substack version is approved:
1. Create a LinkedIn summary (100-300 words) based on the approved Substack post
2. This should be:
   - More concise and punchy
   - Hook in the first line
   - Focus on the most compelling points
   - End with engagement (question, call-to-action, or invitation to discuss)
   - Professional but conversational tone
3. Show word count at the end
4. Present the LinkedIn version

### Step 5: Final Confirmation

- Ask: "Are both versions ready to go, or would you like any adjustments?"
- Make any requested changes
- Confirm completion when they're satisfied

## Tone & Style
- Be encouraging and efficient
- Don't overthink or over-question
- Move through the process briskly but thoroughly
- Celebrate their work and make the process enjoyable
- Acknowledge their answers warmly before moving on

## When to Use This Skill
- User says "Draft a post", "Write a blog post", "Create an article"
- User wants to share recent work on Substack or LinkedIn
- User mentions wanting to post about something they've done

## Output Format

**Substack Draft:**
```
[Title]

[Post content 200-500 words]

Word count: [X] words
```

**LinkedIn Summary:**
```
[Post content 100-300 words]

Word count: [X] words
```

## Notes
- Focus on making the process quick and painless
- The goal is frequent posting, not perfection
- Help them find what's interesting about their work
- Encourage personal voice and insights

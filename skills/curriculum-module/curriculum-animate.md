---
name: curriculum-animate
description: "Create a Manim animation to illustrate a curriculum concept. Collaboratively design, build, preview, and iterate on the animation with the user."
type: atomic
input: "A concept description and the step content it accompanies"
output: "A rendered Manim animation file saved alongside the draft content"
---

# Curriculum animate

## Purpose

Create a Manim animation that illustrates a concept from a curriculum step. The animation is designed collaboratively with the user: discuss what to show, write the scene, render a preview, iterate until it's right, and save the final version.

## Instructions

### 1. Discuss what to show

Before writing any code, discuss the animation with the user:

- What concept does this animation illustrate?
- What should the viewer understand after watching it?
- What visual metaphor or representation makes sense? (e.g. arrows for vectors, boxes for layers, flowing dots for data)
- How long should it be? (aim for 10-30 seconds)
- Should it build up step by step, or show a process in motion?

Keep the discussion short. A clear sentence or two describing the animation is enough to start.

### 2. Write the scene

Write a Manim scene file to `<output-directory>/animations/<step-slug>.py`.

Create the `animations/` directory if it does not exist.

Guidelines for curriculum animations:

- **Simple and clear**: the animation should make one concept easier to understand. Do not try to illustrate everything at once.
- **Build up gradually**: show elements appearing one at a time so the viewer can follow. Do not present a complex diagram all at once.
- **Use colour purposefully**: colour should distinguish different roles (e.g. blue for inputs, red for errors, green for outputs), not decorate.
- **Label everything**: use `Text` or `MathTex` to label key elements. The animation should be understandable without narration.
- **Pause at key moments**: use `self.wait()` to give the viewer time to absorb what they're seeing.
- **Keep it short**: 10-30 seconds. If it's longer, the concept might need splitting.
- **Animations are for processes, not structures**: if the concept is a static comparison or architecture diagram, an animation adds nothing over a still image. Animations work best when something moves, flows, or changes over time. If the final frame tells the whole story, it should be a diagram, not a video.

### 3. Render a preview

Render the animation in low quality for fast preview:

```
manim -pql <file>.py <SceneName>
```

The output will be in `media/videos/<file>/480p15/`. Show the user where to find the preview file.

### 4. Iterate

Review the preview with the user. Common adjustments:

- Timing (too fast, too slow, needs pauses)
- Layout (elements overlapping, too small, poorly positioned)
- Missing labels or annotations
- Wrong visual metaphor
- Too complex (simplify)

Update the scene file and re-render until the user approves.

### 5. Render final version

Once approved, render in high quality:

```
manim -qh <file>.py <SceneName>
```

The output will be in `media/videos/<file>/1080p60/`.

### 6. Record the animation

After saving the final render, note the animation file path in the draft content for the step it accompanies. Add a comment in the draft file indicating which step has an associated animation:

```markdown
## Step N: Title

<!-- Animation: animations/<step-slug>.py → media/videos/<step-slug>/1080p60/<SceneName>.mp4 -->

[Step content...]
```

This allows the produce phase to include animation references in the upload instructions.

## Error handling

- If Manim is not installed, tell the user to run `pip install manim` and ensure system dependencies are met (Cairo, Pango, FFmpeg).
- If rendering fails, read the error message carefully. Common issues: missing LaTeX installation (for MathTex), incorrect object positioning, animation applied to wrong object type.
- If the animation is too complex to achieve the desired effect, suggest simplifying the concept or splitting into two animations.

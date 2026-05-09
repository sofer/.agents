#!/usr/bin/env node
import fs from 'node:fs';

const file = process.argv[2];
if (!file) {
  console.error('Usage: analyse-module-content.mjs <module-content.json>');
  process.exit(1);
}

const data = JSON.parse(fs.readFileSync(file, 'utf8'));
const lessons = data.lessons ?? [];
const exercises = data.exercises ?? [];
const activeLessonIds = new Set(lessons.filter((l) => l.status === 'ACTIVE').map((l) => l.id));
const deletedLessonIds = new Set(lessons.filter((l) => l.status === 'DELETED').map((l) => l.id));

function groupBy(items, keyFn) {
  const map = new Map();
  for (const item of items) {
    const key = keyFn(item);
    if (!map.has(key)) map.set(key, []);
    map.get(key).push(item);
  }
  return map;
}

function line(text = '') {
  console.log(text);
}

line(`# Module ${data.module?.id ?? '(unknown)'} structural audit`);
line();
line(`Module: ${data.module?.name ?? '(missing)'}`);
line(`Status: ${data.module?.status ?? '(missing)'}`);
line(`Lessons: ${lessons.length} total, ${activeLessonIds.size} active, ${deletedLessonIds.size} deleted`);

const activeExercises = exercises.filter((e) => e.status === 'ACTIVE' && e.type);
const visibleActiveExercises = activeExercises.filter((e) => activeLessonIds.has(e.lesson_id));
const hiddenActiveExercises = activeExercises.filter((e) => !activeLessonIds.has(e.lesson_id));
line(`Exercises: ${activeExercises.length} active typed, ${visibleActiveExercises.length} under active lessons, ${hiddenActiveExercises.length} hidden by lesson status`);
line(`KSBs: ${(data.ksb ?? []).length}`);
line();

if (hiddenActiveExercises.length) {
  line('## Active exercises under non-active lessons');
  for (const [lessonId, rows] of groupBy(hiddenActiveExercises, (e) => e.lesson_id)) {
    const lesson = lessons.find((l) => l.id === lessonId);
    line(`- lesson ${lessonId} (${lesson?.status ?? 'missing'}): ${rows.length} active exercises`);
    line(`  ids: ${rows.map((e) => e.id).join(', ')}`);
  }
  line();
}

const duplicateExerciseOrders = [];
for (const [lessonId, rows] of groupBy(exercises, (e) => e.lesson_id)) {
  for (const [order, sameOrder] of groupBy(rows, (e) => e.order_position)) {
    if (sameOrder.length > 1) duplicateExerciseOrders.push({ lessonId, order, rows: sameOrder });
  }
}
if (duplicateExerciseOrders.length) {
  line('## Duplicate exercise order positions');
  for (const item of duplicateExerciseOrders) {
    line(`- lesson ${item.lessonId}, order ${item.order}: ${item.rows.map((e) => `${e.id} ${e.title}`).join(' | ')}`);
  }
  line();
}

const longTitles = exercises.filter((e) => (e.title ?? '').length >= 75);
if (longTitles.length) {
  line('## Long or likely truncated titles');
  for (const e of longTitles) line(`- ${e.id} lesson ${e.lesson_id}: ${e.title}`);
  line();
}

const genericTitles = exercises.filter((e) => ['section', 'todo', 'fixme'].includes((e.title ?? '').trim().toLowerCase()));
if (genericTitles.length) {
  line('## Generic titles');
  for (const e of genericTitles) line(`- ${e.id} lesson ${e.lesson_id}: ${e.title}`);
  line();
}

function isBlank(value) {
  return typeof value !== 'string' || value.trim().length === 0;
}

function summariseMissingContent(e) {
  const missing = [];
  if (e.type === 'EXPLANATION_TEXT' && isBlank(e.explanation_text)) {
    missing.push('explanation_text');
  }
  if (e.type === 'EXPLANATION_VIDEO' && isBlank(e.explanation_video_url)) {
    missing.push('explanation_video_url');
  }
  if ((e.type ?? '').startsWith('QUESTION_') && isBlank(e.question_text)) {
    missing.push('question_text');
  }
  if (e.type === 'QUESTION_TEXT_OPEN_ENDED' && isBlank(e.answer_snippet)) {
    missing.push('answer_snippet');
  }
  if (e.type === 'QUESTION_MULTIPLE_CHOICE') {
    if (!Array.isArray(e.question_multiple_choice_list) || e.question_multiple_choice_list.length === 0) {
      missing.push('question_multiple_choice_list');
    }
    if (!Array.isArray(e.question_multiple_choice_solution) || e.question_multiple_choice_solution.length === 0) {
      missing.push('question_multiple_choice_solution');
    }
  }
  if (e.type === 'QUESTION_CODE') {
    if (isBlank(e.question_code_init)) missing.push('question_code_init');
    if (isBlank(e.question_code_test)) missing.push('question_code_test');
  }
  if (e.type === 'QUESTION_SQL' && isBlank(e.question_sql_database_url)) {
    missing.push('question_sql_database_url');
  }
  return missing;
}

const missingContent = activeExercises
  .map((e) => ({ exercise: e, missing: summariseMissingContent(e) }))
  .filter((item) => item.missing.length > 0);
if (missingContent.length) {
  line('## Missing type-specific content fields');
  for (const item of missingContent) {
    line(`- ${item.exercise.id} lesson ${item.exercise.lesson_id} ${item.exercise.type}: ${item.exercise.title} (${item.missing.join(', ')})`);
  }
  line();
}

const internalWording = [];
for (const e of exercises) {
  const text = [e.title, e.explanation_text, e.question_text, e.question_instructions].filter(Boolean).join('\n');
  if (/\bfile\s+\d+\b|TODO|FIXME/i.test(text)) internalWording.push(e);
}
if (internalWording.length) {
  line('## Internal wording markers');
  for (const e of internalWording) line(`- ${e.id} lesson ${e.lesson_id}: ${e.title}`);
  line();
}

const duplicatePrompts = [];
for (const [prompt, rows] of groupBy(
  exercises.filter((e) => (e.question_text || e.title || '').trim()),
  (e) => (e.question_text || e.title || '').trim(),
)) {
  if (rows.length > 1) duplicatePrompts.push({ prompt, rows });
}
if (duplicatePrompts.length) {
  line('## Duplicate prompts or titles');
  for (const item of duplicatePrompts.slice(0, 30)) {
    line(`- ${item.prompt}: ${item.rows.map((e) => e.id).join(', ')}`);
  }
  if (duplicatePrompts.length > 30) line(`- ... ${duplicatePrompts.length - 30} more`);
}

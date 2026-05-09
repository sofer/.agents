WITH module_row AS (
  SELECT
    id, name, text, status, level, hours, module_type, tags, is_core,
    access_roles, created_at, updated_at
  FROM cortex.modules
  WHERE id = :module_id
),
lessons_json AS (
  SELECT COALESCE(jsonb_agg(to_jsonb(l) ORDER BY l.order_position, l.id), '[]'::jsonb) AS lessons
  FROM (
    SELECT
      id, module_id, title, text, status, level, order_position, img_url,
      attachment_url, attachment_name, created_at, updated_at
    FROM cortex.lessons
    WHERE module_id = :module_id
  ) l
),
exercises_json AS (
  SELECT COALESCE(jsonb_agg(to_jsonb(e) ORDER BY e.lesson_id, e.order_position, e.id), '[]'::jsonb) AS exercises
  FROM (
    SELECT
      id, module_id, lesson_id, title, type, order_position, xp_points,
      answer_snippet, explanation_text, explanation_video_url, question_slides_url,
      question_text, question_instructions, question_code_init,
      question_code_init_language, question_code_test, question_code_test_language,
      question_code_solution, question_multiple_choice_list,
      question_multiple_choice_solution, question_sql_database_url, status,
      created_at, updated_at
    FROM cortex.exercises
    WHERE module_id = :module_id
  ) e
),
ksb_json AS (
  SELECT COALESCE(jsonb_agg(jsonb_build_object(
    'reference', ok.reference,
    'code', ok.code,
    'type', ok.type,
    'description', ok.description
  ) ORDER BY ok.reference, ok.code), '[]'::jsonb) AS ksb
  FROM cortex.module_to_ksb mtk
  JOIN oracle.ksb ok ON ok.id = mtk.ksb_id
  WHERE mtk.module_id = :module_id
)
SELECT jsonb_pretty(jsonb_build_object(
  'module', (SELECT to_jsonb(module_row) FROM module_row),
  'lessons', (SELECT lessons FROM lessons_json),
  'exercises', (SELECT exercises FROM exercises_json),
  'ksb', (SELECT ksb FROM ksb_json)
));

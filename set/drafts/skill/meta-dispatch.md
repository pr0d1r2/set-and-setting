# Skill: meta-dispatch

A meta-skill assigns skill sets to tasks dynamically based on task
characteristics rather than static configuration.

## Rules

- Meta-dispatch examines task type (bug fix, feature, refactor,
  review, research) and selects relevant skill sets.
- Selection is additive: base set always loads, domain sets layer on.
- Task signals: file extensions touched, directories modified, commit
  message keywords, branch name patterns.
- Meta-dispatch config lives outside skill files — it is operational
  configuration, not skill knowledge.
- Avoid over-loading: prefer fewer focused skills over all skills
  always. Context window is finite.

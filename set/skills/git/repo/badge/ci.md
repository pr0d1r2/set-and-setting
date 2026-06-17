# Git repo: CI badge

CI status badges in README.md show build health at a glance. They
link to the pipeline or workflow so visitors can inspect failures.

## When CI is added

Add a badge to README.md immediately after the license badge:

```markdown
[![CI](https://github.com/OWNER/REPO/actions/workflows/ci.yml/badge.svg)](https://github.com/OWNER/REPO/actions/workflows/ci.yml)
```

For GitLab:

```markdown
[![pipeline status](https://gitlab.example.com/OWNER/REPO/badges/main/pipeline.svg)](https://gitlab.example.com/OWNER/REPO/-/commits/main)
```

## Badge ordering convention

Badges in README.md follow this order:

1. CI status (most important -- is it building?)
2. License (legal terms)
3. NixOS version (platform compatibility)
4. Other project-specific badges

Keep badges on a single line separated by spaces. Each badge links to
its source (workflow, license file, nixpkgs branch).

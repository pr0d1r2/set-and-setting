# Skill: interchange

Skills are portable across repos that share the `agent/set/skills/`
convention. When a skill applies to multiple projects, keep its content
identical in all of them -- divergence means one copy improves while
others rot.

## Interchange rules

- **Generic skills copy verbatim.** Skills about shell, nix, lefthook,
  tdd, gnu tools, git conventions, etc. are project-agnostic. Their
  content must be identical across all repos that carry them.
- **Project-specific skills stay local.** Skills about trips, ISOs,
  qemu, NixOS systemd services, etc. belong only to repos that use
  those concepts.
- **Superset wins.** When two repos have the same skill with different
  content, merge into the superset -- the version with more rules,
  better structure, or additional sub-skills. Never silently drop rules
  during sync.
- **Sub-skills increase portability.** A monolithic `security.md` is
  harder to share than `security.md` + `security/credentials.md` +
  `security/hardening.md`. Split when a facet applies independently to
  other repos.
- **Sync direction: newest wins.** After merging into superset, copy
  the result to all repos that carry that skill. Update import lines
  if sub-skills were added.

## Interchange workflow

1. List skills across repos: `find agent/set/skills/ -type f` in each.
2. Diff common skills: content should be identical for generic ones.
3. For each divergence: merge into superset, copy to all repos.
4. For skills only in one repo: decide if generic (copy to others) or
  project-specific (leave).
5. For missing sub-skills: split if a facet would be useful
  independently.

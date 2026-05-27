# NixOS: users

Every NixOS user and group must use a unique numeric uid / gid.

NixOS enforces this at module-eval time. A collision aborts the whole
`nixosConfigurations.<host>` evaluation -- no ISO, no toplevel, no
partial build. The error surfaces late (mid-build) with no file/line
pointer to the colliding users.

When adding or editing a user:

1. Grep the tree for every existing `uid = <n>;` and `gid = <n>;`
   before picking a number.
2. Allocate the next free integer above the current maximum -- do not
   reuse gaps left by renamed/removed users; gaps are cheap, collisions
   are not.
3. Keep `users.users.<name>.uid` and `users.groups.<name>.gid`
   numerically equal for that user (convention -- makes the pair
   grep-able and keeps ownership reasoning obvious).

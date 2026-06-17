# Security: hardening

Security hardening is documented in `HARDENING.md` at the repo root.
This skill covers the patterns used and how to extend them.

## Adding a new service

When adding a systemd service:

1. Start with `ProtectSystem=strict`, `NoNewPrivileges=true`,
  `PrivateTmp=true`
2. Add `BindPaths` only for directories the service actually writes
3. Use `IPAddressDeny=any` + `IPAddressAllow` if the service needs
  network
4. Set `CapabilityBoundingSet=""` unless specific capabilities are
  required
5. Document any relaxations with a comment explaining why

## Deferred hardening

Items in HARDENING.md under "Deferred for development" are release
gates. When re-enabling: uncomment the import, rebuild, run full
integration test suite.

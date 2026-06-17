# Test: security

Security validation happens in integration test health checks. Every
security-relevant feature must have a corresponding assertion.

## When to add a security assertion

Any change that affects the attack surface:

- New network listener -- assert it binds only where expected
- New user or privilege change -- assert locked password, correct
  shell, correct groups
- Firewall rule change -- assert chain contents
- New secret or credential -- assert file permissions and ownership
- New outbound connection -- assert it appears in allow lists

## Pattern

Assert the positive case (rule exists, service active) rather than the
negative (port closed) -- the firewall's default-deny handles the
negative.

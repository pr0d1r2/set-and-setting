# NixOS: systemd

Systemd service configuration patterns used in NixOS modules.

## Service types

| Type | Use case | Example |
| ---- | -------- | ------- |
| `simple` | Long-running daemon | daemons, tunnels |
| `oneshot` | Run-once at boot | setup scripts, storage mounts |
| `oneshot` + `RemainAfterExit` | Run-once, stay "active" | caches, gateways |

## Restart policy

- `Restart=always` for services that must survive crashes and clean
  exits
- `RestartSec=2s` for fast recovery without tight loop
- Never use `Restart=on-failure` for services that exit 0 on
  completion but must restart to poll for next work

## SuccessExitStatus

Tells systemd to treat listed exit codes as success. Prevents
`[FAILED]` in boot log for expected non-zero exits:

```nix
serviceConfig = {
  SuccessExitStatus = "0 1 2";
};
```

Use when: a service legitimately exits non-zero in some scenarios
(cache miss, optional feature unavailable, network timeout on
best-effort service). Do not use to mask real failures.

## Ordering and dependencies

- `After = [ "network-online.target" ]` for services needing network
- `Before = [ "multi-user.target" ]` for services that must finish
  before login
- `ConditionPathIsDirectory` / `ConditionPathExists` to skip services
  when prerequisites are missing
- `OnFailure = [ "poweroff.target" ]` for critical services where
  failure means the node is unsafe

## Sandbox directives cheat sheet

Start with maximum restriction, relax as needed:

```nix
serviceConfig = {
  # Filesystem
  ProtectSystem = "strict";    # /usr, /boot read-only
  ProtectHome = "tmpfs";       # /home replaced with empty tmpfs
  PrivateTmp = true;           # private /tmp
  BindPaths = [ "/path/to/writable" ];
  BindReadOnlyPaths = [ "/nix/store" "/etc" ];

  # Privilege
  NoNewPrivileges = true;
  CapabilityBoundingSet = "";  # zero capabilities
  RestrictSUIDSGID = true;

  # Network
  IPAddressDeny = "any";
  IPAddressAllow = [ "127.0.0.1/32" "::1/128" ];
  RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];

  # Kernel
  ProtectKernelTunables = true;
  ProtectKernelModules = true;
  ProtectKernelLogs = true;
  ProtectControlGroups = true;
  ProtectClock = true;
  ProtectHostname = true;

  # Syscalls
  SystemCallFilter = [ "@system-service" "~@privileged" ];
  SystemCallArchitectures = "native";

  # Resources
  MemoryMax = "80%";
  TasksMax = 512;
};
```

## Testing changes

After modifying a service, run integration tests to verify the service
starts and the system reaches `multi-user.target`. Check journalctl
output for the service in health checks.

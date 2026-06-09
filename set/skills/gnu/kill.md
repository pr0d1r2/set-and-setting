# GNU kill and process groups

Use `kill`, `pkill`, and `pgrep` from the dev shell (nixpkgs
`procps`), never `/bin/kill`. A negative PID signals a whole process
group on both BSD and GNU, so the syntax is not the portability risk
people assume: `kill -9 -- -"$pgid"`.

The target must be a group leader (made by `setsid`, or by expect
`spawn` via forkpty) for `-pgid` to mean the whole tree. `pkill -P`
reaches only direct children, so a deeper `ssh` or `qemu` survives it
and keeps a pty open. `setsid` is missing on macOS, so rely on a tool
that already made its own session rather than making one.

## Background group terminal stop

A process in a background process group that writes (SIGTTOU) or
reads (SIGTTIN) the controlling terminal is stopped, not killed and
not failed. Under `git push` the pre-push hook runs in a background
group while stdin stays the terminal, so a `[ -t 0 ]` guard passes
and any `/dev/tty` access (`stty`, `read -s`, terminal-drain code)
freezes the hook until its timeout kills it.

Ignore both signals before touching the terminal so the operations
proceed, or fail with EIO, instead of stopping:

```sh
(
  [ -t 0 ] || exit 0
  trap '' TTOU TTIN
  stty sane </dev/tty >/dev/tty 2>/dev/null || true
  read -r -t 0.3 -n 10000 -s </dev/tty 2>/dev/null || true
)
```

Ignored signal settings survive `exec`, so an external `stty`
inherits them and will not stop. Symptom: a script prints its final
line, then sits alive but frozen until a timeout reports 124.

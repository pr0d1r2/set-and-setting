# Shell: blackbox

Build every shell script as a blackbox: a standalone unit with defined
inputs (arguments, stdin, environment) and outputs (stdout, exit code).
Compose behavior by invoking other script blackboxes, never by defining
or calling shell functions within the same file.

## Why

- **Rewritable.** Each blackbox has an explicit contract (args in,
  stdout out, exit code). Replacing `bash tool.sh` with a compiled
  `./tool` binary (Rust, Go, C) requires zero changes to callers --
  the interface is the process boundary.
- **Testable.** A blackbox is tested by running it and checking its
  output and exit code. No test harness needs to source internal
  functions or mock shell state.
- **Composable.** Scripts compose via pipelines, subshells, and
  process substitution -- the same mechanisms that compose any Unix
  program, regardless of implementation language.
- **Auditable.** Each file does one thing. Reading the filename and
  its `--help` output is enough to understand its role.

## Rules

1. One script, one responsibility. If a script needs helper logic,
    extract it into a separate script and invoke it.
2. No `function` keyword, no `name()` definitions. Inline the logic
    or call another script.
3. Accept inputs via positional arguments, named flags, environment
    variables, or stdin. Document which.
4. Produce structured output on stdout. Reserve stderr for
    diagnostics only.
5. Exit with a meaningful code: 0 for success, non-zero for failure.
6. Keep scripts small enough that rewriting one to a compiled
    language is a single-session task.

## Migration path

Shell is the prototyping language. Once a blackbox stabilizes:

1. Its contract (arguments, stdout format, exit code semantics) is
    already documented and tested.
2. Rewrite the internals in Rust (or another compiled language) behind
    the same contract.
3. Callers are unchanged -- they invoked a process, not a function.
4. Repeat per-blackbox; the system migrates incrementally.

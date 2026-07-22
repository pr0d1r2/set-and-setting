# Specification fidelity

Treat the task, specification, cited invariants, and pull request description
as testable claims. Try to find a difference between those claims and what the
diff actually does.

Check that:

- Each claimed requirement is implemented, including cited specification
  sections and invariants such as `V` and `C` references.
- The resulting behavior matches the words precisely; names or documentation
  do not promise more than the implementation guarantees.
- The diff stays inside the requested scope. Unrelated cleanup, opportunistic
  redesign, and speculative behavior are absent or separately justified.
- Defaults, edge cases, errors, and omissions do not create silent behavior
  drift beyond the declared change.
- The pull request description, tests, documentation, and generated artifacts
  agree with the implementation and with each other.

Build a requirement-to-diff map and look for requirements with no code or
evidence, and code with no requirement. Either gap is discord unless it is
explicitly justified. Accord means the change does what it says, satisfies the
governing invariants, and does only that.

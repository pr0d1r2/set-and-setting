# Integration

Prove that delivered work actually does what it claims. Every task
that changes observable behavior ships a self-contained verification
script as a phase artifact. The script executes the repo's own
build and test tooling against the real artifacts -- no assertions by
reading, no manual inspection.

See `integration/task/script.md` for the per-task verification script
convention and skeleton.

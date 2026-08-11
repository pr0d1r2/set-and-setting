# Rust equivalent

Search for a well-maintained Rust equivalent when selecting software whose
performance matters. Prefer the equivalent when it satisfies the requirements
with acceptable integration, safety, and ownership costs.

## Applying Rust equivalents

- Search the Rust ecosystem before adopting a tool, library, or custom
  implementation for a performance-sensitive task.
- Compare candidates on the workload that matters: correctness, latency,
  throughput, resource use, safety, portability, integration, maintenance, and
  license.
- Validate promising candidates with representative benchmarks or a focused
  spike. Measure the current option too; do not infer performance from the
  language alone.
- Reuse a maintained equivalent before writing a replacement. Check its
  release history, documentation, tests, security posture, and community
  health as part of the evaluation.
- Record why the selected option is the best fit and what evidence would cause
  the decision to be revisited.

## When another option is appropriate

Rust is a search heuristic, not a performance guarantee or a universal
requirement. Choose another implementation when it better meets the workload,
integration, portability, maturity, licensing, or ownership constraints.
Keep the comparison evidence-based and revisit it when requirements or
available implementations change. See also [[sutton]] and [[nih]].

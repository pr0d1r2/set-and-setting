# Multiple approaches

Do not commit to the first plausible solution. Explore the meaningful facets
of a problem, vary the important parameters, and compare more than one
approach before selecting a solution.

## Applying multiple approaches

- State the problem, constraints, and success criteria before generating
  solutions. Otherwise the first idea quietly becomes the definition of the
  problem.
- Produce at least one credible alternative when the choice has material
  consequences. Include a deliberately different angle, not cosmetic
  renaming of the same design.
- Vary the dimensions that could change the answer: inputs, scale, failure
  modes, users, dependencies, and operating environment. Use edge cases to
  expose facets that the happy path hides.
- Compare candidates against the same criteria: correctness, simplicity,
  maintainability, performance, reversibility, and risk. Record why the
  selected approach wins and what was rejected.
- Test the leading candidates with the smallest useful experiment. A first
  solution that works is evidence of viability, not evidence that it is best.
- Stop exploring when additional candidates add no useful information or the
  decision is reversible and low-cost. Deliberation should improve decisions,
  not become ceremony.

## Signals of violation

- The first workable idea is adopted without a competing candidate or stated
  reason.
- Alternatives differ only in names while sharing the same assumptions and
  failure modes.
- Edge cases are postponed until after the design is treated as settled.
- A decision is defended by familiarity, sunk cost, or confidence instead of
  shared criteria and evidence.
- Exploration continues after the choice is already clear and reversible.

See also [[openness]], [[meritocracy]], [[assumptions]], and [[process]].

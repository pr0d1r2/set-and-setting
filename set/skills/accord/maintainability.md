# Maintainability

Try to find the future maintenance trap: the part a new contributor would
misread, duplicate, or be afraid to change. Compare the diff with the
surrounding code rather than applying a foreign style preference.

Check that:

- Names reveal intent and boundaries; control flow and data flow are readable
  without reconstructing hidden assumptions.
- The change follows nearby idioms and uses the established abstraction level.
  Similar logic has one source of truth, without premature generalization.
- Comments explain durable reasons, constraints, or non-obvious trade-offs.
  Their density and tone fit the surrounding code, and they do not narrate
  obvious syntax or preserve obsolete history.
- No dead code, unused branch, debug aid, placeholder, compatibility shim
  without a removal plan, or generated scaffolding remains.
- The solution is the simplest form that satisfies the present requirements.
  Extra layers, options, configurability, and speculative extension points
  must earn their cost now (KISS and YAGNI).

Discord includes needless complexity, duplicated policy, misleading naming,
or leftovers that make the next correct change harder. Accord requires a
cohesive diff that a maintainer can safely understand and extend.

# Express Intent

Write code that shows WHAT it does, not HOW it does it. A reader should
understand the purpose of a construct from its name, type, and structure
without tracing through the implementation.

## Naming

- Name functions, variables, and types after the domain concept they
  represent, not the mechanism they use. `sorted_users` over
  `bubble_sort_result`; `is_valid` over `flag`.
- A name that requires a comment to explain is the wrong name. Rename
  instead of commenting.
- Boolean names state the condition they represent: `is_empty`,
  `has_permission`, `can_retry`.

## Structure

- Use the language's type system and built-in abstractions to encode
  constraints. A function that accepts only valid states is clearer
  than one that accepts anything and checks at runtime.
- Prefer declarative constructs over manual loops when the language
  provides them: `filter`, `map`, `any`, `all`, list comprehensions,
  pattern matching. The intent (select, transform, test) is
  immediately visible; the iteration mechanism is not the point.
- Extract a named function or variable when an expression's purpose is
  not obvious from the expression itself. The name documents intent;
  the body documents mechanism.
- Group related data into a named structure instead of passing loose
  positional values. A single `address` parameter expresses intent
  better than four strings whose roles depend on position.

## Contracts

- Use assertions, type annotations, and preconditions to state
  assumptions explicitly. An `assert amount > 0` tells the reader
  what the code requires; a silent wrong-result does not.
- Prefer specific error types or result types over raw booleans or
  magic return values. A `NotFound` error expresses intent; returning
  `-1` hides it behind convention.

## Signals of violation

- A comment restates what the next line does ("increment counter",
  "loop through list").
- A variable is named after its type or storage (`data`, `tmp`,
  `list2`, `ret`).
- A function's purpose is only clear after reading its body.
- A boolean parameter silently changes behavior in a way the caller
  cannot predict from the call site.

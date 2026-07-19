# SOLID principles

Five design principles for maintainable, extensible object-oriented and
modular code. Apply when structuring modules, classes, interfaces, or
any unit of encapsulation.

| Principle | Rule |
| --------- | ---- |
| SRP | A module has one reason to change |
| OCP | Extend behavior without modifying existing code |
| LSP | Subtypes must be substitutable for their base types |
| ISP | Depend only on the interface you actually use |
| DIP | Depend on abstractions, not concrete implementations |

## When to apply

Use SOLID as a design lens during:

- Module/class decomposition
- Interface and API boundary design
- Refactoring coupled or rigid code
- Code review (detecting violations)

SOLID principles reinforce each other. SRP decomposition creates the
small, focused units that OCP extends, LSP validates, ISP trims, and
DIP wires together.

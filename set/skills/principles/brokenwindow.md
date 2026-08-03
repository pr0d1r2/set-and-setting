# Broken window

Technical debt does not create value merely because paying it later creates
visible work. Account for the unseen features, reliability, and learning that
repeated repair displaces; retire known, compounding debt as soon as a safe,
complete fix costs less than carrying it.

## Applying the broken-window parable

- Count the opportunity cost, not only the repair. Include slowed delivery,
  recurring incidents, extra review, workarounds, and attention unavailable
  for useful work.
- Compare the cost of fixing now with the expected cost of carrying the debt.
  Prefer prompt repair when the debt recurs, compounds, blocks other work, or
  makes consequential failure more likely.
- Restore the lost capability before polishing it. Make the smallest complete
  repair that removes the constraint, preserves behavior, and passes the
  relevant checks.
- Remove the cause with the symptom. Add a regression test, guardrail, simpler
  design, or clearer ownership so the same window is not paid for again.
- Use nearby work as the repair window when doing so lowers total cost, but do
  not hide unrelated cleanup inside a feature change.
- Record deferred debt with evidence: carrying cost, affected work, risk,
  owner, and the condition that triggers repair. Revisit it when those facts
  change.
- Reinvest the saved maintenance effort in product value, resilience, or the
  next highest-cost debt instead of treating repair activity as progress by
  itself.

## Signals of violation

- Recurring repair work is celebrated as productivity without counting what
  the same effort could have delivered.
- A known defect repeatedly slows changes because each workaround appears
  cheaper than a complete repair in isolation.
- Cleanup is deferred by default even when its carrying cost is already higher
  than a bounded fix.
- A rushed patch restores the immediate path but leaves the cause, test gap, or
  unsafe interface intact.
- A technical-debt initiative measures files changed or tickets closed rather
  than reduced cost, risk, or lead time.
- Opportunistic cleanup expands into unrelated redesign while valuable work
  waits.

## When rapid repayment conflicts with delivery

Do not infer that every imperfection deserves immediate removal. Some debt is
cheap, isolated, reversible, or likely to disappear with its code; repairing
it now can itself displace more valuable work. Timebox the decision, compare
credible carrying and repair costs, then either fix the smallest complete
slice or defer it explicitly. Use [[consequences]] for second-order effects,
[[rootcause]] to prevent repeat payment, and [[surgical]] to contain scope.

Based on Frédéric Bastiat's [parable of the broken
window](https://en.wikipedia.org/wiki/Parable_of_the_broken_window): visible
repair activity does not recover the opportunities displaced by avoidable
destruction.

# Believability

Believability-weighted decision making. Weight input by the source's
proven track record and competence in the relevant domain -- not
everyone's view counts equally, and not equally on every topic.

## Applying believability

- Trust a proven brain's self-review but hold an unproven brain's for a
  second gate. A contributor with a track record of correct, green
  commits in a domain earns lighter review; one without that record
  gets an extra verification pass.
- Weight a review-board arbiter by demonstrated reliability. When
  resolving disagreements, the voice that has been right more often in
  the relevant area carries more weight -- not the loudest, not the
  most senior, not the most recent.
- Earn autonomy by outcome, not by assertion. Claiming expertise is
  not evidence of it. Track records are built from observable results:
  commits that pass CI, fixes that hold, reviews that catch real bugs.
- Distinguish domain-specific from general believability. A source
  highly believable in nix packaging may be unreliable on frontend
  performance. Weight per topic, not per person.
- Update believability on evidence. A previously reliable source that
  ships a string of regressions loses weight; a newcomer whose first
  contributions are solid gains it. The weighting is dynamic, not
  permanent.

## Signals of violation

- All reviewers are treated as equally authoritative regardless of
  their track record in the area under review.
- A decision is driven by seniority, volume, or confidence rather than
  by demonstrated competence in the relevant domain.
- An unproven contributor's changes are merged with the same scrutiny
  as a proven one's -- or less.
- Past failures in a domain are ignored when weighting a source's
  current input on the same domain.
- Autonomy is granted based on self-reported skill rather than
  observed outcomes.

## When believability conflicts with inclusivity

Believability weighting is about decision quality, not about silencing
newcomers. Every voice is heard; the question is how much each voice
moves the needle on a specific decision. A low-believability source may
still surface the insight that changes the outcome -- listen to the
argument, then weight it by the arguer's track record. The goal is
better decisions, not fewer participants.

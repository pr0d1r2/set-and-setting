# YAGNI

Do not build what is not needed right now. Before adding a feature,
abstraction, or dependency, research whether the current task actually
requires it. Speculative "might need later" is not a justification.

When uncertain whether something is needed, investigate: read the
requirements, check how the code is used, and ask. The cost of building
the wrong thing exceeds the cost of building it later.

Remove or decline to add: premature abstractions, unused parameters,
speculative configuration, forward-compatible shims for scenarios that
do not exist yet.

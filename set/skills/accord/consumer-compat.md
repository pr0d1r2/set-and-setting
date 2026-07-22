# Consumer compatibility

For shared code, standards, artifacts, or interfaces, review from the
consumer's side. Try to find a downstream workflow that still looks valid but
changes meaning or fails after adoption.

Check that:

- Public interfaces preserve names, types, shapes, defaults, paths, protocols,
  exit behavior, and observable semantics relied on by consumers.
- An intentional incompatibility is explicit and comes with a viable migration
  path, transition period or version boundary, and enough guidance to adopt it.
- The blast radius includes second- and third-order effects: generated output,
  wrappers, automation, cached state, integrations, and consumers of consumers.
- Old and new versions interact safely wherever rollout can be staggered. A
  fallback does not silently reinterpret data or conceal partial adoption.
- Compatibility claims use representative consumer evidence when the shared
  contract cannot be established from local tests alone.

Discord includes any silent breaking change, unexamined downstream assumption,
or migration that cannot be carried out safely. Accord only when affected
consumers continue to work or the break is explicit, bounded, and adoptable.

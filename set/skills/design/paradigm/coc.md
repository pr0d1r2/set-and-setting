# Convention over configuration as a design paradigm

Convention over configuration (CoC) is the design paradigm that
minimizes explicit decisions by providing sensible defaults derived from
widely understood conventions. A system following CoC works correctly
out of the box for the common case; configuration is reserved for the
uncommon case where the convention does not fit.

## Design lens

Use CoC during framework design, project scaffolding, API surface
review, and build-system decisions as a bias: when a reasonable default
exists, ship it as the convention and make override possible but not
required. The paradigm biases toward:

- Sensible defaults over mandatory configuration. A new project, module,
  or endpoint works immediately without a configuration file.
- Structure-as-meaning. Directory layout, file naming, and placement
  convey intent (a file in `tests/` is a test; a file named
  `*_controller` handles requests) -- the framework acts on the
  structure, not on a declaration.
- Explicit only when deviating. Configuration surfaces only when the
  user needs something the convention does not provide; the
  configuration delta is small and readable.
- Discoverability through consistency. When every project follows the
  same convention, a newcomer navigates any project without reading its
  configuration.

## Signals of violation

- A project requires a configuration file before anything runs.
- Two projects using the same framework arrange files differently and
  both require mapping declarations to explain the layout.
- Documentation spends more space on setup configuration than on domain
  concepts.
- A "getting started" guide has a configuration step before the first
  meaningful action.
- Users copy boilerplate configuration between projects with no
  project-specific changes.

## When configuration is the right choice

Convention over configuration is a bias, not an absolute. Prefer
explicit configuration when:

- The domain has no dominant convention and any default would surprise
  half the users (security policy, locale, deployment target).
- The convention would hide a decision with significant consequences
  (resource limits, authentication mode).
- Multiple equally valid layouts coexist in the ecosystem and forcing
  one would create friction rather than remove it.

When overriding a convention, co-locate the override with the code it
affects and name it so the deviation is obvious. A justified override
should be as easy to understand as the convention it replaces.

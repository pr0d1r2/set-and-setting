# Just: modules

Group related recipes into module files under a `just/` directory,
imported by the root `justfile`.

## Module structure

Every module file must:

1. Pin its working directory back to the repo root so relative
    script paths keep working:

    ```just
    set working-directory := '..'
    ```

2. Define a private `default` recipe that lists the module's own
    recipes with a `just <module>` prefix (plus a trailing space),
    for copy-paste from `just <module>`:

    ```just
    [private]
    default:
        @just --list <module> --list-prefix "    just <module> "
    ```

3. Name recipes as short sub-verbs (`run`, `upload`, `list`, `test`)
    -- the module name already supplies the noun.

## When to keep a recipe flat

Keep at the root of `justfile` any recipe that is:

- a single-command operator shortcut with no natural siblings,
- a standalone verb that doesn't cluster with others,
- or a shared healthcheck invoked against multiple targets.

Groups form from three or more cohesive siblings. Two siblings stay
flat -- promoting them to a module adds typing for no clarity gain.

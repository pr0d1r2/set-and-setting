# Narrow language

## Glob-to-dictionary map

Classify each unknown word by the language of the file it appears
in, not by what the word looks like. An English word in a shell
script goes to the shell dictionary, not the markdown one.

| File glob                                        | Dictionary                    |
| ------------------------------------------------ | ----------------------------- |
| `*.nix`, `flake.lock`                            | `.narrow-language-nix.dic`    |
| `*.sh`, `*.bats`                                 | `.narrow-language-shell.dic`  |
| `*.md`                                           | `.narrow-language-markdown.dic` |
| `*.py`                                           | `.narrow-language-python.dic` |
| `*.yml`, `*.yaml`, `*.toml`, `*.tcl`, `justfile`, `Gemfile` | `.narrow-language-other.dic`  |

Do not create or add words to dictionaries for languages not
present in this repo.

## Recovery procedure

When a `narrow-language` hook reports unknown words:

1. Identify the file each word was flagged in.
2. Look up the dictionary for that file's glob in the table above.
3. Append safely -- `printf '%s\n'` preserves trailing newlines
    (bare `echo >>` or `for w in $words; do echo "$w"; done >>` can
    silently merge the first new word onto the last existing line
    when the file lacks a final newline):

    ```sh
    printf '%s\n' word1 word2 word3 >> .narrow-language-<lang>.dic
    LC_ALL=C sort -u .narrow-language-<lang>.dic -o .narrow-language-<lang>.dic
    ```

4. Re-run the matching hook to verify:

    ```sh
    lefthook run pre-commit --command narrow-language-<lang> --all-files
    ```

Alternatively, `lefthook-narrow-language-add` auto-appends words to
the correct dictionary (sorted, deduped, `git add`ed). Review the
diff before committing.

## Gotchas

- **Compact prunes speculative words.**
  `narrow-language-<lang>-compact` removes dictionary words not
  present in any tracked file. Only add words that genuinely appear
  in the repo; speculatively added words vanish on the next compact
  run, causing confusing churn.
- **Freeze baseline.** `narrow-language-<lang>-freeze` captures the
  current dictionary state. Run it after a bulk add to lock in the
  new baseline.
- **Markdown duplicate headings (MD024).** When adding doc words to
  the markdown dictionary because of a new changelog section, do
  not create a duplicate heading (e.g. a second `### Fixed`).
  Merge entries into the existing section instead.

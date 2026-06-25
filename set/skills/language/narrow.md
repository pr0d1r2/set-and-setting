# Narrow language

Only add words to narrow-language dictionaries that exist in this repo:

- `.narrow-language-nix.dic` - for `*.nix` files
- `.narrow-language-shell.dic` - for `*.sh` and `*.bats` files
- `.narrow-language-markdown.dic` - for `*.md` files
- `.narrow-language-python.dic` - for `*.py` files
- `.narrow-language-other.dic` - for `*.yml`, `*.yaml`, `*.toml`,
  `*.tcl`, `justfile`, `Gemfile`

Do not create or add words to dictionaries for languages not
present in this repo: ruby, javascript, typescript, erb, hcl,
terraform, css, scss.

When narrow-language hook reports unknown words, run
`lefthook-narrow-language-add` to auto-append them to the correct
dictionary (sorted, deduplicated, git-staged). Review the diff
before committing. Manual alternative: add words to the correct
dictionary file (one word per line, sorted).

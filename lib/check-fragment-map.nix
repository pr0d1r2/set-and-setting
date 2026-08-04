# check-fragment-map.nix -- single source of truth for check-name-to-fragment.
# Maps every known check (pinned flake checks from checksFor + lefthook-only
# commands from integration fragments) to its owning fragment. Used by:
#   - checksFor (validates its check names match)
#   - flake.nix (serializes as CHECK_FRAGMENT_MAP env var for shell scripts)
#   - migrate.sh (replaces hardcoded case statements)
# Adding a new check here + its mk*Check helper (or lefthook fragment command)
# is the ONLY step needed; migrate.sh auto-discovers it via the env var.
let
  # GitHub composes a reusable workflow's status context from the caller job
  # and the called job: "<caller> / <called>". Keep the job identifiers as
  # structured data and derive the consumer-facing contexts below.
  requiredWorkflowJobs = {
    caller = "guardrails";
    called = [
      "check"
      "check-darwin"
    ];
  };
in
{
  validFragments = [
    "base"
    "nix"
    "shell"
    "ruby"
    "rubocop"
    "rspec"
    "reek"
    "brakeman"
    "bundle-audit"
    "ascii"
    "markdown"
    "yaml"
    "set"
  ];

  # Fragment -> list of check names. Includes BOTH pinned checks (checksFor)
  # and lefthook-only commands (fragment YAML). The migrate equivalence gate
  # and carry-through logic use this to classify any check it encounters.
  checksPerFragment = {
    base = [
      "gitleaks"
      "git-conflict-markers"
      "git-no-local-paths"
      "execute-permissions"
      "file-size-check"
      "trailing-whitespace"
      "missing-final-newline"
      "editorconfig-checker"
      "typos"
    ];
    nix = [
      "flake-manifest"
      "nixfmt"
      "statix"
      "deadnix"
      "nix-no-embedded-shell"
    ];
    shell = [
      "shellcheck"
      "shfmt"
      "no-shell-functions"
    ];
    ruby = [ ];
    rubocop = [
      "rubocop"
    ];
    rspec = [
      "rspec"
    ];
    reek = [ "reek" ];
    brakeman = [ "brakeman" ];
    bundle-audit = [ "bundle-audit" ];
    ascii = [
      "ascii-only"
    ];
    markdown = [
      "markdownlint"
      "markdownlint-agentic"
    ];
    yaml = [
      "yamllint"
    ];
    set = [
      "set-skill-extension"
      "set-skill-size"
      "set-ref-resolution"
      "set-bundle-content"
    ];
  };

  # Checks that have pinned flake check equivalents (mk*Check helpers).
  # checksFor builds derivations for exactly these; lefthook-only commands
  # (markdownlint, yamllint, set-*) are NOT here.
  pinnedChecks = {
    base = [
      "gitleaks"
      "git-conflict-markers"
      "git-no-local-paths"
      "execute-permissions"
      "file-size-check"
      "trailing-whitespace"
      "missing-final-newline"
      "editorconfig-checker"
      "typos"
    ];
    nix = [
      "flake-manifest"
      "nixfmt"
      "statix"
      "deadnix"
      "nix-no-embedded-shell"
    ];
    shell = [
      "shellcheck"
      "shfmt"
      "no-shell-functions"
    ];
    ruby = [ ];
    rubocop = [ ];
    rspec = [ ];
    reek = [ ];
    brakeman = [ ];
    bundle-audit = [ ];
    ascii = [
      "ascii-only"
    ];
    markdown = [ ];
    yaml = [ ];
    set = [ ];
  };

  # Human-readable trigger descriptions per fragment (for diagnostics).
  fragmentTriggers = {
    base = "always active";
    ascii = "always active";
    nix = "tracked *.nix files";
    shell = "tracked *.sh/*.bash files";
    ruby = "tracked Gemfile or *.gemspec files";
    rubocop = "tracked .rubocop.yml or *.gemspec files";
    rspec = "tracked spec/ files or .rspec";
    reek = "tracked .reek.yml";
    brakeman = "tracked config/brakeman.yml";
    bundle-audit = "tracked Gemfile.lock";
    markdown = "tracked *.md files";
    yaml = "tracked *.yml/*.yaml files";
    set = "tracked set/*.md files";
  };

  # Fragment -> canonical repo units. This is consumed by canonFor, beside
  # checksFor and materializationFor's fragment selection.
  canonUnitsPerFragment = {
    base = [
      "canonDocs"
      "canonGovernance"
    ];
    nix = [ "canonDevEnv" ];
    shell = [ ];
    ruby = [ ];
    rubocop = [ ];
    rspec = [ ];
    reek = [ ];
    brakeman = [ ];
    bundle-audit = [ ];
    ascii = [ ];
    markdown = [ ];
    yaml = [ ];
    set = [ ];
  };

  # Canon files that remain standard-owned after emission. Drift is an error;
  # docs and governance files are intentionally repo-owned after seeding.
  pinnedCanonPaths = [
    "flake.nix"
    ".gitignore"
    ".github/workflows/ci.yml"
  ];

  inherit requiredWorkflowJobs;

  # Standard-derived required status check contexts for branch protection.
  requiredStatusContexts = map (
    calledJob: "${requiredWorkflowJobs.caller} / ${calledJob}"
  ) requiredWorkflowJobs.called;
}

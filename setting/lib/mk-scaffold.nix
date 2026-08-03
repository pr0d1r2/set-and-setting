{ pkgs }:

let
  inherit (builtins) readFile;

  assembledLefthook =
    name: fragments:
    pkgs.runCommand name
      {
        FRAGMENTS_DIR = ../integrations/lefthook;
        FRAGMENTS = builtins.concatStringsSep " " fragments;
      }
      ''
        bash ${./assemble-lefthook.sh}
      '';

  bundleFor =
    name: flake: fragments: extraPaths:
    pkgs.symlinkJoin {
      inherit name;
      paths = [
        (assembledLefthook "${name}-lefthook" fragments)
        (pkgs.writeTextDir "flake.nix" (readFile flake))
        (pkgs.writeTextDir ".github/workflows/ci.yml" (readFile ../scaffold/ci.yml))
      ]
      ++ extraPaths;
    };
in
{
  default =
    bundleFor "scaffold-repo" ../scaffold/component-flake.txt
      [
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
      ]
      [ ];
  ruby =
    bundleFor "scaffold-ruby-repo" ../scaffold/ruby-flake.txt
      [
        "base"
        "ruby"
        "rubocop"
        "rspec"
      ]
      [
        (pkgs.writeTextDir "Gemfile" (readFile ../scaffold/ruby/Gemfile))
        (pkgs.writeTextDir "project.gemspec" (readFile ../scaffold/ruby/project.gemspec))
        (pkgs.writeTextDir ".rubocop.yml" (readFile ../scaffold/ruby/rubocop.yml))
        (pkgs.writeTextDir "spec/spec_helper.rb" (readFile ../scaffold/ruby/spec-helper.txt))
        (pkgs.writeTextDir "lib/project.rb" (readFile ../scaffold/ruby/project.txt))
      ];
}

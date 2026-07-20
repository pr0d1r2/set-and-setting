# meta.nix -- sidecar channel map (V30/I.meta). Single source for channel
# assignment, keyed by source path/subtree. Keeps set/ markdown agnostic
# (C2/V17): channel metadata lives here as data, never as in-source
# frontmatter.
#
# `resolve <path>` returns { channel, paths, keywords, always } for a
# source file path relative to set/skills/ (e.g. "nix/flake.md",
# "generic/skill/interchange.md"). Three levels merge, most specific
# wins:
#   category fallback  <-  subtree entry  <-  exact-file override
#
# Fields:
#   channel  -- "core" (always-on, V18) | "domain" (conditional, V19)
#   paths    -- conditional-load globs (-> rule globs + SKILL.md paths)
#   keywords -- terms for SKILL.md description / when_to_use
#   always   -- bool; force always-on regardless of channel
#
# This map feeds every channel: paths drive both the Claude rule globs
# and the portable SKILL.md `paths`; keywords drive the SKILL.md
# description / when_to_use (V30).
{ lib }:

let
  cats = import ./lib/categories.nix;

  # Per-path / per-subtree overrides. Keys are paths relative to
  # set/skills/: a category ("language"), a topic ("language/narrow.md"),
  # or any prefix. A more specific key overrides a less specific one, and
  # both override the category fallback. Each value is a partial set;
  # unspecified fields fall back.
  overrides = {
    # subtree: every language/* file inherits these keywords unless it
    # overrides them per-file.
    "language" = {
      keywords = [
        "prose"
        "writing"
        "documentation"
        "style"
      ];
    };

    # per-file override: narrow.md is specifically about dictionaries, so
    # it replaces the inherited subtree keywords.
    "language/narrow.md" = {
      keywords = [
        "narrow-language"
        "dictionary"
        "spelling"
        "vocabulary"
      ];
    };

    # rtk is a host-specific proxy, not a universal rule -- keep it a
    # narrow domain even though it sits under the always-on generic core.
    "generic/rtk.md" = {
      channel = "domain";
      always = false;
      keywords = [
        "rtk"
        "token"
        "proxy"
      ];
    };

    # High-value facets (V34/V35): narrow paths (also tighten the rule
    # globs) + content signals so smart materialization (T53) installs
    # them only when the feature is actually used. The qemu subtree shares
    # one signal; mdns refines it.
    "test/qemu.md" = {
      paths = [
        "tests/integration/**"
        "**/*.exp"
      ];
      content = [
        "qemu"
        "enable-kvm"
      ];
    };
    "test/qemu" = {
      paths = [
        "tests/integration/**"
        "**/*.exp"
      ];
      content = [
        "qemu"
        "enable-kvm"
      ];
    };
    "test/qemu/mdns.md" = {
      paths = [ "**/*.nix" ];
      content = [
        "avahi"
        "mDNS"
      ];
    };
    "test/iso.md" = {
      paths = [ "**/*.nix" ];
      content = [
        "ISO9660"
        "El Torito"
        "isoImage"
      ];
    };
    "design/paradigm" = {
      keywords = [
        "design"
        "paradigm"
        "interface"
        "api"
      ];
    };
    "design/paradigm/pola.md" = {
      keywords = [
        "pola"
        "pols"
        "least-astonishment"
        "least-surprise"
        "interface"
        "api"
        "naming"
        "defaults"
      ];
    };
    "design/paradigm/coc.md" = {
      keywords = [
        "convention-over-configuration"
        "coc"
        "sensible-defaults"
        "defaults"
        "scaffolding"
        "framework"
        "boilerplate"
      ];
    };
    "principles/openness.md" = {
      keywords = [
        "openness"
        "open-mindedness"
        "radical-open-mindedness"
        "disconfirming"
        "adversarial-review"
        "blind-spot"
        "ego-barrier"
        "cross-brain"
      ];
    };
    "principles/pola.md" = {
      keywords = [
        "pola"
        "pols"
        "least-astonishment"
        "least-surprise"
        "interface"
        "api"
        "naming"
      ];
    };
    "principles/reality.md" = {
      keywords = [
        "reality"
        "hyperrealism"
        "observed-state"
        "evidence"
        "verification"
        "ci-status"
        "debugging"
      ];
    };
    "principles/truth.md" = {
      keywords = [
        "truth"
        "radical-truth"
        "honesty"
        "faithful-reporting"
        "mistakes"
        "failure"
      ];
    };
    "principles/believability.md" = {
      keywords = [
        "believability"
        "believability-weighted"
        "track-record"
        "competence"
        "credibility"
        "meritocracy"
        "autonomy"
        "trust"
      ];
    };
    "principles/progress.md" = {
      keywords = [
        "progress"
        "pain-reflection"
        "failure-as-fuel"
        "backprop"
        "encode-lesson"
        "compound-improvement"
        "introspect"
      ];
    };
    "principles/rootcause.md" = {
      keywords = [
        "root-cause"
        "rootcause"
        "diagnosis"
        "five-whys"
        "symptom"
        "underlying-defect"
        "trace"
        "debugging"
      ];
    };
    "principles/transparency.md" = {
      keywords = [
        "transparency"
        "radical-transparency"
        "auditable"
        "visible"
        "reasoning"
        "decisions"
        "audit-trail"
        "inspection"
      ];
    };
    "security/hardening.md" = {
      paths = [ "**/*.nix" ];
      content = [
        "ProtectSystem"
        "CapabilityBoundingSet"
      ];
    };
    "opensource/cachix.md" = {
      paths = [
        "flake.nix"
        "**/*.nix"
      ];
      content = [
        "cachix"
        "extra-substituters"
      ];
    };
    "nix/python-package.md" = {
      paths = [ "**/*.nix" ];
      content = [ "buildPythonPackage" ];
    };
  };

  resolve =
    path:
    let
      parts = lib.splitString "/" path;
      category = lib.head parts;
      isCore = lib.elem category cats.core;

      fallback = {
        channel = if isCore then "core" else "domain";
        paths = cats.globs.${category} or [ "**/*" ];
        keywords = [ category ];
        always = isCore;
        # content = materialize-time grep relevance signal (V35); empty =
        # rely on paths/category evidence only.
        content = [ ];
      };

      # Cumulative path prefixes, least specific first:
      #   "nix/infinity/gap.md" -> [ "nix" "nix/infinity" "nix/infinity/gap.md" ]
      prefixes = lib.genList (i: lib.concatStringsSep "/" (lib.sublist 0 (i + 1) parts)) (
        lib.length parts
      );

      matched = lib.filter (p: overrides ? ${p}) prefixes;
    in
    lib.foldl' (acc: p: acc // overrides.${p}) fallback matched;

  # Serialized channel-affecting overrides for the bash emitter, one per
  # line: "path|channel|g1,g2". The delimiter is "|" (NOT a tab): tab is an
  # IFS-whitespace char, so `IFS=$'\t' read` collapses an empty channel
  # field and misassigns the globs. "|" never appears in paths/globs. Only
  # entries that set `channel` or `paths` (keyword-only overrides do not
  # affect the rule channel). Keeps meta.nix the single source of channel
  # data (V30) while the emitter stays plain bash for both the nix and
  # run-time app paths (C9/V28). Empty fields fall back to the category.
  channelOverrides = lib.concatStringsSep "\n" (
    lib.filter (s: s != "") (
      lib.mapAttrsToList (
        p: o:
        lib.optionalString (o ? channel || o ? paths)
          "${p}|${o.channel or ""}|${lib.concatStringsSep "," (o.paths or [ ])}"
      ) overrides
    )
  );
  # Per-source-file applicability signals for smart materialization
  # (V34/V35, I.applicability), one line per skill file:
  #   "relpath|p1,p2|c1,c2"  (paths | content, both resolved via meta)
  # `paths` answer "is a file of this shape present", `content` "is the
  # feature actually used". Enumerated here (single source) so the bash
  # filter only greps. Loose top-level "<cat>.md" resolves via its
  # category. Delimiter "|" (see channelOverrides).
  skillFiles = map (p: lib.removePrefix (toString ./skills + "/") (toString p)) (
    lib.filter (p: lib.hasSuffix ".md" (toString p)) (lib.filesystem.listFilesRecursive ./skills)
  );
  signalKey =
    rel:
    let
      parts = lib.splitString "/" rel;
    in
    if lib.length parts == 1 then lib.removeSuffix ".md" rel else rel;
  signals = lib.concatStringsSep "\n" (
    map (
      rel:
      let
        r = resolve (signalKey rel);
      in
      "${rel}|${lib.concatStringsSep "," r.paths}|${lib.concatStringsSep "," r.content}"
    ) (lib.sort (a: b: a < b) skillFiles)
  );
in
{
  inherit
    overrides
    resolve
    channelOverrides
    signals
    ;
}

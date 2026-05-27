# Nix: Python package

Pattern for packaging Python libraries with `buildPythonPackage`.

## Pure Python (setuptools)

```nix
{ pkgs, src }:
pkgs.python313Packages.buildPythonPackage {
  pname = "mypackage";
  version = "1.2.3";
  pyproject = true;

  inherit src;

  build-system = with pkgs.python313Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies = with pkgs.python313Packages; [
    numpy
  ];

  pythonImportsCheck = [ "mypackage" ];

  meta = with pkgs.lib; {
    description = "What it does";
    homepage = "https://github.com/org/mypackage";
    license = licenses.mit;
  };
}
```

## Key attributes

- `pyproject = true` — required on nixos-25.11 for setuptools builds
- `pythonImportsCheck` — lightweight smoke test, always include
- `doCheck = false` — when tests need network (model downloads, APIs)
- `build-system` — replaces old `nativeBuildInputs` for PEP 517

## Maturin/Rust packages (pre-built wheels)

When source build requires Rust + maturin + heavy native compilation
(e.g. tree-sitter-language-pack compiles 305 grammars), fetch
pre-built wheels from PyPI instead:

```nix
{ pkgs, version ? "1.8.1" }:
let
  wheelInfo = {
    "x86_64-linux" = {
      url = "https://files.pythonhosted.org/packages/.../pkg-${version}-cp310-abi3-manylinux_2_34_x86_64.whl";
      hash = "sha256:...";
    };
    "aarch64-darwin" = {
      url = "https://files.pythonhosted.org/packages/.../pkg-${version}-cp310-abi3-macosx_11_0_arm64.whl";
      hash = "sha256:...";
    };
  }.${pkgs.stdenv.hostPlatform.system};
in
pkgs.python313Packages.buildPythonPackage {
  pname = "pkg";
  inherit version;
  format = "wheel";

  src = pkgs.fetchurl { inherit (wheelInfo) url hash; };
  dependencies = [ ... ];
  pythonImportsCheck = [ "pkg" ];
}
```

Get wheel URLs + hashes from `https://pypi.org/pypi/PACKAGE/json`.

## Flake input pattern

Pin source as non-flake input:

```nix
inputs.mypackage-src = {
  url = "github:org/mypackage/v1.2.3";
  flake = false;
};
```

Pass to build: `import ./mypackage.nix { inherit pkgs; src = mypackage-src; }`

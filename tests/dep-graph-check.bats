#!/usr/bin/env bats

# Unit tests for lib/dep-graph-check.sh -- validates that every flake
# input uses github: URLs (T9/C6).

setup() {
    TARGET="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../lib/dep-graph-check.sh"
}

teardown() {
    rm -rf "$TARGET"
}

@test "exit 0 when all inputs use github: type" {
    cat >"$TARGET/flake.lock" <<'EOF'
{
    "nodes": {
        "nixpkgs": {
            "locked": {
                "type": "github",
                "owner": "NixOS",
                "repo": "nixpkgs"
            },
            "original": {
                "type": "github",
                "owner": "NixOS",
                "repo": "nixpkgs"
            }
        },
        "root": {
            "inputs": {
                "nixpkgs": "nixpkgs"
            }
        }
    },
    "root": "root",
    "version": 7
}
EOF
    FLAKE_LOCK="$TARGET/flake.lock" run bash "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"all inputs use github: URLs"* ]]
}

@test "exit 1 when an input uses git+file: type" {
    cat >"$TARGET/flake.lock" <<'EOF'
{
    "nodes": {
        "local-dep": {
            "locked": {
                "type": "git",
                "url": "file:///opt/local-repo"
            },
            "original": {
                "type": "git",
                "url": "file:///opt/local-repo"
            }
        },
        "root": {
            "inputs": {
                "local-dep": "local-dep"
            }
        }
    },
    "root": "root",
    "version": 7
}
EOF
    FLAKE_LOCK="$TARGET/flake.lock" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
    [[ "$output" == *"non-github"* ]]
}

@test "exit 1 when an input uses path: type" {
    cat >"$TARGET/flake.lock" <<'EOF'
{
    "nodes": {
        "local": {
            "locked": {
                "type": "path",
                "path": "/opt/local"
            },
            "original": {
                "type": "path",
                "path": "/opt/local"
            }
        },
        "root": {
            "inputs": {
                "local": "local"
            }
        }
    },
    "root": "root",
    "version": 7
}
EOF
    FLAKE_LOCK="$TARGET/flake.lock" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
    [[ "$output" == *"path:"* ]]
}

@test "exit 1 when mixed github: and non-github: inputs" {
    cat >"$TARGET/flake.lock" <<'EOF'
{
    "nodes": {
        "nixpkgs": {
            "locked": {
                "type": "github",
                "owner": "NixOS",
                "repo": "nixpkgs"
            },
            "original": {
                "type": "github",
                "owner": "NixOS",
                "repo": "nixpkgs"
            }
        },
        "local-dep": {
            "locked": {
                "type": "git",
                "url": "file:///tmp/local"
            },
            "original": {
                "type": "git",
                "url": "file:///tmp/local"
            }
        },
        "root": {
            "inputs": {
                "nixpkgs": "nixpkgs",
                "local-dep": "local-dep"
            }
        }
    },
    "root": "root",
    "version": 7
}
EOF
    FLAKE_LOCK="$TARGET/flake.lock" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"FAIL"* ]]
}

@test "fails when flake.lock does not exist" {
    FLAKE_LOCK="$TARGET/nonexistent" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"not found"* ]]
}

@test "defaults to flake.lock in current directory" {
    cat >"$TARGET/flake.lock" <<'EOF'
{
    "nodes": {
        "nixpkgs": {
            "locked": { "type": "github" },
            "original": { "type": "github" }
        },
        "root": { "inputs": { "nixpkgs": "nixpkgs" } }
    },
    "root": "root",
    "version": 7
}
EOF
    run bash -c "cd '$TARGET' && bash '$SCRIPT'"
    [ "$status" -eq 0 ]
}

@test "output includes guidance to switch URLs" {
    cat >"$TARGET/flake.lock" <<'EOF'
{
    "nodes": {
        "dep": {
            "locked": { "type": "path", "path": "/tmp" },
            "original": { "type": "path", "path": "/tmp" }
        },
        "root": { "inputs": {} }
    },
    "root": "root",
    "version": 7
}
EOF
    FLAKE_LOCK="$TARGET/flake.lock" run bash "$SCRIPT"
    [ "$status" -eq 1 ]
    [[ "$output" == *"github: URLs"* ]]
    [[ "$output" == *"git+file:"* ]]
}

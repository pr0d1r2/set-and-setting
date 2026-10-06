#!/usr/bin/env bats

setup() {
    TMP="$(mktemp -d)"
    SCRIPT="$BATS_TEST_DIRNAME/../../lib/lint-arch-diagram.sh"
}

teardown() {
    rm -rf "$TMP"
}

@test "README with Mermaid architecture and image development diagrams passes" {
    cat >"$TMP/README.md" <<'EOF'
# Project

## Architecture

```mermaid
graph TD
    A --> B
```

## Development architecture

```diagram
flowchart: development
```
EOF
    run bash "$SCRIPT" "$TMP/README.md"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "README with neither diagram names both findings" {
    printf '%s\n' '# Project' >"$TMP/README.md"
    run bash "$SCRIPT" "$TMP/README.md"
    [ "$status" -eq 1 ]
    [[ "$output" == *"missing architecture diagram"* ]]
    [[ "$output" == *"missing development architecture diagram"* ]]
}

@test "heading and prose near-miss does not pass" {
    cat >"$TMP/README.md" <<'EOF'
# Project

## Architecture

The architecture diagram will be added later.

## Development architecture

The development architecture is documented elsewhere.
EOF
    run bash "$SCRIPT" "$TMP/README.md"
    [ "$status" -eq 1 ]
    [[ "$output" == *"missing architecture diagram"* ]]
    [[ "$output" == *"missing development architecture diagram"* ]]
}

@test "explicit no-shape markers pass" {
    cat >"$TMP/README.md" <<'EOF'
# Project

<!-- no architecture diagram: this repository has no architecture shape to draw -->
<!-- no development architecture diagram: this repository has no development shape to draw -->
EOF
    run bash "$SCRIPT" "$TMP/README.md"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

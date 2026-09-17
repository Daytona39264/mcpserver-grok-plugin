#!/usr/bin/env bats

setup() {
    REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
}

@test ".codex-plugin/plugin.json includes required directory metadata" {
    run node -e '
const fs = require("fs");
const path = require("path");
const manifestPath = path.join(process.argv[1], ".codex-plugin", "plugin.json");
const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
if (manifest.repository !== "https://github.com/Daytona39264/mcpserver-grok-plugin") process.exit(1);
if (!manifest.interface) process.exit(1);
if (manifest.interface.displayName !== "McpServer Grok Plugin") process.exit(1);
if (!manifest.interface.shortDescription) process.exit(1);
if (manifest.interface.composerIcon !== "./assets/icon.svg") process.exit(1);
' "$REPO_ROOT"
    [ "$status" -eq 0 ]
}

@test "declared Codex icon exists" {
    [ -f "$REPO_ROOT/assets/icon.svg" ]
    [ -s "$REPO_ROOT/assets/icon.svg" ]
}

@test "security policy exists for the fork" {
    [ -f "$REPO_ROOT/SECURITY.md" ]
    grep -q 'https://github.com/Daytona39264/mcpserver-grok-plugin/issues' "$REPO_ROOT/SECURITY.md"
}

@test "HOL scanner workflow is pinned and targets main" {
    local workflow="$REPO_ROOT/.github/workflows/hol-plugin-scanner.yml"
    [ -f "$workflow" ]
    grep -q 'branches: \[main\]' "$workflow"
    grep -q 'actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683' "$workflow"
    grep -q 'hashgraph-online/ai-plugin-scanner-action@9bb93a9b22646292a9d737e5169617f688bc195a' "$workflow"
}

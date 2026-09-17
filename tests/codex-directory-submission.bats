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
if (manifest.homepage !== "https://github.com/Daytona39264/mcpserver-grok-plugin") process.exit(1);
if (!manifest.interface) process.exit(1);
if (manifest.interface.displayName !== "MCPServer Grok Plugin") process.exit(1);
if (!manifest.interface.shortDescription) process.exit(1);
if (!manifest.interface.longDescription) process.exit(1);
if (manifest.interface.developerName !== "Payton Byrd (The Sharp Ninja)") process.exit(1);
if (manifest.interface.category !== "Development & Workflow") process.exit(1);
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
    run ruby -ryaml -e '
workflow = YAML.load_file(ARGV[0], permitted_classes: [], aliases: false)
events = workflow.fetch("on")
raise unless events.dig("push", "branches") == ["main"]
raise unless events.dig("pull_request", "branches") == ["main"]
jobs = workflow.fetch("jobs")
raise unless jobs.dig("scan-pull-request", "if") == "github.event_name == '\''pull_request'\''"
raise unless jobs.dig("scan-push", "if") == "github.event_name == '\''push'\''"
raise unless jobs.dig("scan-push", "permissions", "security-events") == "write"
raise unless jobs.dig("scan-pull-request", "steps", 1, "with", "upload_sarif") == false
raise unless jobs.dig("scan-push", "steps", 1, "with", "upload_sarif") == true
raise unless jobs.dig("scan-pull-request", "steps", 0, "uses") == "actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683"
raise unless jobs.dig("scan-push", "steps", 0, "uses") == "actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683"
raise unless jobs.dig("scan-pull-request", "steps", 1, "uses") == "hashgraph-online/ai-plugin-scanner-action@9bb93a9b22646292a9d737e5169617f688bc195a"
raise unless jobs.dig("scan-push", "steps", 1, "uses") == "hashgraph-online/ai-plugin-scanner-action@9bb93a9b22646292a9d737e5169617f688bc195a"
' "$workflow"
    [ "$status" -eq 0 ]
}

@test "scanner support files exist" {
    [ -f "$REPO_ROOT/.codexignore" ]
    [ -f "$REPO_ROOT/.github/dependabot.yml" ]
    grep -q 'package-ecosystem: "github-actions"' "$REPO_ROOT/.github/dependabot.yml"
}

@test "submission handoff document exists" {
    [ -f "$REPO_ROOT/docs/codex-directory-submission.md" ]
    grep -q '^## Scanner Run Record$' "$REPO_ROOT/docs/codex-directory-submission.md"
    grep -q '^## Existing Validation Run Record$' "$REPO_ROOT/docs/codex-directory-submission.md"
    grep -q 'Version: `plugin-scanner==' "$REPO_ROOT/docs/codex-directory-submission.md"
    grep -q 'Expected wheel SHA256:' "$REPO_ROOT/docs/codex-directory-submission.md"
    grep -q '^-\s*Score:' "$REPO_ROOT/docs/codex-directory-submission.md"
    grep -q '^-\s*Grade:' "$REPO_ROOT/docs/codex-directory-submission.md"
    grep -q 'HARDCODED_SECRET' "$REPO_ROOT/docs/codex-directory-submission.md"
    grep -q 'bats tests/' "$REPO_ROOT/docs/codex-directory-submission.md"
    grep -q 'tests passed' "$REPO_ROOT/docs/codex-directory-submission.md"
    grep -q 'tests failed' "$REPO_ROOT/docs/codex-directory-submission.md"
    grep -Fx 'Passing source-branch scanner run URL: **Pending — this workflow must pass on `Daytona39264/mcpserver-grok-plugin` `main` after maintainer review/merge before submitting the external listing.**' "$REPO_ROOT/docs/codex-directory-submission.md" || \
        grep -Eq '^Passing source-branch scanner run URL: (\*\*https://github\.com/Daytona39264/mcpserver-grok-plugin/actions/runs/[0-9]+\*\*|\*\*\[[^]]+\]\(https://github\.com/Daytona39264/mcpserver-grok-plugin/actions/runs/[0-9]+\)\*\*|\[[^]]+\]\(https://github\.com/Daytona39264/mcpserver-grok-plugin/actions/runs/[0-9]+\)|https://github\.com/Daytona39264/mcpserver-grok-plugin/actions/runs/[0-9]+)$' "$REPO_ROOT/docs/codex-directory-submission.md"
}

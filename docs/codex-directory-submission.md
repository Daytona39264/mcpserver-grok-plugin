# Codex Directory Submission Handoff

This repository is the `Daytona39264/mcpserver-grok-plugin` fork prepared for a future `hashgraph-online/awesome-codex-plugins` listing. It preserves upstream attribution to `sharpninja/mcpserver-grok-plugin`, but the public source repository for any directory submission from this fork is:

- https://github.com/Daytona39264/mcpserver-grok-plugin

## Readiness Checklist

- [x] `.codex-plugin/plugin.json` exists and now includes the required Codex directory metadata plus a local icon reference
- [x] `assets/icon.svg` exists and is referenced from `.codex-plugin/plugin.json`
- [x] `SECURITY.md` exists with only GitHub-supported reporting guidance that this fork can truthfully advertise today
- [x] HOL scanner workflow exists at `.github/workflows/hol-plugin-scanner.yml` for `push` and `pull_request` on `main`
- [x] Third-party GitHub Actions in repository workflows are pinned to full commit SHAs and use least-privilege permissions
- [x] Local HOL scanner artifact hash was verified against the current `awesome-codex-plugins` contribution guide
- [x] Existing documented repository validation passed locally with `bats tests/`
- [ ] HOL scanner passes with no high or critical findings on the source repository default branch
- [ ] A real passing GitHub Actions run URL from this fork's `main` branch is available for the external listing PR
- [ ] External README entry PR has been opened in `hashgraph-online/awesome-codex-plugins`

## Scanner Run Record

Reviewed scanner release from the current contribution guide:

- Guide reviewed: `2026-09-17` from `hashgraph-online/awesome-codex-plugins` `CONTRIBUTING.md`
- Version: `plugin-scanner==3.0.184`
- Expected wheel SHA256: `280c7d30c0490db2283878ca58271769cd1f50d550608bac95fde9110fe0cd05`

Commands run in this fork:

```bash
python3 -m pip download --only-binary=:all: --no-deps --dest /tmp/hol-plugin-scanner-dist "plugin-scanner==3.0.184"
python3 -m pip hash /tmp/hol-plugin-scanner-dist/*.whl
python3 -m pipx install --force "plugin-scanner==3.0.184"
/opt/pipx_bin/plugin-scanner scan . --format text
```

Actual local result after the submission-prerequisite changes in this PR:

- Score: `89/100`
- Grade: `B`
- Findings: `critical:0, high:4, medium:0, low:0, info:5`

Current blocker details from the scanner output:

- `lib/marker-resolver.sh:212` — `HARDCODED_SECRET` (high)
- `lib/repl-invoke.sh:1073` — `HARDCODED_SECRET` (high)

Those findings are duplicated across the repo's Claude and Codex package scans, which is why the total shows four high findings. These files are part of the synced core shell implementation guarded by `CORE-MANIFEST.yaml` and `.github/workflows/core-guard.yml`, so they should be reviewed and remediated in the shared upstream/core flow rather than patched ad hoc in this fork.

## Existing Validation Run Record

The currently documented repository validation command completed successfully:

```bash
bats tests/
```

Result:

- `103` tests passed
- `0` tests failed

## Proposed Awesome Codex Plugins README Entry

Category: **Development & Workflow**

Alphabetical placement: under **M**

Suggested single-line entry:

- [MCPServer Grok Plugin](https://github.com/Daytona39264/mcpserver-grok-plugin) - Connects Grok CLI/TUI sessions to MCPServer for workspace-scoped TODOs, session logging, requirements tracking, and continuity hooks.

## Submission Instructions

1. Resolve the remaining high-severity scanner findings in the shared core/upstream flow and sync the fix back into this fork if needed.
2. Merge this repository's prerequisite changes to the source default branch: `main`.
3. Wait for `.github/workflows/hol-plugin-scanner.yml` to run on `main` and pass with score `>=80` and no high/critical findings.
4. Copy the passing workflow run URL from this fork and replace the pending note below.
5. Open a separate PR against `hashgraph-online/awesome-codex-plugins` that adds only the README line above in alphabetical order under **Development & Workflow**.
6. In that external PR description, include the public source URL for this fork and the passing scanner run URL from this fork's `main` branch.
7. Do **not** commit copied plugin bundles, generated catalogs, `plugins.json`, or `marketplace.json` to the directory PR.

Passing source-branch scanner run URL: **Pending — this workflow must pass on `Daytona39264/mcpserver-grok-plugin` `main` after maintainer review/merge before submitting the external listing.**

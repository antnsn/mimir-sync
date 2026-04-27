# CLAUDE.md

Project-specific instructions for Claude (Claude Code, claude.ai, and any
Anthropic-powered agent) working on **mimir-sync**. Read this file in full
before making changes. The companion file
[`.github/copilot-instructions.md`](.github/copilot-instructions.md) is the
canonical source — this document mirrors it for Claude tooling and adds a few
Claude-specific notes.

## What this repo is

A Helm chart that deploys Kubernetes Jobs running `ghcr.io/antnsn/mal-sync`
to push:

- Alertmanager config into Mimir
- Prometheus rule groups into Mimir's ruler
- Loki rule groups into Loki's ruler

Config sources are pluggable: ConfigMap, Secret, or `existingName` for BYO.
Reloader annotations on the Jobs trigger re-syncs when the source changes.

## Files you will touch most

- `chart/values.yaml` — user-facing knobs. Three parallel sections:
  `alertmanager`, `rules`, `lokiRules`. Keep them symmetric.
- `chart/templates/` — `_helpers.tpl` plus three parallel triplets
  (`<feature>-configmap.yaml`, `<feature>-secret.yaml`,
  `<feature>-sync-job.yaml`) plus RBAC.
- `chart/Chart.yaml` — `version` (chart semver) and `appVersion` (image).
- `chart/README.md.tpl` — helm-docs source template.
- `chart/README.md` — **generated**; never hand-edit.
- `.github/workflows/` — CI; see Releasing below.
- `scripts/release.sh` — interactive release helper.

## Sibling repo: `mal-sync` (we own it, you can fix it)

The image this chart runs (`ghcr.io/antnsn/mal-sync`) is built from
`antnsn/mal-sync`, checked out locally at `/Users/marius/repo/antnsn/mal-sync`.
It is **our** code — feel free to fix bugs there directly when the root cause
is in the binary (e.g. wrong CLI flag name, missing flag, incorrect
`mimirtool`/`lokitool` invocation) rather than monkey-patching the chart.

Workflow when the fix lives in `mal-sync`:

1. Edit, build/test (`go build ./...`, `go test ./...`), commit.
2. `codex review --commit <SHA>` (same `/codex:review` mandate as this repo).
3. Tag `vX.Y.Z` and push — `.github/workflows/docker-publish.yml` builds and
   publishes `ghcr.io/antnsn/mal-sync:vX.Y.Z`.
4. Back in this repo, bump `appVersion` in `chart/Chart.yaml` to the new tag
   and cut a chart release through the normal flow.
5. Reference both commits/tags from any related issue or PR body.

Choose the chart-side fix only when the binary's behaviour is actually
correct. When in doubt, prefer fixing `mal-sync` — paving over a binary bug
in templates leaves the next user with the same problem.

## Non-negotiable rules

1. **`/codex:review` before every push.** Every commit you create — feature,
   fix, docs, release commit, anything — must be reviewed via the
   `/codex:review` slash command before `git push`. No exceptions. If review
   surfaces real issues, fix them in follow-up commits and re-run
   `/codex:review` until clean. This applies equally when you're driving
   `scripts/release.sh`: review the staged release commit before answering
   "y" to the script's "Proceed with release?" prompt.
2. **Never edit `chart/README.md` directly.** Edit `values.yaml` or
   `chart/README.md.tpl`, then run `helm-docs`. Both `lint-test.yaml` and
   `superlinter.yml` enforce `helm-docs && git diff --exit-code`.
3. **Keep the three feature sets in sync.** Any change to alertmanager
   templates/values is also expected for `rules` and `lokiRules` unless the
   user explicitly scopes otherwise.
4. **No silent breaking changes.** Removing or renaming a `values.yaml` key
   requires an explicit user request and a major version bump.
5. **Tag discipline.** Tags must match `^v\d+\.\d+\.\d+$`. Never re-tag,
   never force-push tags.
6. **Commit trailer.** End every commit message with:
   ```
   Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
   ```
7. **No secrets** committed; Gitleaks runs in CI.

## Default workflow

1. Plan the change. For anything non-trivial, request a critique from a
   rubber-duck / second-opinion pass before implementing.
2. Make surgical edits. Batch independent edits to the same file in one
   tool call.
3. Run `helm-docs` if you touched `values.yaml` or `chart/README.md.tpl`.
4. Validate:
   ```bash
   helm lint chart/
   helm template test chart/ --debug >/dev/null
   helm template test chart/ \
     --set alertmanager.enabled=true \
     --set rules.enabled=true \
     --set lokiRules.enabled=true \
     --set alertmanager.config.type=configmap \
     --set rules.config.type=configmap \
     --set lokiRules.config.type=configmap \
     --debug >/dev/null
   ct lint --config chart/ct.yaml --charts chart/   # if ct is installed
   ```
5. Stage exactly the files you intended; commit with Conventional Commits
   (`feat:`, `fix:`, `chore:`, `docs:`, `ci:`, `refactor:`).
6. **Run `/codex:review`.** Address findings, commit fixes, re-review.
7. Push. Open a PR for non-trivial changes so CI gates apply.

## Releasing

There is **one release path**. `chart-releaser-action`
(`.github/workflows/release.yaml`) is the sole publisher: when a commit on
`main` bumps `chart/Chart.yaml`'s `version:`, the workflow tags `vX.Y.Z`,
packages the chart, pushes it to `gh-pages` (served at
`https://antnsn.github.io/mimir-sync`), creates the GitHub Release, and
opens a follow-up PR if `helm-docs` would change anything.

### Cutting a release

Use `scripts/release.sh` (preferred) or the manual equivalent:

```bash
./scripts/release.sh --dry-run   # validates in an isolated git worktree
./scripts/release.sh             # bumps, validates, regenerates docs, commits, pushes main
```

The script:

1. Verifies you're on `main`, clean, and in sync with `origin/main`.
2. Prompts for the new version. Validates `^[0-9]+\.[0-9]+\.[0-9]+$`.
3. Confirms tag `vX.Y.Z` does not yet exist locally or on `origin`.
4. Bumps `chart/Chart.yaml` `version:` (and optionally `appVersion:`).
5. Runs `helm lint`, two `helm template` passes, and `ct lint` if available.
6. Runs `helm-docs` pinned to `v1.14.2` (matching CI).
7. Shows the diff, prints the `/codex:review` reminder, and requires you to
   type `proceed` to continue.
8. Commits `chart/Chart.yaml` + `chart/README.md` with the
   `Co-authored-by: Copilot` trailer and pushes `main`.
9. Does **not** create or push tags. Does **not** touch `gh-pages`. Does
   **not** call `gh release create`. The workflow does all of that.

Manual equivalent (for environments without the script): edit
`chart/Chart.yaml`, run `helm lint chart/` and `helm-docs`, run
`/codex:review`, commit with the mandatory trailer, `git push origin main`.

### `/codex:review` is mandatory

Before answering `proceed` (or before `git push` in the manual flow), run
`/codex:review` on the staged release commit. The script's confirmation is
not a substitute. This rule applies to every commit that lands on `main`.

### Pre-release checklist

- [ ] Clean working tree on `main`, synced with `origin/main`.
- [ ] `chart/Chart.yaml` `version:` bumped (semver: breaking → major,
      additive → minor, fix → patch).
- [ ] `appVersion` only changed if the `mal-sync` image contract changed.
- [ ] `helm-docs` produced no remaining diff.
- [ ] `helm lint chart/` passes; `ct lint` passes if installed.
- [ ] `/codex:review` clean on every commit being pushed.

## CI to keep green

- `lint-test.yaml` — PRs touching `chart/**` or any workflow YAML. Runs
  `helm-docs` (must be clean), `ct lint`, and `ct install` on a `kind`
  cluster (after installing `prometheus-operator-crds`) when changed charts
  are detected.
- `superlinter.yml` — PRs. Super-Linter (`slim`) over Bash, EditorConfig,
  GitHub Actions, Gitleaks, JSON, Python, Renovate, shfmt, XML, plus a
  separate `helm-docs` drift check.
- `release.yaml` — covered above.

## Subagents available in this repo

`.github/agents/` holds custom Copilot CLI subagents. They are also useful
context if you're operating from Claude Code:

- `helm-chart-engineer`
- `helm-tester`
- `release-manager`
- `ci-workflow-engineer`

Delegate to them where it speeds up the work; otherwise treat their
descriptions as a checklist of repo conventions.

## Quick command reference

```bash
# Local validation
helm lint chart/
helm template test chart/ --debug
ct lint --config chart/ct.yaml --charts chart/

# Docs
helm-docs                           # regenerate chart/README.md
git diff --exit-code chart/README.md  # what CI checks

# Release helper
./scripts/release.sh --dry-run
./scripts/release.sh

# Release inspection
gh run list --workflow=release.yaml -L 5
gh run watch
```

# Copilot Instructions — mimir-sync

These instructions apply to **GitHub Copilot** (chat, CLI, coding agent) and any
other AI assistant working in this repository. Read them in full before making
changes.

## Repository overview

`mimir-sync` is a **Helm chart** that deploys Kubernetes Jobs which sync:

- **Alertmanager** configuration into Mimir
- **Prometheus rules** into Mimir's ruler
- **Loki rules** into Loki's ruler

The Jobs run the `ghcr.io/antnsn/mal-sync` image (a wrapper around
`mimirtool` / `lokitool`). Jobs are reconciled on ConfigMap/Secret changes via
[Reloader](https://github.com/stakater/Reloader) and self-clean via
`ttlSecondsAfterFinished`.

### Layout

| Path | Purpose |
| --- | --- |
| `chart/Chart.yaml` | Chart metadata. `version` is the chart semver, `appVersion` tracks the `mal-sync` image. |
| `chart/values.yaml` | Single source of truth for user-facing config. |
| `chart/templates/` | All rendered manifests. Three parallel feature sets: `alertmanager-*`, `rules-*` (Mimir rules), `loki-rules-*`. Plus RBAC + helpers. |
| `chart/README.md` | **Generated** by `helm-docs` from `chart/README.md.tpl` + `values.yaml`. Do NOT hand-edit. |
| `chart/ct.yaml` | `chart-testing` config used by CI. |
| `.github/workflows/` | CI: `lint-test.yaml`, `release.yaml`, `superlinter.yml`. |
| `.github/cr.yaml` | `chart-releaser-action` config (publishes to `gh-pages` branch). |
| `.helm-docs.yml` | `helm-docs` config (`fail-on-diff: true`). |
| `scripts/release.sh` | Interactive release helper (bump → validate → docs → commit → push `main`; `chart-releaser-action` handles tag, gh-pages, GitHub Release). |
| `.github/agents/` | Custom Copilot CLI subagents scoped to this repo. |

## Hard rules

1. **Mandatory `/codex:review` before every push.** Every commit you intend to
   push — directly to `main`, to a feature branch, or as part of a release —
   MUST be reviewed by running the `/codex:review` slash command first. No
   exceptions, including docs-only commits and release commits made by
   `scripts/release.sh`. If `/codex:review` reports issues that aren't false
   positives, fix them in additional commits and re-run `/codex:review` until
   it is clean. Only then run `git push`.
2. **Never hand-edit `chart/README.md`.** Update `values.yaml` and/or
   `chart/README.md.tpl`, then run `helm-docs` from the repo root. CI
   (`lint-test.yaml` and `superlinter.yml`) runs `helm-docs && git diff
   --exit-code` and fails on any drift.
3. **Keep alertmanager / rules / loki-rules feature sets symmetric.** When you
   change one (values keys, ConfigMap vs Secret handling, env wiring,
   volumes), apply the same change to the other two unless the user
   explicitly scopes the work.
4. **Don't break backward compatibility of `values.yaml` keys** without an
   explicit user request and a corresponding **major** chart version bump.
5. **Never re-tag an existing version**, never force-push tags, never push
   tags that don't match `^v\d+\.\d+\.\d+$`.
6. **No secrets in the repo.** Super-Linter runs Gitleaks on every PR.
7. **Commit trailer.** Every commit must end with:
   ```
   Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
   ```

## Standard workflow for a chart change

1. **Plan.** For non-trivial work, sketch the change and consult the
   rubber-duck agent before editing.
2. **Edit** `chart/values.yaml`, templates, and `chart/README.md.tpl` as needed.
   Use the `helm-chart-engineer` subagent for substantial template work.
3. **Regenerate docs.**
   ```bash
   helm-docs
   ```
   (Install with `go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest`
   if missing. CI uses version `1.14.2`.)
4. **Validate locally** (also see the `helm-tester` subagent):
   ```bash
   helm lint chart/
   helm template test chart/ --debug >/dev/null
   helm template test chart/ \
     --set alertmanager.enabled=true \
     --set rules.enabled=true \
     --set lokiRules.enabled=true \
     --set lokiRules.config.type=configmap \
     --set alertmanager.config.type=configmap \
     --set rules.config.type=configmap \
     --debug >/dev/null
   ct lint --config chart/ct.yaml --charts chart/   # if ct is installed
   ```
5. **Commit** with a Conventional Commits message (`feat:`, `fix:`, `chore:`,
   `docs:`, `refactor:`, `ci:`). Stage only intended files; never `git add .`
   blindly.
6. **`/codex:review` (REQUIRED).** Run the slash command and address every
   non-trivial finding before pushing.
7. **Push.** Open a PR if working on a branch — `lint-test.yaml` and
   `superlinter.yml` will gate the merge.

## Releasing a new version

There is **one release path**. `chart-releaser-action`
(`.github/workflows/release.yaml`) is the sole publisher: when a commit on
`main` bumps `chart/Chart.yaml`'s `version:`, the workflow tags `vX.Y.Z`,
packages the chart, pushes to `gh-pages` (served at
`https://antnsn.github.io/mimir-sync`), creates the GitHub Release, and
opens an `update-helm-docs` PR if `helm-docs` would change anything. **You
do not create or push tags yourself.**

### `scripts/release.sh` (recommended)

What it does, in order:

1. Verifies preconditions (on `main`, clean tree, in sync with
   `origin/main`).
2. Prompts for the new chart `version` and validates strictly against
   `^[0-9]+\.[0-9]+\.[0-9]+$` (no pre-release / build metadata).
3. Confirms `vX.Y.Z` does not already exist locally or on `origin`.
4. Bumps `chart/Chart.yaml` `version:` (and optionally `appVersion:`).
5. Runs `helm lint`, two `helm template` passes (defaults + all features
   enabled), and `ct lint` if `ct` is on `PATH`.
6. Runs `helm-docs` pinned to `v1.14.2` (same version as CI).
7. Shows the diff, prints a `/codex:review` reminder, and requires you to
   type `proceed` to continue.
8. Commits `chart/Chart.yaml` + `chart/README.md` with the
   `Co-authored-by: Copilot` trailer and pushes to `main`.

The script does **not** create or push tags, does **not** modify
`gh-pages`, and does **not** call `gh release create`. The workflow does
all of that after the push.

```bash
./scripts/release.sh --dry-run   # validates in an isolated git worktree
./scripts/release.sh
```

> **`/codex:review` requirement still applies.** Run `/codex:review` on the
> staged release commit (and any preceding unreleased commits on `main`)
> before typing `proceed`. The script's confirmation is not a substitute.

### Manual equivalent

If you cannot use the script:

1. From a clean `main`, edit `chart/Chart.yaml` to bump `version:` (and
   `appVersion:` only if the `mal-sync` image contract changed).
2. Run `helm lint chart/`, `helm template`, and
   `helm-docs` (pinned: `go install github.com/norwoodj/helm-docs/cmd/helm-docs@v1.14.2`).
3. Run `/codex:review` on the staged change.
4. Commit and push:
   ```bash
   git add chart/Chart.yaml chart/README.md
   git commit -m "chore: prepare for vX.Y.Z release" \
     -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
   git push origin main
   ```

The workflow takes over from there. Watch with `gh run watch` or
`gh run list --workflow=release.yaml -L 1`.

### Pre-release checklist

- [ ] Working tree clean, on `main`, in sync with `origin/main`.
- [ ] `chart/Chart.yaml` `version` bumped per semver (breaking → major,
      additive feature → minor, fix only → patch).
- [ ] `appVersion` updated only if the `mal-sync` image contract changed.
- [ ] `helm-docs` produced no uncommitted diff.
- [ ] `helm lint chart/` and `ct lint` (if available) pass.
- [ ] `/codex:review` clean on every commit being pushed.

## Subagents

Custom subagents live in `.github/agents/` and are auto-discovered by the
Copilot CLI. Prefer delegating to them rather than doing everything in the
main context:

- `helm-chart-engineer` — template/values edits.
- `helm-tester` — `helm lint` / `helm template` / `ct lint`.
- `release-manager` — orchestrates `scripts/release.sh` and the release flow.
- `ci-workflow-engineer` — workflow files and CI debugging.

## CI you must keep green

| Workflow | Trigger | What it enforces |
| --- | --- | --- |
| `lint-test.yaml` | PRs touching `chart/**` or `.github/workflows/*.yaml` | `helm-docs` clean, `ct lint`, `ct install` on a `kind` cluster when the chart actually changed (uses Prometheus Operator CRDs). |
| `superlinter.yml` | PRs | Super-Linter (Bash, EditorConfig, GitHub Actions, Gitleaks, JSON, Python, Renovate, shfmt, XML) + a second job re-running `helm-docs` to guard against drift. |
| `release.yaml` | `main` push touching `chart/**`, releases, manual dispatch | `chart-releaser-action`, `helm-docs` regen, opens a PR with doc updates. |

If a workflow breaks, prefer fixing the root cause over disabling the check.

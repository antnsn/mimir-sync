# Custom Copilot CLI agents for mimir-sync

These agents give the Copilot CLI specialized roles for working on this Helm
chart. They are auto-discovered from `.github/agents/*.md`.

| Agent | When to use |
|-------|-------------|
| [`helm-chart-engineer`](./helm-chart-engineer.md) | Editing `chart/templates/`, `values.yaml`, `_helpers.tpl`. |
| [`helm-tester`](./helm-tester.md) | Running `helm lint`, `helm template`, and `ct lint` after chart changes. |
| [`release-manager`](./release-manager.md) | Bumping `Chart.yaml`, regenerating docs, and driving `scripts/release.sh`. |
| [`ci-workflow-engineer`](./ci-workflow-engineer.md) | Maintaining `.github/workflows/*` and CI configuration. |

## Suggested flow

1. **Plan** the change yourself, optionally consulting the rubber-duck agent.
2. Delegate template/values edits to **`helm-chart-engineer`**.
3. Hand off to **`helm-tester`** to validate.
4. When cutting a release, drive **`release-manager`**; if CI breaks, escalate
   to **`ci-workflow-engineer`**.

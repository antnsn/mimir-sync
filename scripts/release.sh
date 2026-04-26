#!/usr/bin/env bash
# Release helper for the mimir-sync Helm chart.
#
# Single release path: this script bumps chart/Chart.yaml, validates,
# regenerates docs, commits, and pushes to main. It does NOT create or push
# tags, and it does NOT touch gh-pages. The chart-releaser-action workflow
# (.github/workflows/release.yaml) is the sole publisher: it tags, packages,
# pushes to gh-pages, and creates the GitHub Release.

set -euo pipefail

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------
HELM_DOCS_VERSION="v1.14.2"
CHART_DIR="chart"
CHART_FILE="${CHART_DIR}/Chart.yaml"
CHART_README="${CHART_DIR}/README.md"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# State for cleanup
ORIGINAL_BRANCH=""

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      ;;
    -h|--help)
      cat <<'EOF'
Usage: scripts/release.sh [--dry-run]

Bumps chart/Chart.yaml, validates the chart, regenerates chart/README.md,
commits, and pushes to main. The chart-releaser-action workflow handles
tagging, packaging, gh-pages publication, and the GitHub Release.

Options:
  --dry-run   Run all checks and show the diff in an isolated worktree, but
              do not modify the working tree or push anything.
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Trap
# ---------------------------------------------------------------------------
on_error() {
  local rc=$?
  echo -e "${RED}release.sh failed with exit ${rc}${NC}" >&2
  if [[ -n "${ORIGINAL_BRANCH}" ]]; then
    git checkout "${ORIGINAL_BRANCH}" >/dev/null 2>&1 || true
  fi
  cleanup_worktree || true
  exit "$rc"
}
trap on_error ERR

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Cross-platform sed -i wrapper
sed_inplace() {
  if sed --version >/dev/null 2>&1; then
    sed -i "$@"
  else
    sed -i '' "$@"
  fi
}

ensure_helm_docs() {
  if command_exists helm-docs; then
    return
  fi
  echo -e "${YELLOW}helm-docs not found. Installing ${HELM_DOCS_VERSION}...${NC}"
  if ! command_exists go; then
    echo -e "${RED}Error: Go is required to install helm-docs.${NC}" >&2
    exit 1
  fi
  GO111MODULE=on go install "github.com/norwoodj/helm-docs/cmd/helm-docs@${HELM_DOCS_VERSION}"
  GOPATH_BIN="$(go env GOPATH)/bin"
  export PATH="${GOPATH_BIN}:${PATH}"
}

DRYRUN_WORKTREE=""
cleanup_worktree() {
  if [[ -n "${DRYRUN_WORKTREE}" && -d "${DRYRUN_WORKTREE}" ]]; then
    git worktree remove --force "${DRYRUN_WORKTREE}" >/dev/null 2>&1 || rm -rf "${DRYRUN_WORKTREE}"
    DRYRUN_WORKTREE=""
  fi
}

# ---------------------------------------------------------------------------
# Preconditions
# ---------------------------------------------------------------------------
echo -e "${YELLOW}Checking preconditions...${NC}"

if [[ ! -f "${CHART_FILE}" ]]; then
  echo -e "${RED}Error: ${CHART_FILE} not found. Run from repo root.${NC}" >&2
  exit 1
fi

ORIGINAL_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
if [[ "${ORIGINAL_BRANCH}" != "main" ]]; then
  echo -e "${RED}Error: must be on 'main' branch (currently on '${ORIGINAL_BRANCH}').${NC}" >&2
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo -e "${RED}Error: working tree is not clean. Commit or stash changes first.${NC}" >&2
  git status --short >&2
  exit 1
fi

echo -e "${YELLOW}Fetching origin...${NC}"
git fetch origin --quiet
LOCAL_HEAD="$(git rev-parse @)"
REMOTE_HEAD="$(git rev-parse @{u})"
if [[ "${LOCAL_HEAD}" != "${REMOTE_HEAD}" ]]; then
  echo -e "${RED}Error: local main is not in sync with origin/main.${NC}" >&2
  echo "  local:  ${LOCAL_HEAD}" >&2
  echo "  remote: ${REMOTE_HEAD}" >&2
  exit 1
fi

if ! command_exists helm; then
  echo -e "${RED}Error: helm is not installed.${NC}" >&2
  exit 1
fi

echo -e "${GREEN}✓ Preconditions OK${NC}"

# ---------------------------------------------------------------------------
# Read current version, prompt for new version
# ---------------------------------------------------------------------------
CURRENT_VERSION="$(grep '^version:' "${CHART_FILE}" | awk '{print $2}')"
CURRENT_APP_VERSION="$(grep '^appVersion:' "${CHART_FILE}" | awk -F'"' '{print $2}')"

echo -e "${YELLOW}Current chart version:    ${CURRENT_VERSION}${NC}"
echo -e "${YELLOW}Current chart appVersion: ${CURRENT_APP_VERSION}${NC}"

read -r -p "Enter new version (current: ${CURRENT_VERSION}): " NEW_VERSION

if ! [[ "${NEW_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo -e "${RED}Error: invalid version. Must match ^[0-9]+\\.[0-9]+\\.[0-9]+$ (no pre-release / build metadata).${NC}" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Tag-uniqueness check
# ---------------------------------------------------------------------------
echo -e "${YELLOW}Checking that tag v${NEW_VERSION} does not already exist...${NC}"
git fetch --tags origin --quiet
if git rev-parse -q --verify "refs/tags/v${NEW_VERSION}" >/dev/null \
   || git ls-remote --exit-code --tags origin "v${NEW_VERSION}" >/dev/null 2>&1; then
  echo -e "${RED}Error: tag v${NEW_VERSION} already exists locally or on origin. Bump to a new version.${NC}" >&2
  exit 1
fi
echo -e "${GREEN}✓ Tag v${NEW_VERSION} is available${NC}"

# ---------------------------------------------------------------------------
# Optional appVersion bump
# ---------------------------------------------------------------------------
NEW_APP_VERSION=""
read -r -p "Update appVersion? (current: ${CURRENT_APP_VERSION}) [y/N] " -n 1 REPLY || true
echo
if [[ "${REPLY}" =~ ^[Yy]$ ]]; then
  read -r -p "Enter new appVersion: " NEW_APP_VERSION
  if [[ -z "${NEW_APP_VERSION}" ]]; then
    echo -e "${RED}Error: empty appVersion.${NC}" >&2
    exit 1
  fi
fi

# ---------------------------------------------------------------------------
# Choose work directory:
#   - dry-run: an isolated git worktree at HEAD
#   - real:   the current repo
# ---------------------------------------------------------------------------
WORK_DIR="$(pwd)"
if [[ "${DRY_RUN}" == true ]]; then
  DRYRUN_WORKTREE="$(pwd)/.release-dryrun-$$"
  echo -e "${YELLOW}[dry-run] Creating isolated worktree at ${DRYRUN_WORKTREE}${NC}"
  git worktree add --quiet --detach "${DRYRUN_WORKTREE}" HEAD
  WORK_DIR="${DRYRUN_WORKTREE}"
fi

pushd "${WORK_DIR}" >/dev/null

# ---------------------------------------------------------------------------
# Bump Chart.yaml
# ---------------------------------------------------------------------------
echo -e "${YELLOW}Updating ${CHART_FILE} version to ${NEW_VERSION}...${NC}"
sed_inplace "s/^version: .*/version: ${NEW_VERSION}/" "${CHART_FILE}"
if [[ -n "${NEW_APP_VERSION}" ]]; then
  echo -e "${YELLOW}Updating ${CHART_FILE} appVersion to ${NEW_APP_VERSION}...${NC}"
  sed_inplace "s/^appVersion: .*/appVersion: \"${NEW_APP_VERSION}\"/" "${CHART_FILE}"
fi

# ---------------------------------------------------------------------------
# Validate
# ---------------------------------------------------------------------------
echo -e "${YELLOW}Running helm lint...${NC}"
helm lint "${CHART_DIR}/"

echo -e "${YELLOW}Running helm template (default values)...${NC}"
helm template release-check "${CHART_DIR}/" --debug >/dev/null

echo -e "${YELLOW}Running helm template (all features enabled)...${NC}"
helm template release-check "${CHART_DIR}/" --debug \
  --set alertmanager.enabled=true \
  --set rules.enabled=true \
  --set lokiRules.enabled=true \
  --set alertmanager.config.type=configmap \
  --set rules.config.type=configmap \
  --set lokiRules.config.type=configmap \
  >/dev/null

if command_exists ct; then
  echo -e "${YELLOW}Running ct lint...${NC}"
  ct lint --config "${CHART_DIR}/ct.yaml" --charts "${CHART_DIR}/"
else
  echo -e "${YELLOW}ct not on PATH; skipping ct lint (CI will still run it).${NC}"
fi

echo -e "${GREEN}✓ Validation passed${NC}"

# ---------------------------------------------------------------------------
# helm-docs
# ---------------------------------------------------------------------------
ensure_helm_docs
echo -e "${YELLOW}Regenerating ${CHART_README} with helm-docs ${HELM_DOCS_VERSION}...${NC}"
helm-docs

# ---------------------------------------------------------------------------
# Diff
# ---------------------------------------------------------------------------
echo -e "${YELLOW}Diff to be committed:${NC}"
git --no-pager diff -- "${CHART_FILE}" "${CHART_README}"

# ---------------------------------------------------------------------------
# /codex:review reminder + typed confirmation
# ---------------------------------------------------------------------------
cat <<'EOF'

============================================================================
REMINDER: per CLAUDE.md and .github/copilot-instructions.md, you must run
/codex:review on this commit BEFORE answering 'proceed'. The script cannot
enforce this — it is your responsibility.
============================================================================
EOF

if [[ "${DRY_RUN}" == true ]]; then
  echo -e "${GREEN}✓ Dry run complete. No changes were made to the working tree.${NC}"
  popd >/dev/null
  cleanup_worktree
  exit 0
fi

read -r -p "Type 'proceed' to commit and push to main (anything else cancels): " CONFIRM
if [[ "${CONFIRM}" != "proceed" ]]; then
  echo -e "${YELLOW}Release cancelled. Reverting working-tree changes...${NC}"
  git restore --staged "${CHART_FILE}" "${CHART_README}" 2>/dev/null || true
  git checkout -- "${CHART_FILE}" "${CHART_README}"
  popd >/dev/null
  exit 1
fi

# ---------------------------------------------------------------------------
# Commit & push
# ---------------------------------------------------------------------------
echo -e "${YELLOW}Committing release...${NC}"
git add "${CHART_FILE}" "${CHART_README}"
git commit \
  -m "chore: prepare for v${NEW_VERSION} release" \
  -m "Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"

echo -e "${YELLOW}Pushing to origin/main...${NC}"
git push origin main

popd >/dev/null

cat <<EOF

${GREEN}✓ Release commit pushed to main.${NC} The chart-releaser-action workflow will:
  - tag v${NEW_VERSION}
  - package the chart
  - publish to gh-pages and Artifact Hub
  - create a GitHub Release

Watch progress with:
  gh run watch
  gh run list --workflow=release.yaml -L 1

The new version will be available at:
  https://antnsn.github.io/mimir-sync
EOF

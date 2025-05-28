#!/bin/bash
set -e

# Default values
DRY_RUN=false

# Parse command line arguments
for arg in "$@"; do
  case $arg in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      echo "Unknown argument: $arg"
      exit 1
      ;;
  esac
done

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install helm-docs if not present
install_helm_docs() {
    if ! command_exists helm-docs; then
        echo -e "${YELLOW}helm-docs not found. Installing...${NC}"
        if command_exists go; then
            GO111MODULE=on go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest
            export PATH="$(go env GOPATH)/bin:$PATH"
        else
            echo -e "${RED}Error: Go is required to install helm-docs. Please install Go and try again.${NC}"
            exit 1
        fi
    fi
}

# Function to run helm lint
run_helm_lint() {
    echo -e "${YELLOW}Running Helm lint...${NC}"
    if ! command_exists helm; then
        echo -e "${RED}Error: Helm is not installed. Please install Helm and try again.${NC}"
        exit 1
    fi
    
    if ! helm lint chart/; then
        echo -e "${RED}Error: Helm lint failed. Please fix the issues and try again.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Helm lint passed${NC}"
}

# Function to package the helm chart and update the gh-pages branch
update_gh_pages() {
    echo -e "${YELLOW}Packaging Helm chart and updating GitHub Pages...${NC}"
    
    # Create a temporary directory
    local temp_dir=$(mktemp -d)
    echo -e "${YELLOW}Using temporary directory: ${temp_dir}${NC}"
    
    # Package the chart
    echo -e "${YELLOW}Packaging chart...${NC}"
    helm package chart/ -d "${temp_dir}/charts"
    
    # Save current branch
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    
    # Switch to gh-pages branch
    echo -e "${YELLOW}Switching to gh-pages branch...${NC}"
    git fetch origin gh-pages
    git checkout gh-pages
    
    # Copy the packaged chart
    mkdir -p charts
    cp "${temp_dir}/charts/mimir-sync-${NEW_VERSION}.tgz" charts/
    
    # Update or create the index.yaml
    echo -e "${YELLOW}Updating Helm repository index...${NC}"
    if [ -f index.yaml ]; then
        helm repo index --url https://antnsn.github.io/mimir-sync --merge index.yaml .
    else
        helm repo index --url https://antnsn.github.io/mimir-sync .
    fi
    
    # Commit and push changes to gh-pages
    echo -e "${YELLOW}Committing and pushing changes to gh-pages branch...${NC}"
    git add charts/ index.yaml
    git commit -m "chore: release chart v${NEW_VERSION}"
    git push origin gh-pages
    
    # Switch back to original branch
    echo -e "${YELLOW}Switching back to ${current_branch} branch...${NC}"
    git checkout "${current_branch}"
    
    # Clean up
    rm -rf "${temp_dir}"
    
    echo -e "${GREEN}✓ GitHub Pages updated with new chart version${NC}"
}

# Function to update documentation
update_docs() {
    echo -e "${YELLOW}Updating documentation...${NC}"
    install_helm_docs
    helm-docs
    
    # Check if documentation was updated
    if ! git diff --quiet chart/README.md; then
        echo -e "${YELLOW}Documentation was updated.${NC}"
        git add chart/README.md
    else
        echo -e "${GREEN}No documentation changes detected.${NC}"
    fi
}

# Get current version from Chart.yaml
CURRENT_VERSION=$(grep '^version:' chart/Chart.yaml | awk '{print $2}')
echo -e "${YELLOW}Current version: ${CURRENT_VERSION}${NC}"

# Prompt for new version
read -p "Enter new version (current: ${CURRENT_VERSION}): " NEW_VERSION

# Validate version format (semver)
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*(\+[0-9A-Za-z-]+)?)?$ ]]; then
    echo "Error: Invalid version format. Please use semantic versioning (e.g., 1.2.3)"
    exit 1
fi

# Update Chart.yaml
echo -e "${YELLOW}Updating chart version to ${NEW_VERSION}...${NC}"
sed -i '' "s/^version: .*/version: ${NEW_VERSION}/" chart/Chart.yaml

# Update appVersion if needed
CURRENT_APP_VERSION=$(grep '^appVersion:' chart/Chart.yaml | awk -F'"' '{print $2}')
read -p "Update appVersion? (current: ${CURRENT_APP_VERSION}) [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter new appVersion: " NEW_APP_VERSION
    sed -i '' "s/^appVersion: .*/appVersion: \"${NEW_APP_VERSION}\"/" chart/Chart.yaml
fi

# Run helm lint
run_helm_lint

# Update documentation
update_docs

# Show changes
echo -e "${YELLOW}Changes to be committed:${NC}"
git diff

echo -e "\n${YELLOW}The following actions will be performed:${NC}"
echo "1. Commit version ${NEW_VERSION} changes"
echo "2. Create and push tag v${NEW_VERSION}"
echo "3. Push changes to main branch"

read -p "Proceed with release? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Release cancelled. Cleaning up...${NC}"
    git checkout -- chart/Chart.yaml
    exit 1
fi

# Commit changes
if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY RUN] Would commit changes with message: chore: prepare for v${NEW_VERSION} release${NC}"
    echo -e "${YELLOW}[DRY RUN] Would create and push tag: v${NEW_VERSION}${NC}"
    echo -e "${YELLOW}[DRY RUN] Would push changes to remote${NC}"
    echo -e "${GREEN}✓ Dry run complete. No changes were made.${NC}"
    exit 0
else
    # Real run
    echo -e "${YELLOW}Committing changes...${NC}"
    git add chart/Chart.yaml chart/README.md
    git commit -m "chore: prepare for v${NEW_VERSION} release"

    # Create and push tag
    echo -e "${YELLOW}Creating and pushing tag v${NEW_VERSION}...${NC}"
    git tag -a "v${NEW_VERSION}" -m "Release v${NEW_VERSION}"

    # Push changes
    echo -e "${YELLOW}Pushing changes to remote...${NC}"
    git push origin main
    git push origin "v${NEW_VERSION}"
    
    # Update GitHub Pages
    update_gh_pages
fi

echo -e "\n${GREEN}✓ Release v${NEW_VERSION} has been initiated!${NC}"
echo -e "${GREEN}✓ GitHub Pages has been updated with the new chart version${NC}"
echo -e "${YELLOW}The new version is now available at:${NC}"
echo "https://antnsn.github.io/mimir-sync/"

# Instructions for GitHub release
echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Go to https://github.com/antnsn/mimir-sync/releases/new"
echo "2. Select the v${NEW_VERSION} tag"
# Check if we can use GitHub CLI to create the release
if command -v gh &> /dev/null; then
    read -p "Would you like to create a GitHub release now? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Creating GitHub release...${NC}"
        gh release create "v${NEW_VERSION}" -t "v${NEW_VERSION}" -F <(echo "Release v${NEW_VERSION} of Mimir Sync Helm chart")
    fi
fi

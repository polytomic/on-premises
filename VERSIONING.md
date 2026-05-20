# Versioning and Release Strategy

This repository uses component-specific tags for releases. Each Terraform module and the Helm chart are versioned independently.

## Tag Format

**Helm Chart:**
Tags follow the pattern: `polytomic-<version>` (required by chart-releaser)

**Terraform Modules:**
Tags follow the pattern: `<module>-v<version>`

**Examples:**
```
polytomic-1.0.2
ecs-v2.9.0
eks-v1.2.0
gke-v1.3.0
```

**Component prefixes:**
- `polytomic-` - Helm chart (no v prefix)
- `ecs-v` - ECS module
- `eks-v` - EKS module
- `eks-addons-v` - EKS addons module
- `eks-helm-v` - EKS Helm deployment module
- `gke-v` - GKE module
- `gke-helm-v` - GKE Helm deployment module

### Legacy tag format

Terraform module tags created before this change used a slash-separated path:

```
terraform/<module>/v<version>
```

For example: `terraform/ecs/v2.8.0`, `terraform/gke-helm/v1.3.0`.

These tags are still valid and continue to resolve. However, Terraform's `git::` source handler passes the `ref` value through `go-getter`, which parses unencoded slashes as additional URL path segments and fails the lookup. Consumers pinning a legacy tag must URL-encode the slashes as `%2F`:

```hcl
module "polytomic" {
  source = "git::https://github.com/polytomic/on-premises.git//terraform/modules/ecs?ref=terraform%2Fecs%2Fv2.8.0"
}
```

New releases use the slash-free format above and do not require encoding:

```hcl
module "polytomic" {
  source = "git::https://github.com/polytomic/on-premises.git//terraform/modules/ecs?ref=ecs-v2.9.0"
}
```

## Semantic Versioning

- **MAJOR** (x.0.0): Breaking changes
- **MINOR** (0.x.0): New features, backwards-compatible
- **PATCH** (0.0.x): Bug fixes, backwards-compatible

## Changelogs

Each component has its own changelog:
- `helm/charts/polytomic/CHANGELOG.md`
- `terraform/modules/ecs/CHANGELOG.md`
- `terraform/modules/eks/CHANGELOG.md`
- etc.

Root `CHANGELOG.md` is an index pointing to component changelogs.

---

# Release Checklist

Your changes are in master, you're ready to cut a release:

## 1. Pick version number
Breaking changes? → MAJOR. New features? → MINOR. Bug fixes? → PATCH.

## 2. Update component CHANGELOG.md
```markdown
## [1.2.0] - 2026-01-20

### Added
- New feature X

### Fixed
- Bug Y
```

Commit it:
```bash
git add terraform/modules/eks/CHANGELOG.md
git commit -m "Update changelog for EKS module v1.2.0"
```

## 3. For Helm only: Update Chart.yaml version
```yaml
version: 1.2.0  # Update this
```

Commit it:
```bash
git add helm/charts/polytomic/Chart.yaml
git commit -m "Bump Helm chart version to 1.2.0"
```

## 4. For Helm only: Push to master
Merging the Chart.yaml version bump to master automatically triggers the
chart-releaser workflow, which creates the `polytomic-<version>` tag and
GitHub Release with the packaged chart.

```bash
git push origin master
```

## 5. For Terraform only: Create and push tag

Use the Makefile target in `terraform/`:

```bash
cd terraform
make release-tag MODULE=eks VERSION=1.2.0
```

This validates that you're on `master` with a clean tree, that the version appears in the module's CHANGELOG, creates the annotated tag in the `<module>-v<version>` format, and pushes it to `origin`.

To create the tag manually:

```bash
git tag -a eks-v1.2.0 -m "Release EKS module v1.2.0"
git push origin eks-v1.2.0
```

## 6. Update root CHANGELOG.md
Update the version number for your component:
```markdown
#### EKS Infrastructure Module
- **Current Version**: 1.2.0  ← Update this
- **Latest Tag**: `eks-v1.2.0`  ← Update this
```

Commit and push:
```bash
git add CHANGELOG.md
git commit -m "Update root changelog for EKS v1.2.0"
git push origin master
```

Done!

**Note:**
- **Helm charts**: Tag and GitHub Release are created automatically by chart-releaser when the version bump merges to master. Do not manually create tags or releases for Helm charts.
- **Terraform modules**: Optionally create a manual GitHub Release at https://github.com/polytomic/on-premises/releases

> **Warning:** Do not manually create GitHub Releases or `polytomic-*` tags for Helm charts. The chart-releaser workflow handles both. If a release already exists for a chart version, chart-releaser will skip it and the chart will not be published.

---

## Quick Reference Commands

```bash
# What changed since last release?
git log eks-v1.0.0..HEAD -- terraform/modules/eks/

# See existing tags
git tag -l "eks-v*"
git tag -l "terraform/eks/*"      # legacy
git tag -l "polytomic-*"

# Delete a tag (if you messed up)
git tag -d eks-v1.2.0
git push origin :refs/tags/eks-v1.2.0
```

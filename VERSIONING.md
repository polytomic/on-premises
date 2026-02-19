# Versioning and Release Strategy

**Adopted**: January 20, 2026

This repository uses component-specific tags for releases. Each Terraform module and the Helm chart are versioned independently.

## Tag Format

**Helm Chart:**
Tags follow the pattern: `polytomic-<version>` (required by chart-releaser)

**Terraform Modules:**
Tags follow the pattern: `terraform/<module>/v<version>`

**Examples:**
```
polytomic-1.0.2
terraform/ecs/v2.7.0
terraform/eks/v1.0.0
terraform/gke/v1.0.0
```

**Component prefixes:**
- `polytomic-` - Helm chart (no v prefix)
- `terraform/ecs/` - ECS module
- `terraform/eks/` - EKS module
- `terraform/eks-addons/` - EKS addons module
- `terraform/eks-helm/` - EKS Helm deployment module
- `terraform/gke/` - GKE module
- `terraform/gke-helm/` - GKE Helm deployment module

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

## 4. Create and push tag
```bash
# For Terraform modules
git tag -a terraform/eks/v1.2.0 -m "Release EKS module v1.2.0"
git push origin terraform/eks/v1.2.0

# For Helm chart (triggers automatic GitHub release)
# Note: Must match chart name-version format for chart-releaser
git tag -a polytomic-1.2.0 -m "Release Helm chart v1.2.0"
git push origin polytomic-1.2.0
```

## 5. Update root CHANGELOG.md
Update the version number for your component:
```markdown
#### EKS Infrastructure Module
- **Current Version**: 1.2.0  ← Update this
- **Latest Tag**: `terraform/eks/v1.2.0`  ← Update this
```

Commit and push:
```bash
git add CHANGELOG.md
git commit -m "Update root changelog for EKS v1.2.0"
git push origin master
```

Done!

**Note:**
- **Helm charts**: GitHub Release is created automatically when you push the `polytomic-*` tag
- **Terraform modules**: Optionally create a manual GitHub Release at https://github.com/polytomic/on-premises/releases

---

## Quick Reference Commands

```bash
# What changed since last release?
git log terraform/eks/v1.0.0..HEAD -- terraform/modules/eks/

# See existing tags
git tag -l "terraform/eks/*"
git tag -l "polytomic-*"

# Delete a tag (if you messed up)
git tag -d terraform/eks/v1.2.0
git push origin :refs/tags/terraform/eks/v1.2.0
```

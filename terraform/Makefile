format:
	@echo
	@for d in modules/* ; \
	 do \
			terraform fmt "$$d" ; \
			echo "Module $$d formatted... ✅" ; \
	done
	@echo "\nAll modules formatted 🎉"


generate-docs: 
	@echo
	@for d in modules/* ; \
	 do \
			terraform-docs md "$$d" >"$$d/README.md" ; \
			echo "Module $$d/README.md written... ✅" ; \
	done
	@echo "\nAll modules README.md documentation up to date 🎉"

scan:
	@echo
	@for d in modules/* ; \
	 do \
	 		echo "Scanning module $$d... " ; \
			tfsec --minimum-severity CRITICAL "$$d" || true ; \
	done
	@echo "\nAll modules scanned 🎉\n"


all: format generate-docs scan

# Releasable modules are those with their own CHANGELOG.md.
RELEASABLE_MODULES := $(sort $(notdir $(patsubst %/,%,$(dir $(wildcard modules/*/CHANGELOG.md)))))

# Create an annotated release tag for a Terraform module.
#
# Usage:
#   make release-tag MODULE=<name> VERSION=<x.y.z>
# Example:
#   make release-tag MODULE=ecs VERSION=2.9.0
#
# Produces a tag in the slash-free format `<module>-v<version>` (see ../VERSIONING.md).
# The tag is created locally; push it with the command printed at the end.
release-tag:
	@if [ -z "$(MODULE)" ] || [ -z "$(VERSION)" ]; then \
		echo "Usage: make release-tag MODULE=<name> VERSION=<x.y.z>"; \
		echo "Example: make release-tag MODULE=ecs VERSION=2.9.0"; \
		echo "Releasable modules: $(RELEASABLE_MODULES)"; \
		exit 1; \
	fi
	@if ! echo "$(RELEASABLE_MODULES)" | tr ' ' '\n' | grep -qx "$(MODULE)"; then \
		echo "Error: '$(MODULE)' is not a releasable module."; \
		echo "Releasable modules: $(RELEASABLE_MODULES)"; \
		exit 1; \
	fi
	@if [ -n "$$(git status --porcelain)" ]; then \
		echo "Error: working tree is dirty; commit or stash changes before tagging"; \
		exit 1; \
	fi
	@branch=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$branch" != "master" ]; then \
		echo "Error: must be on master to tag a release (currently on $$branch)"; \
		exit 1; \
	fi
	@if ! grep -qE "^## \[?$(VERSION)(\]| )" "modules/$(MODULE)/CHANGELOG.md"; then \
		echo "Error: version $(VERSION) not found in modules/$(MODULE)/CHANGELOG.md"; \
		echo "Add a CHANGELOG entry for this version before tagging."; \
		exit 1; \
	fi
	@tag="$(MODULE)-v$(VERSION)"; \
	if git rev-parse "$$tag" >/dev/null 2>&1; then \
		echo "Error: tag $$tag already exists"; \
		exit 1; \
	fi; \
	git tag -a "$$tag" -m "Release $(MODULE) module v$(VERSION)"; \
	echo "Created tag $$tag"; \
	echo "Push it with: git push origin $$tag"

.PHONY: format generate-docs scan release-tag
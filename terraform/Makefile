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

.PHONY: format generate-docs scan
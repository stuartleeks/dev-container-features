.PHONY: test

help: ## show this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%s\033[0m|%s\n", $$1, $$2}' \
	| column -t -s '|'

test-bash-completion: ## test the bash-completion feature
	devcontainer features test -f bash-completion -i mcr.microsoft.com/devcontainers/base:ubuntu .

test-project-sync: ## Sync the feature code to the test project
	rm -rf test-project/.devcontainer/src
	cp -r src test-project/.devcontainer/src

test-project-build: test-project-sync ## Build the test project
	@echo "Building the test project..."
	echo "" | devcontainer build --workspace-folder test-project | cat

test:
	devcontainer features test --base-image mcr.microsoft.com/devcontainers/base:ubuntu
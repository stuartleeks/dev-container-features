help: ## show this help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%s\033[0m|%s\n", $$1, $$2}' \
	| column -t -s '|'

test-bash-completion: ## test the bash-completion feature
	# devcontainer features test --remote-user vscode --skip-scenarios -f bash-completion -i mcr.microsoft.com/devcontainers/base:ubuntu .
	devcontainer features test --skip-scenarios -f bash-completion -i mcr.microsoft.com/devcontainers/base:ubuntu .
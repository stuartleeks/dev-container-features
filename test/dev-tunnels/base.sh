#!/bin/bash
set -e

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib. Syntax is...
# check <LABEL> <cmd> [args...]

# NOTE: currently have to run the test using zsh as the devtunnel install script only adds the PATH to the first shell config it finds
#       and when running as root in the dev container base image used for testing, that is .zshrc
# check "Check devtunnel is installed" zsh --interactive -c "devtunnel --version" | grep 'Tunnel CLI'

check "Check devtunnel is installed" bash -c "devtunnel --version" | grep 'Tunnel CLI'

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults

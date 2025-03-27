#!/usr/bin/env bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "cache dir permission" bash -c "test -w /dc/azure"
check "check symlink" bash -c 'test $(readlink "$HOME/.azure") == "/dc/azure/"'

# Report result
reportResults

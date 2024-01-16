#!/usr/bin/env bash

# Default test suit to run for all tests

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "cache dir permission" bash -c "test -w /dc/shellhistory"

# Report result
reportResults
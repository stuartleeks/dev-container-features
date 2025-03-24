#!/usr/bin/env bash

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "check fish config script validity" fish -c "source $HOME/.config/fish/config.fish"
check "check fish config script content" bash -c "cat $HOME/.config/fish/config.fish | grep -q 'XDG_DATA_HOME'"
check "cache dir permission" bash -c "test -w /dc/shellhistory"

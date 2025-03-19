#!/usr/bin/env bash

set -e

# Feature-specific tests
check "cache fish script" fish -c "source $HOME/.config/fish/config.fish"

./_default.sh

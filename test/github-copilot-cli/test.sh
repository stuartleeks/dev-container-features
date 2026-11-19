#!/bin/bash
set -e

INSTALL_DIR="/usr/local/share/stuartleeks-devcontainer-features/github-copilot-cli/cli/bin"

test "$(command -v copilot)" = "$INSTALL_DIR/copilot"
test -w "$INSTALL_DIR/copilot"
staging_dir="$(mktemp -d "$INSTALL_DIR/.copilot-update-test-XXXXXX")"
rmdir "$staging_dir"
COPILOT_AUTO_UPDATE=false copilot --version

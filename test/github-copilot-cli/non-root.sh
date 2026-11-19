#!/bin/bash
set -e

test "$(id -u)" -ne 0

FEATURE_DIR="/usr/local/share/stuartleeks-devcontainer-features/github-copilot-cli"

# Simulate stale ownership after UID/GID remapping, including an existing marker.
sudo chown -R root:root "$FEATURE_DIR/cli"
test ! -w "$FEATURE_DIR/cli/bin"
sudo mkdir -p "$FEATURE_DIR/markers"
sudo touch "$FEATURE_DIR/markers/oncreate"
bash "$FEATURE_DIR/scripts/oncreate.sh"

exec bash "$(dirname "$0")/test.sh"

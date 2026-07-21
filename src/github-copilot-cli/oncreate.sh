#!/usr/bin/env bash

set -e

# NOTES
# `install.sh`
# - installs GitHub Copilot CLI via https://gh.io/copilot-install
#
# `oncreate.sh`
# - fixes permissions on the mounted volume so the user can write to it
# (COPILOT_HOME is set to /dc/github-copilot-cli via containerEnv in devcontainer-feature.json)

FEATURE_DIR="/usr/local/share/stuartleeks-devcontainer-features/github-copilot-cli"
LOG_FILE="$FEATURE_DIR/log.txt"

log() {
  echo "$1"
  echo "$1" >> "$LOG_FILE"
}

if command -v sudo > /dev/null; then
  SUDO="sudo"
else
  SUDO=""
fi

$SUDO chown -R "$(id -u):$(id -g)" "$LOG_FILE"

log "In OnCreate script"
if [ -f "$FEATURE_DIR/markers/oncreate" ]; then
  log "Feature 'github-copilot-cli' oncreate actions already run, skipping"
  exit 0
fi

if [ ! -w "/dc/github-copilot-cli" ]; then
  log "Fixing permissions of '/dc/github-copilot-cli'..."
  $SUDO chown -R "$(id -u):$(id -g)" "/dc/github-copilot-cli"
  log "Done!"
else
  log "Permissions of '/dc/github-copilot-cli' are OK!"
fi

log "Adding marker file to indicate oncreate actions have been run"
$SUDO mkdir -p "$FEATURE_DIR/markers"
$SUDO touch "$FEATURE_DIR/markers/oncreate"

log "Done"


#!/bin/sh

FEATURE_DIR="/usr/local/share/stuartleeks-devcontainer-features/github-copilot-cli"
LIFECYCLE_SCRIPTS_DIR="$FEATURE_DIR/scripts"
LOG_FILE="$FEATURE_DIR/log.txt"

set -e

mkdir -p "${FEATURE_DIR}"

echo "" > "$LOG_FILE"
log() {
  echo "$1"
  echo "$1" >> "$LOG_FILE"
}

log "Activating feature 'github-copilot-cli'"
log "User: ${_REMOTE_USER}     User home: ${_REMOTE_USER_HOME}"

log "Installing GitHub Copilot CLI..."
curl -fsSL https://gh.io/copilot-install | bash
log "GitHub Copilot CLI installed"

if [ -f oncreate.sh ]; then
    mkdir -p "${LIFECYCLE_SCRIPTS_DIR}"
    cp oncreate.sh "${LIFECYCLE_SCRIPTS_DIR}/oncreate.sh"
fi
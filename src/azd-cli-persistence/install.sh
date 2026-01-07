#!/bin/sh

FEATURE_DIR="/usr/local/share/stuartleeks-devcontainer-features/azd-cli-persistence"
LIFECYCLE_SCRIPTS_DIR="$FEATURE_DIR/scripts"
LOG_FILE="$FEATURE_DIR/log.txt"

set -e

mkdir -p "${FEATURE_DIR}"

echo "" > "$LOG_FILE"
log() {
  echo "$1"
  echo "$1" >> "$LOG_FILE"
}

log "Activating feature 'azd-cli-persistence'"
log "User: ${_REMOTE_USER}     User home: ${_REMOTE_USER_HOME}"

# check if marker file exists to avoid re-running oncreate script actions
if [ -f "$$FEATURE_DIR/markers/install" ]; then
  log "Feature 'azd-cli-persistence' already installed, skipping oncreate actions"
  exit 0
fi

got_old_azure_folder=false
if [ -e "$_REMOTE_USER_HOME/.azd" ]; then
  log "Moving existing .azd folder to .azd-old"
  mv "$_REMOTE_USER_HOME/.azd" "$_REMOTE_USER_HOME/.azd-old"
  got_old_azure_folder=true
else
  log "No existing .azd folder found at '$_REMOTE_USER_HOME/.azd'"
fi

log "symlinking ~/.azd"
ln -s /dc/azure-dev/ "$_REMOTE_USER_HOME/.azd"
chown -R "${_REMOTE_USER}:${_REMOTE_USER}" "$_REMOTE_USER_HOME/.azd"

if [ -f oncreate.sh ]; then
    mkdir -p "${LIFECYCLE_SCRIPTS_DIR}"
    cp oncreate.sh "${LIFECYCLE_SCRIPTS_DIR}/oncreate.sh"
fi

log "Adding marker file to indicate persistence is installed"
mkdir -p "$FEATURE_DIR/markers"
touch "$FEATURE_DIR/markers/install"
#!/bin/sh

FEATURE_DIR="/usr/local/share/stuartleeks-devcontainer-features/azure-cli-persistence"
LIFECYCLE_SCRIPTS_DIR="$FEATURE_DIR/scripts"
LOG_FILE="$FEATURE_DIR/log.txt"

set -e

mkdir -p "${FEATURE_DIR}"

echo "" > "$LOG_FILE"
log() {
  echo "$1"
  echo "$1" >> "$LOG_FILE"
}

log "Activating feature 'azure-cli-persistence'"
log "User: ${_REMOTE_USER}     User home: ${_REMOTE_USER_HOME}"

got_old_azure_folder=false
if [ -e "$_REMOTE_USER_HOME/.azure" ]; then
  log "Moving existing .azure folder to .azure-old"
  mv "$_REMOTE_USER_HOME/.azure" "$_REMOTE_USER_HOME/.azure-old"
  got_old_azure_folder=true
fi

ln -s /dc/azure/ "$_REMOTE_USER_HOME/.azure"
chown -R "${_REMOTE_USER}:${_REMOTE_USER}" "$_REMOTE_USER_HOME/.azure"

if [ -f oncreate.sh ]; then
    mkdir -p "${LIFECYCLE_SCRIPTS_DIR}"
    cp oncreate.sh "${LIFECYCLE_SCRIPTS_DIR}/oncreate.sh"
fi

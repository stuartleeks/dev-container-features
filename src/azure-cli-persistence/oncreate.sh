#!/usr/bin/env bash

set -e

FEATURE_DIR="/usr/local/share/stuartleeks-devcontainer-features/azure-cli-persistence"
LOG_FILE="$FEATURE_DIR/log.txt"

log() {
  echo "$1"
  echo "$1" >> "$LOG_FILE"
}

if command -v sudo > /dev/null; then
  sudo chown -R "$(id -u):$(id -g)" "$LOG_FILE"
else
  chown -R "$(id -u):$(id -g)" "$LOG_FILE"
fi

log "In OnCreate script"

fix_permissions() {
    local dir
    dir="${1}"

    if [ ! -w "${dir}" ]; then
        echo "Fixing permissions of '${dir}'..."
        sudo chown -R "$(id -u):$(id -g)" "${dir}"
        echo "Done!"
    else
        echo "Permissions of '${dir}' are OK!"
    fi
}

fix_permissions "/dc/azure"

# Fix up the cliextensions folder in case the user had an old .azure folder
# that had extensions installed in it (e.g. using the azure-cli feature and specifying extensions to install)

if [ -d "$HOME/.azure-old" ]; then
    got_old_azure_folder=true
else
    got_old_azure_folder=false
fi


old_cliextensions_folder="$HOME/.azure-old/cliextensions"
new_cliextensions_folder="$HOME/.azure/cliextensions"
new_cliextensions_folder_parent="$HOME/.azure"

got_old_extensions_folder=false

if [ "$got_old_azure_folder" = true ]; then
  if [ -d "$old_cliextensions_folder" ]; then
    got_old_extensions_folder=true
    log "cliextensions folder found in old .azure folder"
    if [ -d "$new_cliextensions_folder" ]; then
      if [ -L "$new_cliextensions_folder" ]; then
        symlink_target=$(readlink "$new_cliextensions_folder")
        if [ "$symlink_target" = "$old_cliextensions_folder" ]; then
          log "cliextensions folder ('$new_cliextensions_folder') already symlinked to '$old_cliextensions_folder' - no action needed"
        else
          log "cliextensions folder ('$new_cliextensions_folder') is a symlink, but points to a different location ('$symlink_target')"
          exit 1
        fi
      else
        log "cliextensions folder ('$new_cliextensions_folder') already exists in but is not a symlink"
        exit 1
      fi
    else
      log "cliextensions folder ('$new_cliextensions_folder') does not exist - creating symlink to '$old_cliextensions_folder'"
      if command -v sudo > /dev/null; then
        sudo ln -s "$old_cliextensions_folder" "$new_cliextensions_folder_parent"
      else
        ln -s "$old_cliextensions_folder" "$new_cliextensions_folder_parent"
      fi
    fi
  fi
fi

# If we haven't got an old .azure folder with a cliextensions folder in it, check if the new cliextensions folder is a symlink to the old one
# And if so, remove the symlink
# This can happen if the user has installed the azure-cli feature and specified extensions to install
# and then later removed the extensions.
if [ "$got_old_extensions_folder" = false ]; then
  if [ -L "$new_cliextensions_folder" ]; then
    symlink_target=$(readlink "$new_cliextensions_folder")
    if [ "$symlink_target" = "$old_cliextensions_folder" ]; then
      log "cliextensions folder ('$new_cliextensions_folder') is a symlink to '$old_cliextensions_folder' - removing symlink"
      rm "$new_cliextensions_folder"
    fi
  fi
fi

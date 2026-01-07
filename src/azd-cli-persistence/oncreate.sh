#!/usr/bin/env bash

set -e

# NOTES
# `install.sh`
# - moves `.azd` to `.~azd-old` if it exists
# - creates symlink from `~/.azd` to the mounted volume
#
# `oncreate.sh`
# - if the old `.azd/extensions` folder exists
#   - and is symlinked to the same location then exit (success)
#   - and is symlinked to a different location then fail (unexpected/unplanned state)
#   - and not a symlink then copy extensions from the old folder to the new location, adding marker files to copied extensions. Additionally clean up any extensions with the marker file that no longer exist in the source folder (i.e. extensions that the user has removed but we previously copied).
# - if the old `.azd/extensions` folder does not exist then check if the new `.azd/extensions` folder is a symlink to the old location and if so, remove the symlink


FEATURE_DIR="/usr/local/share/stuartleeks-devcontainer-features/azd-cli-persistence"
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
# check if marker file exists to avoid re-running oncreate script actions
if [ -f "$HOME/.stuartleeks/azd-cli-persistence-oncreate" ]; then
  log "Feature 'azd-cli-persistence' oncreate actions already run, skipping"
  exit 0
fi


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

fix_permissions "/dc/azure-dev"

add_marker() {
  log "Adding marker file to indicate oncreate actions have been run"
  mkdir -p "$HOME/markers"
  if command -v sudo > /dev/null; then
    sudo touch "$FEATURE_DIR/markers/oncreate"
  else
    touch "$FEATURE_DIR/markers/oncreate"
  fi
}

merge_extensions() {
  local src_dir
  local dest_dir
  src_dir="${1}"
  dest_dir="${2}"
  log "Merging extensions from '${src_dir}' to '${dest_dir}'..."
  for extension in "${src_dir}"/*; do
    extension_name=$(basename "${extension}")
    if [ -d "${dest_dir}/${extension_name}" ]; then
      log "  Extension '${extension_name}' already exists in destination - skipping"
    else
      log "  Copying extension '${extension_name}' to destination"
      cp -R "${extension}" "${dest_dir}/"
      # Add a marker file to indicate that this extension was copied from the source folder
      touch "${dest_dir}/${extension_name}/.azd-cli-persistence-copied"
    fi
  done

  log "Checking for extensions that were copied previously but are no longer in the source folder..."
  for extension in "${dest_dir}"/*; do
    extension_name=$(basename "${extension}")
    if [ -f "${extension}/.azd-cli-persistence-copied" ]; then
      if [ ! -d "${src_dir}/${extension_name}" ]; then
        log "  Extension '${extension_name}' was copied previously but is no longer in source - removing"
        rm -rf "${extension}"
      else
        log "  Extension '${extension_name}' was copied but is still present in source - keeping"
      fi
    else
      log "  Extension '${extension_name}' was not copied by azure-cli-persistence - keeping"
    fi
  done
}

# Fix up the extensions folder in case the user had an old .azd folder
# that had extensions installed in it

if [ -d "$HOME/.azd-old" ]; then
    got_old_azure_folder=true
else
    got_old_azure_folder=false
fi


old_extensions_folder="$HOME/.azc-old/extensions"
new_extensions_folder="$HOME/.azc/extensions"
new_extensions_folder_parent="$HOME/.azc"

if [ -d "$old_extensions_folder" ]; then
  log "extensions folder found in old .azd folder"
  if [ -d "$new_extensions_folder" ]; then
    if [ -L "$new_extensions_folder" ]; then
      symlink_target=$(readlink "$new_extensions_folder")
      if [ "$symlink_target" = "$old_extensions_folder" ]; then
        log "extensions folder ('$new_extensions_folder') already symlinked to '$old_extensions_folder' - no action needed"
        add_marker
        log "Done"
        exit 0
      else
        log "extensions folder ('$new_extensions_folder') is a symlink, but points to a different location ('$symlink_target')"
        exit 1
      fi
    else
      log "extensions folder ('$new_extensions_folder') already exists but is not a symlink"
      merge_extensions "$old_extensions_folder" "$new_extensions_folder"
      add_marker
      log "Done"
      exit 0
    fi
  else
    log "extensions folder ('$new_extensions_folder') does not exist - creating symlink to '$old_extensions_folder'"
    log "Creating symlink..."
    if command -v sudo > /dev/null; then
      sudo ln -s "$old_extensions_folder" "$new_extensions_folder_parent"
    else
      ln -s "$old_extensions_folder" "$new_extensions_folder_parent"
    fi
    add_marker
    log "Done"
    exit 0
  fi
else
  log "No old .azd/extensions folder found"
  # If we haven't got an old .azd folder with a extensions folder in it, check if the new extensions folder is a symlink to the old one
  # And if so, remove the symlink
  # This can happen if the user has installed extensions before this feature runs
  if [ -L "$new_extensions_folder" ]; then
    symlink_target=$(readlink "$new_extensions_folder")
    if [ "$symlink_target" = "$old_extensions_folder" ]; then
      log "extensions folder ('$new_extensions_folder') is a symlink to '$old_extensions_folder' which doesn't exist- removing symlink"
      rm "$new_extensions_folder"
    fi
  fi
fi

add_marker
log "Done"


#!/bin/bash
set -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

rm -rf "$script_dir/.devcontainer/shell-history"
cp -R "$script_dir/../src/shell-history" $script_dir/.devcontainer/shell-history

rm -rf $script_dir/.devcontainer/azure-cli-persistence
cp -R "$script_dir/../src/azure-cli-persistence" $script_dir/.devcontainer/azure-cli-persistence

echo "" | devcontainer build --workspace-folder $script_dir

#!/usr/bin/env bash

set -e

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

# Generally, the installation favours configuring a shell to use the mounted volume
# for storing history rather than symlinking as any operation to recreate files 
# could delete the symlink. 
# On shells where this isn't possible, we symlink as a fallback.

echo "Activating feature 'shell-history'"
echo "User: $(id -un)"

if [ "$SHELL" = "/bin/bash" ]; then
    if [[ -z "$HISTFILE_OLD" ]]; then
        export HISTFILE_OLD=$HISTFILE
    fi
    export HISTFILE=/dc/shellhistory/.bash_history
    export PROMPT_COMMAND='history -a'
    fix_permissions /dc/shellhistory

elif [ "$SHELL" = "/bin/zsh" ]; then

    export HISTFILE=/dc/shellhistory/.zsh_history
    export PROMPT_COMMAND='history -a'
    fix_permissions /dc/shellhistory

elif [ "$SHELL" = "/usr/bin/fish" ]; then

    if [ -z "$XDG_DATA_HOME" ]; 
    then
        set history_location ~/.local/share/fish/fish_history
    else
        set history_location $XDG_DATA_HOME/fish/fish_history
    fi

    if [ -f $history_location ]; then
        mv $history_location "$history_location-old"
    fi 

    ln -s /dc/shellhistory/fish_history $history_location
    fix_permissions $history_location
fi

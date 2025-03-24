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
echo "User home: $HOME"


# Set HISTFILE for bash
cat << EOF >> "$HOME/.bashrc"
if [[ -z "\$HISTFILE_OLD" ]]; then
    export HISTFILE_OLD=\$HISTFILE
fi
export HISTFILE=/dc/shellhistory/.bash_history
export PROMPT_COMMAND='history -a'
EOF

# Set HISTFILE for zsh
cat << EOF >> "$HOME/.zshrc"
export HISTFILE=/dc/shellhistory/.zsh_history
export PROMPT_COMMAND='history -a'
EOF

# Create symlink for fish
mkdir -p $HOME/.config/fish
cat << 'EOF' >> "$HOME/.config/fish/config.fish"
if [ -z "$XDG_DATA_HOME" ];
    set history_location ~/.local/share/fish/fish_history
else
    set history_location $XDG_DATA_HOME/fish/fish_history
end

if [ -f $history_location ];
    mv $history_location "$history_location-old"
end

ln -fs /dc/shellhistory/fish_history $history_location
EOF

fix_permissions /dc/shellhistory

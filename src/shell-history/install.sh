#!/bin/sh
set -e

echo "Activating feature 'shell-history'"
echo "User: ${_REMOTE_USER}     User home: ${_REMOTE_USER_HOME}"

if [  -z "$_REMOTE_USER" ] || [ -z "$_REMOTE_USER_HOME" ]; then
  echo "***********************************************************************************"
  echo "*** Require _REMOTE_USER and _REMOTE_USER_HOME to be set (by dev container CLI) ***"
  echo "***********************************************************************************"
  exit 1
fi

#
# Generally, the installation favours configuring a shell to use the mounted volume
# for storing history rather than symlinking as any operation to recreate files 
# could delete the symlink. 
# On shells where this isn't possible, we symlink as a fallback.
#

# Set HISTFILE for bash
cat << EOF >> "$_REMOTE_USER_HOME/.bashrc"
export HISTFILE=/dc/shellhistory/.bash_history
export PROMPT_COMMAND='history -a'
sudo chown -R $_REMOTE_USER /dc/shellhistory
EOF
chown -R $_REMOTE_USER $_REMOTE_USER_HOME/.bashrc

# Set HISTFILE for zsh
cat << EOF >> "$_REMOTE_USER_HOME/.zshrc"
export HISTFILE=/dc/shellhistory/.zsh_history
export PROMPT_COMMAND='history -a'
sudo chown -R $_REMOTE_USER /dc/shellhistory
EOF
chown -R $_REMOTE_USER $_REMOTE_USER_HOME/.zshrc

# Create symlink for fish
mkdir -p $_REMOTE_USER_HOME/.config/fish
cat << EOF >> "$_REMOTE_USER_HOME/.config/fish/config.fish"
if test -z "\$XDG_DATA_HOME"
    set history_location ~/.local/share/fish/fish_history
else
    set history_location \$XDG_DATA_HOME/fish/fish_history
end
if test -f \$history_location
    mv \$history_location "\$history_location-old"
end
ln -s /dc/shellhistory/fish_history \$history_location
sudo chown -R $_REMOTE_USER \$history_location
EOF
chown -R $_REMOTE_USER $_REMOTE_USER_HOME/.config/

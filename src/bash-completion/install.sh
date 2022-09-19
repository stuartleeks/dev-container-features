#!/bin/bash
set -e

USERNAME=${USERNAME:-"automatic"}

# Determine the appropriate non-root user
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u "${CURRENT_USER}" > /dev/null 2>&1; then
            USERNAME="${CURRENT_USER}"
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi
elif [ "${USERNAME}" = "none" ] || ! id -u ${USERNAME} > /dev/null 2>&1; then
    USERNAME=root
fi

if [[ "${USERNAME}" == "root" ]]; then
  USER_HOME=/root
else
  USER_HOME=/home/${USERNAME}
fi

echo "Activating feature 'bash-completion'"
echo "User: ${USERNAME}     User home: ${USER_HOME}"

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    echo "completion file at /usr/share/bash-completion/bash_completion"
    echo -e "#bash-completion:\nsource /usr/share/bash-completion/bash_completion\n" >> "${USER_HOME}/.bashrc"
  elif [ -f /etc/bash_completion ]; then
    echo "completion file at /etc/bash_completion"
    echo -e "#bash-completion:\nsource /etc/bash_completion\n" >> "${USER_HOME}/.bashrc"
  else
    echo "bash-completion not found. Installing..."
    apt-get update
    apt-get install bash-completion
    echo -e "#bash-completion:\nsource /usr/share/bash-completion/bash_completion\n" >> "${USER_HOME}/.bashrc"
  fi
fi

#!/bin/bash
set -e

echo "Activating feature 'bash-completion'"

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    echo "completion file at /usr/share/bash-completion/bash_completion"
    echo -e "source /usr/share/bash-completion/bash_completion\n" >> ~/.bashrc
  elif [ -f /etc/bash_completion ]; then
    echo "completion file at /etc/bash_completion"
    echo -e "source /etc/bash_completion\n" >> ~/.bashrc
  else
    echo "bash-completion not found. Installing..."
    apt-get update
    apt-get install bash-completion
    echo -e "source /usr/share/bash-completion/bash_completion\n" >> ~/.bashrc
  fi
fi

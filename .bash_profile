###### Aliases
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

if [ -f ~/.bash_completions ]; then
  . ~/.bash_completions
fi

# Enable tab completion for many Bash commands.
if which brew > /dev/null && [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
  source "$(brew --prefix)/share/bash-completion/bash_completion";
elif [ -f /etc/bash_completion ]; then
  source /etc/bash_completion;
fi;

###### Setting up key-repeat
defaults write -g InitialKeyRepeat -int 13 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)

###### Generate uuid using Python
uuid() {
  python -c "import uuid; print uuid.uuid4();"
}

###### Duplicate a file adding the extention .bak_[timestamp]
backup() {
  if [ -z "${1}" ]
  then
    echo "Missing file to backup. Nothing to do."
    return 1
  fi
  BACKUP_FILENAME="${1}.bak_$(date +"%Y%m%d%H%M%S")";
  cp "${1}" "${BACKUP_FILENAME}" && echo "Backup created: ${BACKUP_FILENAME}";
}

###### Terminal environment
export PATH="/usr/local/bin:/usr/local/sbin:$PATH:/Users/tveitan/bin"

export TERM="xterm-color"

# Make grep to highlight matches
export GREP_OPTIONS='--color=auto'

# PS1
export PS1="\[\e[0;33m\]\u\[\e[0m\]@\[\e[0;32m\]\h\[\e[0m\]:\[\e[0;34m\]\W\[\e[0m\] \[\e[0;36m\]\$(__git_ps1 '(%s)')\[\e[0m\]\$ \[\e[m\]"
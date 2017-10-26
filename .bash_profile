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

###### Setup PATH
export PATH="/usr/local/bin:/usr/local/sbin:$PATH:${HOME}/bin:${HOME}/.composer/vendor/bin"

if [ -x /usr/libexec/path_helper ]; then
  eval $(/usr/libexec/path_helper -s)
fi

###### Terminal environment
export TERM="xterm-color"

# Make grep to highlight matches
export GREP_OPTIONS='--color=auto'

# Highlight manual pages.
export LESS_TERMCAP_mb=$'\E[01;31m';
export LESS_TERMCAP_md=$'\E[01;38;5;74m';
export LESS_TERMCAP_me=$'\E[0m';
export LESS_TERMCAP_se=$'\E[0m';
export LESS_TERMCAP_so=$'\E[38;5;246m';
export LESS_TERMCAP_ue=$'\E[0m';
export LESS_TERMCAP_us=$'\E[04;38;5;146m';


# PS1
export PS1="\[\e[0;33m\]\u\[\e[0m\]@\[\e[0;32m\]\h\[\e[0m\]:\[\e[0;34m\]\W\[\e[0m\] \[\e[0;36m\]\$(__git_ps1 '(%s)')\[\e[0m\]\$ \[\e[m\]"


test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

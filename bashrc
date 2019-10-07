# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

if [ -f .aliases ]; then
    . .aliases
fi

# Only for macOS. Fedora turns this on automatically via /etc/bashrc.
if [ -r "/usr/local/etc/profile.d/bash_completion.sh" ] ; then
    . "/usr/local/etc/profile.d/bash_completion.sh"
fi

if command -v direnv >/dev/null 2>&1 ; then
    eval "$(direnv hook bash)"
fi

set -o vi

# Append to history file, rather than blowing it away
shopt -s histappend

export TERM=xterm-256color
export GOPATH=$HOME/go

PATH="${GOPATH}/bin${PATH:+:${PATH}}"
PATH="${HOME}/bin${PATH:+:${PATH}}"

# kubectx default fzf support changes the "show current context"
# usage into "interactively select context" :(
export KUBECTX_IGNORE_FZF=Y

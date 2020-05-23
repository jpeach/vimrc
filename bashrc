# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

if [ -r ~/.aliases ]; then
    . ~/.aliases
fi

if command -v direnv >/dev/null 2>&1 ; then
    eval "$(direnv hook bash)"
fi

set -o vi

# Append to history file, rather than blowing it away
shopt -s histappend

export TERM=xterm-256color
export GOPATH=$HOME/go

export GIT_EDITOR=vim

# Add rustup install directory if it exists.
if [ -d "$HOME/.cargo/bin" ]; then
    PATH="${HOME}/.cargo/bin${PATH:+:${PATH}}"
fi

# Add Homebrew compat paths on macOS.
# https://discourse.brew.sh/t/why-was-with-default-names-removed/4405
if command -v brew > /dev/null 2>&1 ; then
    for p in $(brew --prefix)/opt/*/libexec/gnubin ; do
        PATH="${p}${PATH:+:${PATH}}"
    done
fi

PATH="${GOPATH}/bin${PATH:+:${PATH}}"
PATH="${HOME}/bin${PATH:+:${PATH}}"

# kubectx default fzf support changes the "show current context"
# usage into "interactively select context" :(
export KUBECTX_IGNORE_FZF=Y

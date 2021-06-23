# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

if [ -r ~/.aliases ]; then
    . ~/.aliases
fi

# If HOMEBREW_PREFIX is set we have already eval'ed this and doing it
# again will just add it into $PATH again.
if [ -d /home/linuxbrew -a -z "$HOMEBREW_PREFIX" ]; then
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
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
    . "$HOME/.cargo/env"
fi

# Add Homebrew compat paths on macOS.
# https://discourse.brew.sh/t/why-was-with-default-names-removed/4405
case $(uname -s) in
    Darwin)
        if command -v brew > /dev/null 2>&1 ; then
            for p in $(brew --prefix)/opt/*/libexec/gnubin ; do
                PATH="${p}${PATH:+:${PATH}}"
            done
        fi
    ;;
esac

PATH="${GOPATH}/bin${PATH:+:${PATH}}"
PATH="${HOME}/bin${PATH:+:${PATH}}"

# kubectx default fzf support changes the "show current context"
# usage into "interactively select context" :(
export KUBECTX_IGNORE_FZF=Y

# Ugh. Set up google cloud SDK if the homebrew cask is there.
if [ -r "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc" ]; then
    export CLOUDSDK_PYTHON="/usr/local/opt/python@3.8/libexec/bin/python"
    source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"
fi

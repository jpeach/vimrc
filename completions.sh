# This file sets up bash completions for various tooling.

# Only for macOS. Fedora turns this on automatically via /etc/bashrc.
if [ -r /usr/local/etc/profile.d/bash_completion.sh ] ; then
    source /usr/local/etc/profile.d/bash_completion.sh
# Same, but yanked from Ubuntu /etc/bash.bashrc.
elif [ -r /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
elif [ -r /etc/bash_completion ]; then
    source /etc/bash_completion
fi

if command -v kubectl >/dev/null 2>&1 ; then
    source <(kubectl completion bash)
    complete -o default -F __start_kubectl k
fi

if [ -r /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc ]  ; then
    source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc
fi

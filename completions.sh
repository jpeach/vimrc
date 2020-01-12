# This file sets up bash completions for various tooling.

# Only for macOS. Fedora turns this on automatically via /etc/bashrc.
if [ -r "/usr/local/etc/profile.d/bash_completion.sh" ] ; then
    source "/usr/local/etc/profile.d/bash_completion.sh"
fi

if command -v kubectl >/dev/null 2>&1 ; then
    source <(k completion bash)
    complete -o default -F __start_kubectl k
fi

if [ -r /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc ]  ; then
    source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc
fi

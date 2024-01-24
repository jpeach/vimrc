#! /bin/bash

# Copyright 2021 James Peach
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

readonly HERE=$(cd $(dirname $0) && pwd)

. /etc/os-release || true

error()
{
    echo "$@"
    exit 1
}

brew::available() {
    command -v brew > /dev/null 2>&1
}

ln::is_gnu() {
    ln --version 2>&1 | grep -q "GNU coreutils"
}

os::is() {
    local -r wanted="$1"

    case $(uname -s) in
    $1) return 0 ;;
    *) return 1 ;;
    esac
}

linkit()
{
    if ln::is_gnu || os::is "Linux" ; then
        # -n treat LINK_NAME  as a normal file if it
        #    is a symbolic link to a directory
        ln -snfv $1 $2
    elif os::is "Darwin" ; then
        # -s symbolic
        # -h don't follow target symlinks
        # -f overwrite target
        # -v verbose
        ln -shfv $1 $2
    else
        ln -sfv $1 $2
    fi
}

# Install a muxer shell script that you can symlink commands to in
# order to run them from a Homebrew install prefix. This is useful
# for things that Homebrew refuses to link (like llvm and openssl).
brew::prefix()
{
    local prefix="$1"
    local progname=".homebrew.$prefix"

    touch ~/bin/"$progname"
    chmod 755  ~/bin/"$progname"

    cat > ~/bin/"$progname" <<EOF
#! /usr/bin/env bash

readonly PROG=\$(basename \$0)
readonly PREFIX=\$(brew --prefix ${prefix})

case \$PROG in
$progname)
    echo homebrew.${prefix} runs a program from the ${prefix} Homebrew prefix
    ;;
*)
    exec \${PREFIX}/bin/\${PROG} "\$@"
    ;;
esac
EOF
}

# Install a bash profile.
bash::profile() {
    cat > ~/.bash_profile <<EOF
source ~/.bashrc
source $HERE/completions.sh
EOF
}

# Set a git global config item
git::config() {
    local -r key="$1"
    local -r value="$2"

    git config --global "$key" "$value"
}

HOMEDIR=$(cd ~ && pwd)
VIMRC=$(cd $(dirname $0) && pwd)

# Trim a leading $HOMEDIR from the VIMRC path, which turns it into a relative
# path if it's inside $HOMEDIR. If it's an absolute path, we will lose the
# leading '/', but put it back later.
VIMRC=${VIMRC##$HOMEDIR/}

(
    cd ~

    [[ -d "$VIMRC" ]] || VIMRC="/${VIMRC}"
    [[ -d "$VIMRC" ]] || error "can't find $VIMRC"
    [[ -d ~/bin ]] || mkdir ~/bin

    # Remove any old symlink first so that we don't follow it.
    [[ -L ~/.vim ]] && rm -v ~/.vim

    # If it's an old directory, save it.
    [[ -d ~/.vim ]] && mv ~/.vim ~/.vim.old

    # .gitconfig isn't a symlink anymore, we just write it out.
    [[ -L ~/.gitconfig ]] && rm ~/.gitconfig

    linkit $VIMRC/tmux.conf ~/.tmux.conf
    linkit $VIMRC/vimrc ~/.vimrc
    linkit $VIMRC/ideavimrc ~/.ideavimrc
    linkit $VIMRC ~/.vim

    mkdir -p ~/.config
    linkit ../$VIMRC ~/.config/nvim

    linkit $VIMRC/aliases ~/.aliases
    linkit $VIMRC/bashrc ~/.bashrc
    linkit $VIMRC/zshrc ~/.zshrc

    # Make this an absolute symlink.
    linkit $(pwd)/$VIMRC/tmux-cc ~/bin/tmux-cc

    # Don't update Vagrantfile if it is a regular file, since I
    # probably should verify that I don't want it and/or clean up
    # and VMs.
    if [ ! -f ~/Vagrantfile ] ; then
        linkit $VIMRC/Vagrantfile ~/Vagrantfile
    else
        echo Skipping Vagrantfile update ...
    fi
)

# Install some basic Fedora packages.
if command -v dnf > /dev/null ; then
    sudo dnf install -y \
        ack \
        bash-completion \
        curl \
        direnv \
        global \
        htop \
        jq \
        neovim \
        procps-ng \
        vim-enhanced
fi

# Install some basic Debian packages.
if os::is 'Linux' ; then
    if command -v apt > /dev/null ; then
        sudo apt install -y \
            ack \
            bash-completion \
            curl \
            direnv \
            exuberant-ctags \
            fzf \
            git \
            global \
            htop \
            jq \
            neovim \
            nodejs \
            rsync \
            vim \
            watch
    fi
fi

# Install macOS basics.
if os::is "Darwin" ; then
    if brew::available ; then
        brew install \
            ack \
            bash \
            bash-completion \
            curl \
            direnv \
            fzf \
            git \
            htop \
            jq \
            kubectx \
            kubernetes-cli \
            node \
            nvim \
            rsync \
            watch
    fi

    # Install macOS prefix muxers.
    if brew::available ; then
        brew::prefix llvm
        brew::prefix openssl
        brew::prefix curl

        linkit .homebrew.curl $HOME/bin/curl
        linkit .homebrew.openssl $HOME/bin/openssl

        linkit .homebrew.llvm $HOME/bin/clangd
        linkit .homebrew.llvm $HOME/bin/clang-format
        linkit .homebrew.llvm $HOME/bin/clang-query
        linkit .homebrew.llvm $HOME/bin/clang-tidy

    fi
fi

case "$ID" in
ubuntu)
    for url in \
        https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    do
        debfile=/tmp/$(basename "$url" .deb)-$$.deb
        curl --location --progress-bar -o $debfile "$url"
        sudo apt install -y $debfile
    done
    ;;
esac

# Update vim-plug.
curl --silent --fail --location --create-dirs \
    --output ~/.vim/autoload/plug.vim \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

bash::profile

# Update global git defaults
git::config push.default    simple
git::config user.name       "James Peach"
git::config user.email      jpeach@apache.org
git::config diff.noprefix   true
git::config rerere.enabled  true # https://git-scm.com/book/en/v2/Git-Tools-Rerere
git::config grep.extendedRegexp true
git::config pull.ff only
git::config init.defaultBranch main
git::config transfer.fsckObjects true
git::config fetch.fsckObjects true

# Remember you can only have 10 "-c" commands at a time.
if command -v nvim 2>&1 ; then
    nvim \
        -c PlugUpdate \
        -c PlugInstall \
        -c PlugUpgrade \
        -c only -c quit

    nvim \
        -c "CocInstall coc-json" \
        -c "CocInstall coc-tsserver" \
        -c "CocInstall coc-go " \
        -c "CocInstall coc-clangd" \
        -c "CocInstall coc-rust-analyzer" \
        -c only -c quit

    nvim \
        -c GoInstallBinaries \
        -c only -c quit
fi

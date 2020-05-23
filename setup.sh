#! /bin/bash

# Copyright 2019 James Peach
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
    $1) return true ;;
    *) return false ;;
    esac
}

linkit()
{
    if ln::is_gnu || os::is "Linux" ; then
        # -n treat LINK_NAME  as a normal file if it
        #    is a symbolic link to a directory
        ln -snfv $1 $2
    elif os::is "Darwin"; then
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
    linkit $VIMRC ~/.vim

    linkit $VIMRC/aliases ~/.aliases
    linkit $VIMRC/bashrc ~/.bashrc

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

# Update vim-plug.
curl --silent --fail --location --create-dirs \
    --output ~/.vim/autoload/plug.vim \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Install some basic Fedora packages.
if command -v dnf > /dev/null ; then
    sudo dnf install -y \
        ack \
        global \
        vim-enhanced
fi

# Install macOS basics.
if brew::available ; then
    brew install \
        ack \
        bash \
        bash-completion \
        curl \
        direnv \
        fzf \
        git \
        jq \
        kubectx \
        kubernetes-cli \
        macvim \
        watch \
        rsync
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

bash::profile

# Update global git defaults
git::config push.default    simple
git::config user.name       "James Peach"
git::config user.email      jpeach@apache.org
git::config diff.noprefix   true
git::config rerere.enabled  true # https://git-scm.com/book/en/v2/Git-Tools-Rerere
git::config grep.extendedRegexp true

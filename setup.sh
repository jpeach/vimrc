#! /bin/bash
# Copyright 2010 James Peach
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

error()
{
    echo "$@"
    exit 1
}

linkit()
{
    case $(uname -s) in
    Darwin)
        # -s symbolic
        # -h don't follow target symlinks
        # -f overwrite target
        # -v verbose
        ln -shfv $1 $2
        ;;
    Linux)
        # -n treat LINK_NAME  as a normal file if it
        #    is a symbolic link to a directory
        ln -snfv $1 $2
        ;;
    *)
        ln -sfv $1 $2
        ;;
    esac
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
    [[ -d ~/.vim ]] && mv ~/.vim ~/.vim.old

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

# Install some basic Fedora packages.
if command -v dnf > /dev/null ; then
    sudo dnf install -y \
        ack \
        global \
        vim-enhanced
fi

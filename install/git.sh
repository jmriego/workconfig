#!/usr/bin/env bash
cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1
cd ..
DIR="$PWD"

sudo apt update
sudo apt install git

function update_gitconfig {

echo Updating Git config...

cat << EOF >> ~/.gitconfig
[include]
    path = ~/workconfig/git/_gitconfig

[core]
    excludesfile = ~/workconfig/git/_gitignore_global
EOF

}

grep workconfig ~/.gitconfig || update_gitconfig

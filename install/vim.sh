#!/usr/bin/env bash
cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1
cd ..
DIR="$PWD"

sudo apt update
sudo apt install vim-gtk3
git clone https://github.com/k-takata/minpac.git %USERPROFILE%\vimfiles\pack\minpac\opt\minpac
curl -sL install-node.vercel.app/lts | bash

ln -s "$DIR/_vimrc" "$HOME/.vimrc"

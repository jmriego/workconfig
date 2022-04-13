#!/usr/bin/env bash
cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1
cd ..
DIR="$PWD"

sudo apt update
sudo apt install xterm zsh tmux tmuxinator silversearcher-ag

ln -s "$DIR/_Xresources" "$HOME/.Xresources"
wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/UbuntuMono.zip" -O /tmp/UbuntuMono.zip
mkdir -p ~/.fonts
unzip /tmp/UbuntuMono.zip -d ~/.fonts

chsh -s /usr/bin/zsh

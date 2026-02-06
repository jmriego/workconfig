#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

command_exists() {
    local command="$1"
    type "$command" >/dev/null 2>&1
}

# installing reattach-to-user-namespace is recommended on OS X
if $DIR/is-nested.sh; then
    printf "\033]52;c;$(base64 | tr -d '\r\n')\a"
elif command_exists "pbcopy"; then
    if command_exists "reattach-to-user-namespace"; then
        reattach-to-user-namespace pbcopy
    else
        pbcopy
    fi
elif command_exists "xsel"; then
    xsel -i --clipboard
elif command_exists "xclip"; then
    xclip -selection clipboard
elif command_exists "putclip"; then # cygwin clipboard command
    putclip
elif command_exists "clip.exe"; then # WSL clipboard command
    clip.exe
fi

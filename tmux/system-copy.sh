#!/usr/bin/env bash

command_exists() {
    local command="$1"
    type "$command" >/dev/null 2>&1
}

# installing reattach-to-user-namespace is recommended on OS X
if command_exists "pbcopy"; then
    if command_exists "reattach-to-user-namespace"; then
        reattach-to-user-namespace pbcopy
    else
        pbcopy
    fi
elif command_exists "clip.exe"; then # WSL clipboard command
    clip.exe
elif command_exists "xsel"; then
    xsel -i --clipboard
elif command_exists "xclip"; then
    xclip -selection clipboard
elif command_exists "putclip"; then # cygwin clipboard command
    putclip
fi

#!/usr/bin/env bash

command_exists() {
    local command="$1"
    type "$command" >/dev/null 2>&1
}

paste() {
    # installing reattach-to-user-namespace is recommended on OS X
    if command_exists "pbpaste"; then
        if command_exists "reattach-to-user-namespace"; then
            reattach-to-user-namespace pbpaste
        else
            pbpaste
        fi
    elif command_exists "xsel"; then
        xsel --clipboard
    elif command_exists "xclip"; then
        xclip -out -selection clipboard
    elif command_exists "getclip"; then # cygwin clipboard command
        getclip
    elif command_exists "powershell.exe"; then # cygwin clipboard command
        powershell.exe -Command get-clipboard | sed 's/\r//g' | perl -pi -e 'chomp if eof'
    fi
}

paste | tmux load-buffer -b clipboard - && tmux paste-buffer -b clipboard

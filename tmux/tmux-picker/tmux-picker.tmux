#!/usr/bin/env bash

#
# HELPERS
#

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMUX_PRINTER="$CURRENT_DIR/tmux-printer/tmux-printer"

function set_tmux_env() {
    local option_name="$1"
    local final_value="$2"

    tmux setenv -g "$option_name" "$final_value"
}

function process_format () {
    echo -ne "$($TMUX_PRINTER "$1")"
}

function array_join() {
    local IFS="$1"; shift; echo "$*";
}

#
# CONFIG
#

set_tmux_env PICKER_COPY_COMMAND "$TMUX_CONF_DIR/system-copy.sh; $TMUX_CONF_DIR/system-paste.sh"
# open vim in a split
# set_tmux_env PICKER_COPY_COMMAND_UPPERCASE "bash -c 'arg=\$(cat -); tmux split-window -h -c \"#{pane_current_path}\" vim \"\$arg\"'"
set_tmux_env PICKER_COPY_COMMAND_UPPERCASE "$TMUX_CONF_DIR/system-open.sh"

#set_tmux_env PICKER_HINT_FORMAT $(process_format "#[fg=color0,bg=color202,dim,bold]%s")
set_tmux_env PICKER_HINT_FORMAT $(process_format "#[fg=black,bg=red,bold]%s")
set_tmux_env PICKER_HINT_FORMAT_NOCOLOR "%s"

#set_tmux_env PICKER_HIGHLIGHT_FORMAT $(process_format "#[fg=black,bg=color227,normal]%s")
set_tmux_env PICKER_HIGHLIGHT_FORMAT $(process_format "#[fg=black,bg=yellow,bold]%s")

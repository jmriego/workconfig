#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pattern_file=$CURRENT_DIR/patterns/$1.pattern

function set_tmux_env() {
    local option_name="$1"
    local final_value="$2"

    tmux setenv -g "$option_name" "$final_value"
}

function array_join() {
    local IFS="$1"; shift; echo "$*";
}

current_pane_path="$(tmux display-message -p "#{pane_current_path}")"

# in copy mode only copy selected text
# in normal mode copy it to a buffer, system clipboard and paste
if [[ -n "$(tmux display-message -p "#{scroll_position}")" ]]; then
    set_tmux_env PICKER_COPY_COMMAND "tmux load-buffer -; tmux send-keys -X cancel"
    set_tmux_env PICKER_COPY_COMMAND_UPPERCASE "$TMUX_CONF_DIR/system-open.sh; tmux send-keys -X cancel"
else
    set_tmux_env PICKER_COPY_COMMAND "$TMUX_CONF_DIR/system-copy.sh; $TMUX_CONF_DIR/system-paste.sh"
    set_tmux_env PICKER_COPY_COMMAND_UPPERCASE "$TMUX_CONF_DIR/system-open.sh"
fi


source $pattern_file
set_tmux_env PICKER_PATTERNS1 $(array_join "|" "${PATTERNS_LIST1[@]}")
set_tmux_env PICKER_PATTERNS2 $(array_join "|" "${PATTERNS_LIST2[@]}")
set_tmux_env PICKER_BLACKLIST_PATTERNS $(array_join "|" "${BLACKLIST[@]}")
$CURRENT_DIR/tmux-picker.sh

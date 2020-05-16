[ "$(hostname -s)" != "$(tmux display-message -p "#T" | cut -d : -f 1 -s)" ] &&
[ "tmux" = "$(tmux display-message -p "#T" | cut -d : -f 3 -s)" ]

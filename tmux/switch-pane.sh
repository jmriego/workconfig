direction=$1
outer=$2
if [ "$direction" = "up" ]
then
  keys="C-k"
  pane="-U"
elif [ "$direction" = "down" ]
then
  keys="C-j"
  pane="-D"
elif [ "$direction" = "left" ]
then
  keys="C-h"
  pane="-L"
elif [ "$direction" = "right" ]
then
  keys="C-l"
  pane="-R"
elif [ "$direction" = "last" ]
then
  keys="C-\\"
  pane="-l"
fi

is_vim() {
  tmux display-message -p '#{pane_current_command}' | grep -iqE '(^|\/)vim?$'
}
 
 
if [ $outer = "outer" ]
then
  tmux select-pane "$pane"
elif $TMUX_CONF_DIR/is-nested.sh
then
  tmux send-keys "$keys"
elif is_vim
then
  tmux send-keys "$keys"
else
  tmux select-pane "$pane"
fi

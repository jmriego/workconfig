#!/usr/bin/env bash

function current_session {
    tmux display-message -p "#S"
}

function num_sessions {
    tmux ls | grep -v '^todo:' | wc -l
}

if [ "$1" == "toggle-todo" ]; then

  (tmux display-message -p '#S' | grep -iqE '^todo:' && tmux switch-client -l) || tmuxinator todo

elif [ "$1" == "prev" ]; then

  if [[ $(num_sessions) -lt 2 ]]; then
      tmux new-session -d
  fi

  tmux switch-client -p
  if [[ "$(current_session)" == "todo" ]]; then
      tmux switch-client -p
  fi

else

  if [[ $(num_sessions) -lt 2 ]]; then
      tmux new-session -d
  fi

  tmux switch-client -n
  if [[ "$(current_session)" == "todo" ]]; then
      tmux switch-client -n
  fi

fi

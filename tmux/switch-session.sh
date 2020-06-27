#!/usr/bin/env bash

current_session=`tmux display-message -p "#S"`

if [ "$1" == "toggle-todo" ]; then

  (tmux display-message -p '#S' | grep -iqE '^todo$' && tmux switch-client -l) || tmuxinator todo

elif [ "$1" == "prev" ]; then

  tmux ls \
    | awk -v s="$current_session" -F: '{ls[NR]=$1} $1==s{i=NR} END {if (i==1) {print ls[NR]} else {print ls[i-1]}}' \
    | grep -q '^todo$' && tmux switch-client -p 

  tmux switch-client -p

else

  tmux ls \
    | awk -v s="$current_session" -F: '{ls[NR]=$1} $1==s{i=NR} END {if (i==NR) {print ls[1]} else {print ls[i+1]}}' \
    | grep -q '^todo$' && tmux switch-client -n

  tmux switch-client -n

fi

#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

SRC="$1"
DST="$2"

[ -z ${DST} ] && DST="$($DIR/projectionist_query.sh "$SRC/.projections.json" grsync)"

[[ "$SRC" == */ ]] || SRC="$SRC/"
[[ "$DST" == */ ]] || DST="$DST/"

# function to get the existing list of files
# in the repo that are currently ignored by git
function get_ignore {

  SRC="$1"

  # if its a remote address, ssh into it and get the list of files
  if [[ "$SRC" = *:* ]]
  then
    hostname="$(echo "$SRC" | cut -d : -f 1 -s)"
    repopath="$(echo "$SRC" | cut -d : -f 2 -s)"
    ssh "$hostname" "git -C '$repopath' ls-files --exclude-standard -oi --directory"
  else
    git -C "$SRC" ls-files --exclude-standard -oi --directory
  fi

}

rsync -r --delete \
    --include .git \
    --exclude-from=<(get_ignore) \
    "$SRC" "$DST"

#!/usr/bin/env bash
# function to do an rsync of a git repo processing the .gitignore
# the .gitignore processed will come from the first param

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# return the parameter if it's a directory or the dirname if not
function ensure_dir() {
  f="$1"

  if [[ "$f" = *:* ]]
  then
    hostname="$(echo "$f" | cut -d : -f 1 -s)"
    f="$(echo "$f" | cut -d : -f 2 -s)"
    ssh "$hostname" "bash -c '[[ -d $f ]] && echo $f || dirname $f'"
  else
    [[ -d "$f" ]] && echo "$f" || dirname "$f"
  fi
}

# function to get the existing list of files
# in the repo that are currently ignored by git
function get_ignore {
  repopath="$(ensure_dir "$1")"

  # if its a remote address, ssh into it and get the list of files
  if [[ "$1" = *:* ]]
  then
    hostname="$(echo "$1" | cut -d : -f 1 -s)"
    ssh "$hostname" "git -C '$repopath' ls-files --exclude-standard -oi --directory"
  else
    git -C "$repopath" ls-files --exclude-standard -oi --directory
  fi
}

# this function accepts either a last parameter as the target of the rsync
# or with this option, it will try to find it from the projectionist config
if [ "$1" = "--default-target" ]
then
  [[ "$1" = *:* ]] && echo "cannot use --default-target for remote repos"
  shift
  for p in "$@"
  do
    if [[ ! "$p" = -* ]]
    then
      f="$p"
      break
    fi
  done
  DST="$($DIR/projectionist_query.sh "$(ensure_dir "${f:-$PWD}")/.projections.json" grsync)"
  set -- "$@" "${DST}"
fi

rsync -r --delete \
    --exclude-from=<(get_ignore) \
    "$@"

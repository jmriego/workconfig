#!/usr/bin/env bash
# function to do an rsync of a git repo processing the .gitignore
# the .gitignore processed will come from the first param

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# function to get the existing list of files
# in the repo that are currently ignored by git
function get_ignore {
  # if its a remote address, ssh into it and get the list of files
  if [[ "$SRC" = *:* ]]
  then
    hostname="$(echo "$SRC" | cut -d : -f 1 -s)"
    repopath="$(echo "$SRC" | cut -d : -f 2 -s)"
    ssh "$hostname" "git -C '$repopath' ls-files --exclude-standard -oi --directory"
  else
    git -C "$GIT_DIR" ls-files --exclude-standard -oi --directory
    echo .git # TODO remove this
  fi
}

function get_git_dir {
  if [[ "$SRC" = *:* ]]
  then
    hostname="$(echo "$SRC" | cut -d : -f 1 -s)"
    repopath="$(echo "$SRC" | cut -d : -f 2 -s)"
    ssh "$hostname" "git -C '$repopath' rev-parse --show-toplevel"
  else
    git -C "$SRC" rev-parse --show-toplevel
  fi
}

function relative_path() {
  f="$1"

  if [[ "$f" = *:* ]]
  then
    hostname="$(echo "$f" | cut -d : -f 1 -s)"
    f="$(echo "$f" | cut -d : -f 2 -s)"
    echo "$hostname:$GIT_DIR/./$(ssh "$hostname" "realpath --relative-to='$GIT_DIR' '$f'" )"
  else
    realpath --relative-to="$GIT_DIR" "$f"
  fi
}

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

# this function accepts either a last parameter as the target of the rsync
# or with this option, it will try to find it from the projectionist config
if [ "$1" = "--default-target" ]
then
    SRC="$(ensure_dir $2)"
    DST="$($DIR/projectionist_query.sh "`get_git_dir`/.projections.json" grsync)"
    shift
else
    SRC="$(ensure_dir $1)"
    # set DST to last parameter and remove it from $@
    for DST in "$@"; do :; done
    set -- "${@:1:$(($#-1))}"
fi

GIT_DIR="$(get_git_dir)"

# loop through params and make them relative to the git repo
for param; do
  tmp=$(relative_path "$1" | tr -s "/")
  set -- "$@" "${tmp%.}"
  shift
done

[[ "$SRC" = *:* ]] || cd "$GIT_DIR"
echo pwd $PWD
echo XXXignorestart
get_ignore
echo XXXignoreend

rsync -nirR --delete \
    --exclude-from=<(get_ignore) \
    "$@" "$DST/"

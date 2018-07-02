setopt prompt_subst
autoload -U colors && colors

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '!'
zstyle ':vcs_info:*' stagedstr '+'
# zstyle ':vcs_info:*' formats '%b %S %u%c'
# PROMPT='${vcs_info_msg_0_}> '

# Echoes information about Git repository status when inside a Git repository
git_info() {

  # Exit if not inside a Git repository
  ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 && return

  # Git branch/tag, or name-rev if on detached head
  local GIT_LOCATION=${$(git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD)#(refs/heads/|tags/)}

  local MERGING="M"
  local UNTRACKED="?"
  local STAGED="+"
  local AHEAD="^"
  local BEHIND="v"

  local -a DIVERGENCES
  local -a FLAGS

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    FLAGS+=( "$MERGING" )
  fi

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    FLAGS+=( "$UNTRACKED" )
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    FLAGS+=( "$STAGED" )
  fi

  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    DIVERGENCES+=( "${AHEAD//NUM/$NUM_AHEAD}" )
  fi

  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    DIVERGENCES+=( "${BEHIND//NUM/$NUM_BEHIND}" )
  fi

  local color="green"
  if ! git diff --quiet 2> /dev/null; then
    local color="red"
  fi
  local -a GIT_INFO
  [[ ${#FLAGS[@]} -ne 0 ]] && GIT_INFO+=( "${(j::)FLAGS}" )
  [[ ${#DIVERGENCES[@]} -ne 0 ]] && GIT_INFO+=( "${(j::)DIVERGENCES}" )
  GIT_INFO+=( "$GIT_LOCATION" )
  echo "${color}:${(j: :)GIT_INFO}"
}

export VIRTUAL_ENV_DISABLE_PROMPT=1
function virtualenv_info() {
    if [ -n "$VIRTUAL_ENV" ]; then
        if [ -f "$VIRTUAL_ENV/__name__" ]; then
            local name=`cat $VIRTUAL_ENV/__name__`
        elif [ `basename $VIRTUAL_ENV` = "__" ]; then
            local name=$(basename $(dirname $VIRTUAL_ENV))
        else
            local name=$(basename $VIRTUAL_ENV)
        fi
        echo "blue:$name"
    fi
}

function get_prompt() {
  local -a prompt_sections
  
  git_info="$(git_info)"
  [[ -n "$git_info" ]] && prompt_sections+="$git_info"
  
  virtualenv_info="$(virtualenv_info)"
  [[ -n "$virtualenv_info" ]] && prompt_sections+="$virtualenv_info"
  
  local p
  local prev_col
  local col
  sep=''
  p=""
  
  for section in $prompt_sections
  do
    prev_col="${col}"
    col="${section%:*}"
    text="${section#*:}"
    if [[ -n "$p" ]]
    then
      p="${p}%{$fg[$prev_col]%}%{$bg[$col]%}${sep}%{$reset_color%}"
    fi
    p="${p}%{$bg[$col]%}${text}"
  done

  if [[ -n "$p" ]]
  then
    echo "${p}%{$reset_color%}%{$fg[$col]%}${sep}%{$reset_color%} "
  else
    echo "${sep} "
  fi
}

PS1='$(get_prompt)'

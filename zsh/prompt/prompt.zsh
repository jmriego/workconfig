my_dir="$(dirname "$0")"

DEFAULT_FG_COLOR_CHANGE="%{$fg[white]%}"

setopt prompt_subst
autoload -U colors && colors

source "$my_dir/prompt_icons.zsh"
source "$my_dir/git.zsh"
source "$my_dir/virtualenv.zsh"

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

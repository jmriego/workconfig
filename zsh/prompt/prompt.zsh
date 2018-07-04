local prompt_dir="$(dirname "$0")"

local DEFAULT_BG="black"
local DEFAULT_FG="white"

setopt prompt_subst
autoload -U colors && colors

source "$prompt_dir/prompt_icons.zsh"

local -a prompt_sections
export prompt_sections=(git virtualenv exit_code)

for section_name in $prompt_sections
do
  source "${prompt_dir}/${section_name}.zsh"
done


return_prompt_section() {
  echo "$1" #bgcolor
  echo "$2" #fgcolor
  echo "$3" #text
}


# expects a section name
# build an array with the result of calling {section}_info
# indexes 1: bg, 2: fg, 3: text
export prompt_section
build_prompt_section() {
  prompt_section=("${(@f)$(${@}_info)}")
  # return error if the prompt is empty
  [[ -n "${prompt_section[3]}" ]] || return 1
}


echo_prompt_section() {
  prompt_section=("${(@f)$(${@}_info)}")
  echo "${prompt_section[3]}"
}


function get_prompt() {
  export RETVAL=$?
  export RETVALS=( "$pipestatus[@]" )

  local prev_bgcolor fgcolor bgcolor text
  local p
  local p=""
  local sep=''

  for section_name in $prompt_sections
  do
    prev_bgcolor="${bgcolor}"
    # bgcolor="$DEFAULT_BG"
    # fgcolor="$DEFAULT_FG"

    build_prompt_section ${section_name} || continue
    bgcolor="${prompt_section[1]:-${DEFAULT_BG}}"
    fgcolor="${prompt_section[2]:-${DEFAULT_FG}}"
    text="${prompt_section[3]}"

    if [[ -n "$p" ]]
    then
      p="${p}%{$fg[$prev_bgcolor]%}%{$bg[$bgcolor]%}${sep}"
    fi
    p="${p}%{$bg[$bgcolor]%}%{$fg[$fgcolor]%}${text}"
  done

  if [[ -n "$p" ]]
  then
    echo "${p}%{$reset_color%}%{$fg[$bgcolor]%}${sep}%{$reset_color%} "
  else
    echo "${sep} "
  fi
}

PS1='$(get_prompt)'

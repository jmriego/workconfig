local prompt_dir="$(dirname "$0")"

local DEFAULT_BG="black"
local DEFAULT_FG="white"

setopt prompt_subst
autoload -U colors && colors

source "$prompt_dir/prompt_icons.zsh"

local -a prompt_sections
export prompt_sections=(git virtualenv exit_code is_root)

for section_name in $prompt_sections
do
  source "${prompt_dir}/${section_name}.zsh"
done


return_prompt_section() {
  echo "$1" #bgcolor
  echo "$2" #fgcolor
  echo "{$3:-none}" #attribute
  echo "$4" #text
}


# expects a section name
# build an array with the result of calling {section}_info
# indexes 1: bg, 2: fg, 3: attributes, 4: text
export prompt_section
build_prompt_section() {
  prompt_section=("${(@f)$(${@}_info)}")
  # return error if the prompt is empty
  [[ -n "${prompt_section[4]}" ]] || return 1
}


echo_prompt_section() {
  prompt_section=("${(@f)$(${@}_info)}")
  echo "${prompt_section[4]}"
}


function get_prompt() {
  export RETVAL=$?
  export RETVALS=( "$pipestatus[@]" )

  local prev_bgcolor fgcolor bgcolor text
  local p
  local p=""
  local sep="$PROMPT_ICON_PROMPT_SEPARATOR"

  for section_name in $prompt_sections
  do
    prev_bgcolor="${bgcolor}"
    # bgcolor="$DEFAULT_BG"
    # fgcolor="$DEFAULT_FG"

    build_prompt_section ${section_name} || continue
    bgcolor="${prompt_section[1]:-${DEFAULT_BG}}"
    fgcolor="${prompt_section[2]:-${DEFAULT_FG}}"
    attribute="${prompt_section[3]}"
    text="${prompt_section[4]}"

    if [[ -n "$p" ]]
    then
      p="${p}%{$fg[$prev_bgcolor]%}%{$bg[$bgcolor]%}${sep}"
    fi
    p="${p}%{\033[${color[$attribute]}m%}%{$bg[$bgcolor]%}%{$fg[$fgcolor]%}${text}"
  done

  if [[ -n "$p" ]]
  then
    echo -e "${p}%{$reset_color%}%{$fg[$bgcolor]%}${sep}%{$reset_color%} "
  else
    echo "${PROMPT_ICON_DEFAULT_PROMPT} "
  fi
}

PS1='$(get_prompt)'

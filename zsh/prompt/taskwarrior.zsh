#!/bin/zsh

# Echoes information about Git repository status when inside a Git repository
taskwarrior_info() {
  local -a TASK_NUMBERS

  local inbox="$(task count +in status:pending)"
  local due_today="$(task "due<=today" status:pending count) "
  local done_today="$(task "status=completed" "end=today" count)"
  local section_color="red"
  TASK_NUMBERS+=("${PROMPT_ICON_TASK_DONE}${done_today}")
  [[ $due_today -gt 0 ]] && TASK_NUMBERS+=("${PROMPT_ICON_TASK_URGENT}${due_today}")

  if [[ $inbox -gt 0 ]]
  then
    TASK_NUMBERS+=("${PROMPT_ICON_TASK_INBOX}${inbox}")
    section_color="red"
  fi

  return_prompt_section "white" "$section_color" "${(j::)TASK_NUMBERS}"
}

if [[ ! $ZSH_EVAL_CONTEXT =~ :file$ ]]
then
  if [[ $1 == "tmux" ]]
  then
    local -a TMUX_FORMAT
    [[ ! -z $1 ]] && TMUX_FORMAT+=("bg=$1")
    [[ ! -z $2 ]] && TMUX_FORMAT+=("fg=$2")

    if [[ ${#TMUX_FORMAT[@]} -gt 0 ]]
    then
      (return_prompt_section() {echo "#[${(j:,:)TMUX_FORMAT}]$3#[default]"; } && taskwarrior_info)
    else
      (return_prompt_section() {echo "$3"; } && taskwarrior_info)
    fi
  else
    (return_prompt_section() {echo "$3"; } && taskwarrior_info)
  fi
fi

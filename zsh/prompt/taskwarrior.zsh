#!/bin/zsh

# Echoes information about Git repository status when inside a Git repository
taskwarrior_info() {
  local -a TASK_NUMBERS

  local inbox="$(task count +in status:pending)"
  local due_today="$(task "due<=today" status:pending count) "
  local done_today="$(task "status=completed" "end=today" count)"
  local section_color="red"
  local attribute=""
  TASK_NUMBERS+=("${PROMPT_ICON_TASK_DONE}${done_today}")
  [[ $due_today -gt 0 ]] && TASK_NUMBERS+=("${PROMPT_ICON_TASK_URGENT}${due_today}")

  if [[ $inbox -gt 0 || $due_today -gt 0 ]]
  then
    TASK_NUMBERS+=("${PROMPT_ICON_TASK_INBOX}${inbox}")
    section_color="red"
    attribute="blink"
  fi

  return_prompt_section "white" "$section_color" "$attribute" "${(j::)TASK_NUMBERS}"
}

if [[ ! $ZSH_EVAL_CONTEXT =~ :file$ ]]
then
  if [[ $1 == "tmux" ]]
  then
    bg="$2"
    fg="$3"
    (return_prompt_section() {
        local -a TMUX_FORMAT
        [[ ! -z $bg ]] && TMUX_FORMAT+=("bg=$bg")
        # we only take the attribute from the prompt build. The colours are received as params
        [[ ! -z $3 ]] && fg="${fg},$3"
        [[ ! -z $fg ]] && TMUX_FORMAT+=("fg=$fg")
        if [[ ${#TMUX_FORMAT[@]} -gt 0 ]]
        then
            echo "#[${(j:,:)TMUX_FORMAT}]$4#[default]";
        else
            echo "$4"
        fi
    } &&
    taskwarrior_info
    )
  else
    (return_prompt_section() {echo "$4"; } && taskwarrior_info)
  fi
fi

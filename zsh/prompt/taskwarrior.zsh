#!/bin/zsh

# Echoes information about Git repository status when inside a Git repository
taskwarrior_info() {
  local -a TASK_NUMBERS

  local inbox="$(task count +in status:pending)"
  local due_today="$(task due=today status:pending count) "
  local done_today="$(task end:today status:completed count)"
  TASK_NUMBERS+=("${PROMPT_ICON_TASK_DONE}${done_today}")
  [[ $due_today -gt 0 ]] && TASK_NUMBERS+=("${PROMPT_ICON_TASK_URGENT}${due_today}")
  [[ $inbox -gt 0 ]] && TASK_NUMBERS+=("${PROMPT_ICON_TASK_INBOX}${inbox}")

  return_prompt_section "white" "" "${(j::)TASK_NUMBERS}"
}

[[ $ZSH_EVAL_CONTEXT =~ :file$ ]] || (return_prompt_section() {echo "$3"; } && taskwarrior_info)

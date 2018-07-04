exit_code_info() {
  local exit_code="${RETVAL}"
  [[ -z $exit_code || $exit_code == 0 ]] && return
  return_prompt_section "red" "white" "${PROMPT_ICON_ERROR}${exit_code}"
}

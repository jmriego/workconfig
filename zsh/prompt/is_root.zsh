is_root_info() {
  [[ $(print -P "%#") == '#' ]] || return
  return_prompt_section "red" "yellow" "$PROMPT_ICON_ROOT"
}

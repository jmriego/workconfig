is_root_info() {
  [[ $(print -P "%#") == '#' ]] || return
  return_prompt_section "red" "" "" "$PROMPT_ICON_ROOT"
}

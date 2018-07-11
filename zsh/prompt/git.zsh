autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*:*' stagedstr "$PROMPT_ICON_GIT_STAGED"
zstyle ':vcs_info:git*' formats "%b%c" "%u"
zstyle ':vcs_info:git*' actionformats "%b%c" "%u" "%a"

(( ${precmd_functions[(I)vcs_info]} )) || precmd_functions+=(vcs_info)

# Echoes information about Git repository status when inside a Git repository
git_info() {

  # Exit if not inside a Git repository
  [[ -z $vcs_info_msg_0_ ]] && return

  local -a GIT_INFO
  GIT_INFO+=("${PROMPT_ICON_GIT_BRANCH}")
  GIT_INFO+=("${vcs_info_msg_0_}")

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    GIT_INFO+=("$PROMPT_ICON_GIT_UNTRACKED")
  fi

  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    GIT_INFO+=( "${PROMPT_ICON_GIT_AHEAD//NUM/$NUM_AHEAD}" )
  fi

  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    GIT_INFO+=( "${PROMPT_ICON_GIT_BEHIND//NUM/$NUM_BEHIND}" )
  fi

  local bgcolor="green"
  [[ -n $vcs_info_msg_1_ ]] && bgcolor="yellow"

  GIT_INFO+=("${vcs_info_msg_2_/merge/${PROMPT_ICON_GIT_MERGING}}")
  return_prompt_section "$bgcolor" "" "${(j::)GIT_INFO}"
}

# Echoes information about Git repository status when inside a Git repository
git_info() {

  # Exit if not inside a Git repository
  ! git rev-parse --is-inside-work-tree > /dev/null 2>&1 && return

  # Git branch/tag, or name-rev if on detached head
  local GIT_LOCATION=${$(git symbolic-ref -q HEAD || git name-rev --name-only --no-undefined --always HEAD)#(refs/heads/|tags/)}

  local -a DIVERGENCES
  local -a FLAGS

  local GIT_DIR="$(git rev-parse --git-dir 2> /dev/null)"
  if [ -n $GIT_DIR ] && test -r $GIT_DIR/MERGE_HEAD; then
    FLAGS+=( "$PROMPT_ICON_GIT_MERGING" )
  fi

  if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
    FLAGS+=( "$PROMPT_ICON_GIT_UNTRACKED" )
  fi

  if ! git diff --cached --quiet 2> /dev/null; then
    FLAGS+=( "$PROMPT_ICON_GIT_STAGED" )
  fi

  local NUM_AHEAD="$(git log --oneline @{u}.. 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_AHEAD" -gt 0 ]; then
    DIVERGENCES+=( "${PROMPT_ICON_GIT_AHEAD//NUM/$NUM_AHEAD}" )
  fi

  local NUM_BEHIND="$(git log --oneline ..@{u} 2> /dev/null | wc -l | tr -d ' ')"
  if [ "$NUM_BEHIND" -gt 0 ]; then
    DIVERGENCES+=( "${PROMPT_ICON_GIT_BEHIND//NUM/$NUM_BEHIND}" )
  fi

  local bgcolor="green"
  if ! git diff --quiet 2> /dev/null; then
    bgcolor="yellow"
  fi

  local -a GIT_INFO
  GIT_INFO+=( "${PROMPT_ICON_GIT_BRANCH}${GIT_LOCATION} " )
  [[ ${#FLAGS[@]} -ne 0 ]] && GIT_INFO+=( "${(j::)FLAGS}" )
  [[ ${#DIVERGENCES[@]} -ne 0 ]] && GIT_INFO+=( "${(j::)DIVERGENCES}" )
  return_prompt_section "$bgcolor" "" "${(j::)GIT_INFO}"
}

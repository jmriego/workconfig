# Echoes information about Git repository status when inside a Git repository
git2_info() {

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

  if [ -n $vcs_info_msg_2_ ]; then
    local action="${vcs_info_msg_2_/merge/${PROMPT_ICON_GIT_MERGING}}"
    local action="${action/rebase-i/${PROMPT_ICON_GIT_MERGING}}"
    local action="${action/rebase/${PROMPT_ICON_GIT_MERGING}}"
    GIT_INFO+=("$action")
  fi

  return_prompt_section "$bgcolor" "" "${(j::)GIT_INFO}"
}

source ~/.zsh-async/async.zsh
# Initialize zsh-async
async_init
# Start a worker that will report job completion
async_start_worker git_prompt_worker -n
# Wrap git status in a function, so we can pass in the working directory
git_status() {
  autoload -Uz vcs_info
  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' check-for-changes true
  zstyle ':vcs_info:*:*' stagedstr "$PROMPT_ICON_GIT_STAGED"
  zstyle ':vcs_info:*' max-exports 3
  zstyle ':vcs_info:git*' formats "%b%c" "%u"
  zstyle ':vcs_info:git*' actionformats "%b%c" "%u" "%a"
  (( ${precmd_functions[(I)vcs_info]} )) || precmd_functions+=(vcs_info)
  cd "$1"
  git2_info
}

# Define a function to process the result of the job
completed_callback() {
  local output=$@
  H_PROMPT_GIT="${output}"
  async_job git_prompt_worker git_status $(pwd)
}

# Register our callback function to run when the job completes
async_register_callback git_prompt_worker completed_callback
# Start the job
async_job git_prompt_worker git_status $(pwd)


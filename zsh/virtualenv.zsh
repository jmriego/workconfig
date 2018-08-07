function workon_cwd {
  if [[ -z "$WORKON_CWD" ]]; then
    local WORKON_CWD=1
    # Check if this is a Git repo
    local GIT_REPO_ROOT=""
    local GIT_TOPLEVEL="$(git rev-parse --show-toplevel 2> /dev/null)"
    if [[ $? == 0 ]]; then
      GIT_REPO_ROOT="$GIT_TOPLEVEL"
    fi
    # Get absolute path, resolving symlinks
    local PROJECT_ROOT="${PWD:A}"
    while [[ "$PROJECT_ROOT" != "/" && ! -e "$PROJECT_ROOT/.venv" \
             && ! -d "$PROJECT_ROOT/.git"  && "$PROJECT_ROOT" != "$GIT_REPO_ROOT" ]]; do
      PROJECT_ROOT="${PROJECT_ROOT:h}"
    done
    if [[ "$PROJECT_ROOT" == "/" ]]; then
      PROJECT_ROOT="."
    fi
    # Check for virtualenv name override
    if [[ -f "$PROJECT_ROOT/.venv" ]]; then
      ENV_NAME="$(cat "$PROJECT_ROOT/.venv")"
    elif [[ -f "$PROJECT_ROOT/.venv/bin/activate" ]];then
      ENV_NAME="$PROJECT_ROOT/.venv"
    elif [[ "$PROJECT_ROOT" != "." ]]; then
      ENV_NAME="${PROJECT_ROOT:t}"
    else
      ENV_NAME=""
    fi
    if [[ "$ENV_NAME" != "" ]]; then
      # Activate the environment only if it is not already active
      if [[ "$VIRTUAL_ENV" != "$WORKON_HOME/$ENV_NAME" ]]; then
        if [[ -e "$WORKON_HOME/$ENV_NAME/bin/activate" ]]; then
          workon "$ENV_NAME" && export CD_VIRTUAL_ENV="$ENV_NAME"
        elif [[ -e "$ENV_NAME/bin/activate" ]]; then
          source $ENV_NAME/bin/activate && export CD_VIRTUAL_ENV="$ENV_NAME"
        fi
      fi
    elif [[ -n $CD_VIRTUAL_ENV && -n $VIRTUAL_ENV ]]; then
      # We've just left the repo, deactivate the environment
      # Note: this only happens if the virtualenv was activated automatically
      deactivate && unset CD_VIRTUAL_ENV
    fi
  fi
}

if ! (( $chpwd_functions[(I)workon_cwd] )); then
  chpwd_functions+=(workon_cwd)
fi
workon_cwd

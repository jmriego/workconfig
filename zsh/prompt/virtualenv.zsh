export VIRTUAL_ENV_DISABLE_PROMPT=1
function virtualenv_info() {
  if [ -n "$VIRTUAL_ENV" ]; then

    if [ -f "$VIRTUAL_ENV/__name__" ]; then
      local name=`cat $VIRTUAL_ENV/__name__`
    elif [ `basename $VIRTUAL_ENV` = "__" ]; then
      local name=$(basename $(dirname $VIRTUAL_ENV))
    else
      local name=$(basename $VIRTUAL_ENV)
    fi

    if [[ "$(which python)" =~ "$VIRTUAL_ENV" ]]; then
      # we have changed the default python
      local icon="${PROMPT_ICON_PYTHON}"
    else
      local icon="${PROMPT_ICON_CONSOLE}"
    fi

    return_prompt_section "blue" "" "" "${icon}${name}"
  fi
}

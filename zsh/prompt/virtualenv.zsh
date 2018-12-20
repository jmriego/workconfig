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

    return_prompt_section "blue" "" "" "${PROMPT_ICON_PYTHON}${name}"
  fi
}

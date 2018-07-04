# export POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
export POWERLEVEL9K_DIR_PATH_SEPARATOR="/"
export POWERLEVEL9K_HOME_FOLDER_ABBREVIATION="~"
export POWERLEVEL9K_DIR_SHOW_WRITABLE=false
export POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
export SED_EXTENDED_REGEX_PARAMETER="-E"
# export POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER=true

dir_info() {
  local tmp="$IFS"
  local IFS=""
  local current_path=$(pwd | sed -e "s,^$HOME,~,")
  local IFS="$tmp"
  if [[ -n "$POWERLEVEL9K_SHORTEN_DIR_LENGTH" || "$POWERLEVEL9K_SHORTEN_STRATEGY" == "truncate_with_folder_marker" ]]; then
    export POWERLEVEL9K_SHORTEN_DELIMITER=$'\U2026'

    case "$POWERLEVEL9K_SHORTEN_STRATEGY" in
      truncate_middle)
        current_path=$(pwd | sed -e "s,^$HOME,~," | sed $SED_EXTENDED_REGEX_PARAMETER "s/([^/]{$POWERLEVEL9K_SHORTEN_DIR_LENGTH})[^/]+([^/]{$POWERLEVEL9K_SHORTEN_DIR_LENGTH})\//\1$POWERLEVEL9K_SHORTEN_DELIMITER\2\//g")
      ;;
      truncate_from_right)
        current_path=$(truncatePathFromRight "$(pwd | sed -e "s,^$HOME,~,")" )
      ;;
      truncate_with_package_name)
        local name repo_path package_path current_dir zero

        # Get the path of the Git repo, which should have the package.json file
        if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == "true" ]]; then
          # Get path from the root of the git repository to the current dir
          local gitPath=$(git rev-parse --show-prefix)
          # Remove trailing slash from git path, so that we can
          # remove that git path from the pwd.
          gitPath=${gitPath%/}
          package_path=${$(pwd)%%$gitPath}
          # Remove trailing slash
          package_path=${package_path%/}
        elif [[ $(git rev-parse --is-inside-git-dir 2> /dev/null) == "true" ]]; then
          package_path=${$(pwd)%%/.git*}
        fi

        # Replace the shortest possible match of the marked folder from
        # the current path. Remove the amount of characters up to the
        # folder marker from the left. Count only the visible characters
        # in the path (this is done by the "zero" pattern; see
        # http://stackoverflow.com/a/40855342/5586433).
        local zero='%([BSUbfksu]|([FB]|){*})'
        current_dir=$(pwd)
        # Then, find the length of the package_path string, and save the
        # subdirectory path as a substring of the current directory's path from 0
        # to the length of the package path's string
        subdirectory_path=$(truncatePathFromRight "${current_dir:${#${(S%%)package_path//$~zero/}}}")
        # Parse the 'name' from the package.json; if there are any problems, just
        # print the file path
        defined POWERLEVEL9K_DIR_PACKAGE_FILES || POWERLEVEL9K_DIR_PACKAGE_FILES=(package.json composer.json)

        local pkgFile="unknown"
        for file in "${POWERLEVEL9K_DIR_PACKAGE_FILES[@]}"; do
          if [[ -f "${package_path}/${file}" ]]; then
            pkgFile="${package_path}/${file}"
            break;
          fi
        done

        local packageName=$(jq '.name' ${pkgFile} 2> /dev/null \
          || node -e 'console.log(require(process.argv[1]).name);' ${pkgFile} 2>/dev/null \
          || cat "${pkgFile}" 2> /dev/null | grep -m 1 "\"name\"" | awk -F ':' '{print $2}' | awk -F '"' '{print $2}' 2>/dev/null \
          )
        if [[ -n "${packageName}" ]]; then
          # Instead of printing out the full path, print out the name of the package
          # from the package.json and append the current subdirectory
          current_path="`echo $packageName | tr -d '"'`$subdirectory_path"
        else
          current_path=$(truncatePathFromRight "$(pwd | sed -e "s,^$HOME,~,")" )
        fi
      ;;
      truncate_with_folder_marker)
        local last_marked_folder marked_folder
        export POWERLEVEL9K_SHORTEN_FOLDER_MARKER=".shorten_folder_marker"

        # Search for the folder marker in the parent directories and
        # buildup a pattern that is removed from the current path
        # later on.
        for marked_folder in $(upsearch $POWERLEVEL9K_SHORTEN_FOLDER_MARKER); do
          if [[ "$marked_folder" == "/" ]]; then
            # If we reached root folder, stop upsearch.
            current_path="/"
          elif [[ "$marked_folder" == "$HOME" ]]; then
            # If we reached home folder, stop upsearch.
            current_path="~"
          elif [[ "${marked_folder%/*}" == $last_marked_folder ]]; then
            current_path="${current_path%/}/${marked_folder##*/}"
          else
            current_path="${current_path%/}/$POWERLEVEL9K_SHORTEN_DELIMITER/${marked_folder##*/}"
          fi
          last_marked_folder=$marked_folder
        done

        # Replace the shortest possible match of the marked folder from
        # the current path.
        current_path=$current_path${PWD#${last_marked_folder}*}
      ;;
      truncate_to_unique)
        # for each parent path component find the shortest unique beginning
        # characters sequence. Source: https://stackoverflow.com/a/45336078
        paths=(${(s:/:)PWD})
        cur_path='/'
        cur_short_path='/'
        for directory in ${paths[@]}
        do
          cur_dir=''
          for (( i=0; i<${#directory}; i++ )); do
            cur_dir+="${directory:$i:1}"
            matching=("$cur_path"/"$cur_dir"*/)
            if [[ ${#matching[@]} -eq 1 ]]; then
              break
            fi
          done
          cur_short_path+="$cur_dir/"
          cur_path+="$directory/"
        done
        current_path="${cur_short_path: : -1}"
      ;;
      *)
        if [[ $current_path != "~" ]]; then
          current_path="$(print -P "%$((POWERLEVEL9K_SHORTEN_DIR_LENGTH+1))(c:$POWERLEVEL9K_SHORTEN_DELIMITER/:)%${POWERLEVEL9K_SHORTEN_DIR_LENGTH}c")"
        fi
      ;;
    esac
  fi

  if [[ "${POWERLEVEL9K_DIR_OMIT_FIRST_CHARACTER}" == "true" ]]; then
    current_path="${current_path[2,-1]}"
  fi

  if [[ "${POWERLEVEL9K_DIR_PATH_SEPARATOR}" != "/" ]]; then
    current_path="$( echo "${current_path}" | sed "s/\//${POWERLEVEL9K_DIR_PATH_SEPARATOR}/g")"
  fi

  if [[ "${POWERLEVEL9K_HOME_FOLDER_ABBREVIATION}" != "~" ]]; then
    current_path=${current_path/#\~/${POWERLEVEL9K_HOME_FOLDER_ABBREVIATION}}
  fi

  typeset -AH dir_states
  dir_states=(
    "DEFAULT"         "$PROMPT_ICON_FOLDER"
    "HOME"            "$PROMPT_ICON_HOME"
    "HOME_SUBFOLDER"  "$PROMPT_ICON_HOME_SUB"
    "NOT_WRITABLE"    "$PROMPT_ICON_NOT_WRITABLE"
  )
  local current_state="DEFAULT"
  if [[ "${POWERLEVEL9K_DIR_SHOW_WRITABLE}" == true && ! -w "$PWD" ]]; then
    current_state="NOT_WRITABLE"
  elif [[ $(print -P "%~") == '~' ]]; then
    current_state="HOME"
  elif [[ $(print -P "%~") == '~'* ]]; then
    current_state="HOME_SUBFOLDER"
  fi
  return_prompt_section "white" "black" "${dir_states[$current_state]}$current_path"
}

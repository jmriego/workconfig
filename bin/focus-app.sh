#!/usr/bin/env bash

function focus_windows {
  found_windows="$(xdotool search --onlyvisible "$@")"
  xdotool windowactivate "$(echo "$found_windows" | tail -1)"
}

function go_to_app {

  app="$1"
  case "$app" in

    calendar)
      focus_windows --classname "www.google.com__calendar_render" || google-chrome-stable --app="https://www.google.com/calendar/render"
      ;;

    dbeaver)
      focus_windows --classname "DBeaver" || /usr/bin/flatpak run --branch=stable --arch=x86_64 --command=/app/dbeaver/dbeaver io.dbeaver.DBeaverCommunity
      ;;

    firefox)
      focus_windows --name "Mozilla Firefox" || firefox
      ;;

    gmail)
      focus_windows --classname "mail.google.com" || google-chrome-stable --app="https://mail.google.com"
      ;;

    google-chrome)
      focus_windows --classname "google-chrome" || google-chrome-stable
      ;;

    keepassxc)
      focus_windows --classname "KeePassXC" || keepassxc
      ;;

    obsidian)
      focus_windows --classname "obsidian" || obsidian
      ;;

    slack)
      focus_windows --classname "Slack" || slack
      ;;

    spotify)
      focus_windows --class "Spotify" || spotify
      ;;

    terminal)
      focus_windows --class "XTerm" || xterm
      ;;

    zoom)
      focus_windows --class "zoom" || zoom
      ;;

    *)
      return 1
      ;;

  esac

}

go_to_app "$1"

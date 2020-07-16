#!/usr/bin/env bash
app="https://mail.google.com"
classname="mail.google.com"
xdotool search --classname "$classname" >/dev/null || google-chrome-stable --app="$app"

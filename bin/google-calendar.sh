#!/usr/bin/env bash
app="https://www.google.com/calendar/render"
classname="www.google.com__calendar_render"
xdotool search --classname "$classname" >/dev/null || google-chrome-stable --app="$app"

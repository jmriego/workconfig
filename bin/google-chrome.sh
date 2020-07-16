#!/usr/bin/env bash
classname="Google-chrome"
xdotool search --classname "$classname" >/dev/null || google-chrome-stable

require('hammerspoon.utils')
require('hammerspoon.spaces')
require('hammerspoon.events')
require('hammerspoon.interact')
require('hammerspoon.windows')
require('hammerspoon.notifications')

-- special tasks needed after switching to certain apps

-- click on the lower bottom corner off the Gmail window to focus and allow hotkeys
function after_gmail()
    gmail_frame = hs.window.focusedWindow():frame()
    point_click = {x=gmail_frame["x"]+15.0, y=gmail_frame["y"]+gmail_frame["h"]-15.0}
    mouseClick("left", point_click)
end

-- go to tab with Jira or open a new one
function after_jira()
    hs.execute('/usr/local/bin/chrome-cli activate -t $(/usr/local/bin/chrome-cli list links | grep "filter=50263" | grep -o "[0-9][0-9]*\\]" | head -1) || /usr/local/bin/chrome-cli open "https://bugs.indeed.com/issues/?filter=50263"')
end

-- keyboard keys to be used in mission control and the program/window to open
-- the name of the app should be the names found in Applications folder
key_params = {
    ["i"] = "Google Chrome";
    ["j"] = {["app"] = "Google Chrome", ["after"]=after_jira};
    ["h"] = "YakYak";
    ["c"] = "Google Calendar";
    ["g"] = {["app"] = "Gmail", ["after"]=after_gmail};
    ["n"] = "Notes";
    ["e"] = "TextEdit";
    ["f"] = "Finder";
    ["t"] = "iTerm2";
    ["p"] = "Preview";
    ["x"] = "Microsoft Excel";
    ["w"] = "Microsoft Word";
    ["m"] = "Oracle Data Modeler";
    ["d"] = "DBeaver";
    ["k"] = "Slack";
    ["r"] = "iBooks";
    ["s"] = "Spotify"
}
assign_modal_hotkeys(key_params)

-- Window Management
-- move window to left half of current screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Left", function()
    split_window_left()
end)

-- move window to right half of current screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Right", function()
    split_window_right()
end)

-- make window take the entire screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Up", function()
    maximize_window()
end)

-- make window take the entire screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Return", function()
    fullscreen_window()
end)


-- ---------------
-- bind shortcuts
-- ---------------

-- Music control
hs.hotkey.bind({"cmd"}, "pagedown", function() hs.spotify.next() end)
hs.hotkey.bind({"cmd"}, "pageup", function() hs.spotify.previous() end)

-- Switch to Google Chrome and press ctrl+. for Tabli
hs.hotkey.bind({'cmd'}, '.', function()
    launchOrFocus("Google Chrome")
    hs.eventtap.keyStroke({'ctrl'}, ".")
end)

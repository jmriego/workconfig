require('hammerspoon.utils')
require('hammerspoon.events')
require('hammerspoon.interact')
require('hammerspoon.windows')
require('hammerspoon.notifications')

-- special tasks needed after switching to certain apps

-- go to tab with Jira or open a new one
function after_jira()
    local cmd = [[ set searchString to "SDP/boards/11163"

                   tell application "Google Chrome"
                       set win_List to every window
                       set win_num to 0

                       repeat with win in win_List
                           set win_num to win_num + 1
                           set tab_list to every tab of win
                           set tab_num to 0

                           repeat with t in tab_list
                               set tab_num to tab_num + 1

                               if searchString is in (URL of t as string) then
                                   tell application "System Events" to tell process "Google Chrome"
                                       perform action "AXRaise" of window win_num
                                       set frontmost to true
                                   end tell
                                   set active tab index of front window to tab_num
                               end if
                           end repeat
                       end repeat
                   end tell ]]
    hs.osascript.applescript(cmd)

end

-- keyboard keys to be used in mission control and the program/window to open
-- the name of the app should be the names found in Applications folder
key_params = {
    ["b"] = "Google Chrome";
    ["p"] = {["app"] = "Google Chrome", ["after"]=after_jira};
    ["c"] = "Google Calendar";
    ["g"] = "Gmail";
    ["t"] = "Obsidian";
    ["f"] = "Firefox";
    ["space"] = "iTerm";
    ["s"] = "Slack";
    ["m"] = "Spotify"
}
assign_app_hotkeys(key_params)


-- Window Management
-- move window to left half of current screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Left", nil, function()
    split_window_left()
end)

-- move window to right half of current screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Right", nil, function()
    split_window_right()
end)

-- make window take the entire screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Up", nil, function()
    maximize_window()
end)

-- make window take the entire screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Return", nil, function()
    fullscreen_window()
end)

hs.hotkey.bind({"cmd", "alt"}, "h", nil, function()
    hs.window.focusedWindow():focusWindowWest()
end)

hs.hotkey.bind({"cmd", "alt"}, "j", nil, function()
    hs.window.focusedWindow():focusWindowSouth()
end)

hs.hotkey.bind({"cmd", "alt"}, "k", nil, function()
    hs.window.focusedWindow():focusWindowNorth()
end)

hs.hotkey.bind({"cmd", "alt"}, "l", nil, function()
    hs.window.focusedWindow():focusWindowEast()
end)

require('hammerspoon.utils')
require('hammerspoon.events')
require('hammerspoon.interact')
require('hammerspoon.windows')
require('hammerspoon.notifications')
local chrome = require('hammerspoon.chrome')

-- special tasks needed after switching to certain apps

-- go to tab with Jira or open a new one
function after_jira()
  chrome.switch_tab("SDP.boards.11163")
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

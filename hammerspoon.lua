local shortcuts = require('hammerspoon.shortcuts')
local notifications = require('hammerspoon.notifications')
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
    ["x"] = "KeepassXC";
    ["m"] = "Spotify"
}
shortcuts.assign_app_shortcuts(key_params)


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

-- Notifications
-- open -g "hammerspoon://show_notification?title=Pay Attenttion&text=I just finished this long proccess"
-- the title and text are optional parameters
hs.urlevent.bind("show_notification",
                 function(eventName, params)
                   notifications.send_notification(params["title"], params["text"])
                  end
                   )

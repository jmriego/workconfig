mission_control = nil
--detect when mission control is opening with just a short countdown
e = nil
t = nil
point_click = nil -- point in current screen to click on
app = nil


-- keyboard keys to be used in mission control and the program/window to open
-- the name of the app should be the names found in Applications folder
key_params = {
    -- ["g"] = {"Google Chrome", "Google Hangouts", false};
    -- ["h"] = {"Google Chrome", "Google Hangouts", true};
    ["i"] = "Google Chrome";
    ["j"] = "Google Chrome"; -- actually it will go to the jira tab or open it
    ["h"] = "YakYak";
    ["c"] = "Google Calendar";
    ["g"] = "Gmail";
    ["n"] = "Notes";
    ["e"] = "TextEdit";
    ["f"] = "Finder";
    ["d"] = "Cyberduck";
    ["t"] = "iTerm";
    ["p"] = "PSequel";
    ["m"] = "Sequel Pro";
    ["x"] = "Microsoft Excel";
    ["w"] = "Microsoft Word";
    ["o"] = "Oracle Data Modeler";
    ["k"] = "Slack";
    ["s"] = "Spotify"
}


function leftClick(point)
    print(point.x .. ' , ' .. point.y)
    local clickState = hs.eventtap.event.properties.mouseEventClickState
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseDown"], point):setProperty(clickState, 1):post()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseUp"], point):setProperty(clickState, 1):post()
end

function launchOrFocus(app_win_inc)
    local found_window = nil

    if type(app_win_inc) == 'string'
    then
        app = app_win_inc
        win = ''
        inclusive = true
    else
    print(app_win_inc)
        app = app_win_inc[1]
        win = app_win_inc[2]
        inclusive = app_win_inc[3]
    end

    local app_windows = hs.window.filter.new(app)
    -- local app_main_window = hs.application.get(app):mainWindow()

    for k, window in pairs(app_windows:getWindows()) do
        local title = window:title()
        print(title)
        if title:len() > 0 and (title:find(win)==nil) ~= inclusive and found_window==nil
        then
            found_window = window
        -- found_window:becomeMain()
        found_window:application():activate(false)
        -- app_main_window:becomeMain()

        --
            -- found_window:raise()
            -- print('focus')
            -- for some reason hangouts tends to lose focus just after gaining it first
            -- hs.timer.doAfter(0.5, function() found_window:focus(); end)
        -- else
        --     window:sendToBack()
        --     print('focus')
        end
    end

    if not found_window then
        hs.application.launchOrFocus(app)
    end
end


function getCurrentWindowTitle()
    local success, title = pcall(function() return hs.uielement.focusedElement():title(); end)
    if not success
    then
       title = nil
    end
    return title
end

-- is the value in the table?
function has_value (tab, val)
--     for index, value in ipairs(tab) do
--         if value == val then
--             return true
--         end
--     end
--
--     return false
    return tab[val] ~= nil
end


-- Notifications
-- open -g "hammerspoon://show_notification?title=Pay Attenttion&text=I just finished this long proccess"
-- the title and text and optional parameters
hs.urlevent.bind("show_notification", function(eventName, params)

  if params["title"] then
    notification_title=params["title"]
  else
    notification_title="Alert"
  end

  if params["text"] then
    notification_text=params["text"]
  else
    notification_text="Alert"
  end

    hs.notify.new({title=notification_title, informativeText=notification_text}):send()
end)


-- Window Management
-- move window to left half of current screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

-- move window to right half of current screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end)

-- make window take the entire screen
hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Up", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h
  win:setFrame(f)
end)


-- This is the main code for checking the key presses while mission control is open
-- it also detects left mouse button pressed and in that key it does nothing. whatever you pressed will be proccessed normally
e = hs.eventtap.new({hs.eventtap.event.types.leftMouseDown}, function(event)
    e:stop()
    hs.timer.doAfter(0.1, function() k:exit(); end)
    return false
end)
e:stop()

-- ---------------
-- bind shortcuts
-- ---------------

-- Music control
hs.hotkey.bind({"cmd"}, "pagedown", function() hs.spotify.next() end)
hs.hotkey.bind({"cmd"}, "pageup", function() hs.spotify.previous() end)
hs.hotkey.bind({"cmd"}, "pagedown", function() hs.spotify.next() end)
hs.hotkey.bind({"cmd"}, "pageup", function() hs.spotify.previous() end)

-- Switch to Google Chrome and press ctrl+. for Tabli
hs.hotkey.bind({'cmd'}, '.', function()
    launchOrFocus("Google Chrome")
    hs.eventtap.keyStroke({'ctrl'}, ".")
end)


-- app switching
k = hs.hotkey.modal.new('', 'F20')

for index, value in pairs(key_params) do
    k:bind('', index, function()

        launchOrFocus(value)

        -- special tasks needed after switching to certain apps

        -- click on the lower bottom corner off the Gmail window to focus and allow hotkeys
        if (value == "Gmail")
        then
            -- click on the Gmail website after focusing it so that they keyboard shortcuts work
            gmail_frame = hs.window.focusedWindow():frame()
            point_click = {x=gmail_frame["x"]+15.0, y=gmail_frame["y"]+gmail_frame["h"]-15.0}
        end

        -- go to tab with Jira or open a new one
        if (index == "j")
        then
            hs.execute('/usr/local/bin/chrome-cli activate -t $(/usr/local/bin/chrome-cli list links | grep "filter=50263" | grep -o "[0-9][0-9]*" | head -1) || /usr/local/bin/chrome-cli open "https://bugs.indeed.com/issues/?filter=50263"')
        end

        k:exit()
    end)
end

k:bind('', 'escape', function() k:exit(); hs.eventtap.keyStroke({}, "escape") end)
-- k:bind({'ctrl'}, 'down', function() k:exit() end)


function k:entered()
    app = nil
    mission_control = hs.task.new("/Applications/Mission Control.app/Contents/MacOS/Mission Control", nil)
    mission_control:start() -- no key will be proccessed until this timer finishes
    e:start()
end

function k:exited()
    if app then
        hs.alert(app)
    end
    e:stop()

    hs.eventtap.keyStroke({}, "escape") -- to exit Mission Control
    if point_click ~= nil
    then
        print(point_click)
        hs.timer.doAfter(0.1, function() leftClick(point_click); point_click=nil; end)
    end
end

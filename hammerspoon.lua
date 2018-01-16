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
    ["t"] = "iTerm2";
    ["p"] = "Preview";
    ["x"] = "Microsoft Excel";
    ["w"] = "Microsoft Word";
    ["m"] = "Oracle Data Modeler";
    ["b"] = "DBeaver";
    ["k"] = "Slack";
    ["r"] = "iBooks";
    ["s"] = "Spotify"
}


function mouseClick(button, point)
    local button = button or "left"
    local point = point or hs.mouse.getAbsolutePosition()
    print(button .. '@' .. point.x .. ' , ' .. point.y)
    local clickState = hs.eventtap.event.properties.mouseEventClickState
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types[(button .. "MouseDown")], point):setProperty(clickState, 1):post()
    hs.timer.doAfter(0.1, function() hs.eventtap.event.newMouseEvent(hs.eventtap.event.types[(button .. "MouseUp")], point):setProperty(clickState, 1):post(); end)
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

    local all_windows = hs.window.filter.new(true)

    for k, window in pairs(all_windows:getWindows()) do
        if window:application():name() == app
        then
            local title = window:title()
            if title:len() > 0 and (title:find(win)==nil) ~= inclusive
            then
                found_window = window
                found_window:application():activate(false)
                hs.timer.doAfter(0, function() hs.execute('open ' .. found_window:application():path()); end)
                return
            end
        end
    end

    hs.application.launchOrFocus(app)
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
function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function index_of(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end

    return false
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

event_mm = hs.eventtap.new({hs.eventtap.event.types.otherMouseDown}, function(event)
    mouse_button_pressed = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
    if mouse_button_pressed == 2 then
        local ptMouse = hs.mouse.getAbsolutePosition()
        event_mm:stop()
        hs.timer.doAfter(0.0, function() mouseClick("middle", ptMouse); event_mm:start(); end)
    end
    return true
end)
event_mm:start()

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
            hs.execute('/usr/local/bin/chrome-cli activate -t $(/usr/local/bin/chrome-cli list links | grep "filter=50263" | grep -o "[0-9][0-9]*\\]" | head -1) || /usr/local/bin/chrome-cli open "https://bugs.indeed.com/issues/?filter=50263"')
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
        hs.timer.doAfter(0.1, function() mouseClick("left", point_click); point_click=nil; end)
    end
end

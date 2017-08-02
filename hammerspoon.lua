mission_control = nil
--detect when mission control is opening with just a short countdown
mission_control_opening = nil
mission_control_opening = hs.timer.new(0.5, function() mission_control_opening:stop(); end)
e = nil
last_event = nil
p = nil

-- detect when f20 key has been pressed but not yet released
-- f20_event_up = nil
-- f20_event_up = hs.eventtap.new({hs.eventtap.event.types.keyUp}, function(event)
--     local pressed_keycode = event:getProperty(hs.eventtap.event.properties.keyboardEventKeycode)
--     local pressed_key = hs.keycodes.map[pressed_keycode]
--     if (pressed_key == "f20")
--     then
--         f20_event_up:stop()
--     end
-- end)

-- keyboard keys to be used in mission control and the program/window to open
-- the name of the app should be the names found in Applications folder
key_params = {
    -- ["g"] = {"Google Chrome", "Google Hangouts", false};
    -- ["h"] = {"Google Chrome", "Google Hangouts", true};
    ["g"] = "Google Chrome";
    ["h"] = "YakYak";
    ["c"] = "Google Calendar";
    ["m"] = "Gmail";
    ["n"] = "Notes";
    ["f"] = "Finder";
    ["t"] = "iTerm2";
    ["p"] = "PSequel";
    ["s"] = "Sequel Pro";
    ["x"] = "Microsoft Excel";
    ["w"] = "Microsoft Word";
    ["o"] = "Oracle Data Modeler";
    ["k"] = "Slack";
    ["i"] = "iTunes";
    ["d"] = "Deezer"
}


function leftClick(point)
    print(point.x .. ' , ' .. point.y)
    local clickState = hs.eventtap.event.properties.mouseEventClickState
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseDown"], point):setProperty(clickState, 1):post()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types["leftMouseUp"], point):setProperty(clickState, 1):post()
end

-- this function accepts only one parameter: app_win_inc
-- you can pass either the name of an app. eg. Slack
-- or a table with three values: app, window title, inclusive:
--     inclusive means whether you are searching for a window with that title (true)
--     or for a window that doesn't have that title (false)
-- function launchOrFocus(app_win_inc)
--     if type(app_win_inc) == 'string'
--     then
--         hs.application.launchOrFocus(app_win_inc)
--     elseif type(app_win_inc) == 'table' then
--         app = app_win_inc[1]
--         win = app_win_inc[2]
--         inclusive = app_win_inc[3]
--         local application = hs.application.get(app)
--         if application==nil
--         then
--             hs.application.launchOrFocus(app)
--             hs.timer.doAfter(0.5, function() hs.application.launchOrFocus(app); end)
--         else
--             local app_windows = application:allWindows()
--
--             for k, window in pairs(app_windows) do
--                 local title = window:title()
--                 if title:len() > 0 and (title:find(win)==nil) ~= inclusive
--                 then
--                     window:focus()
--                     -- for some reason hangouts tends to lose focus just after gaining it first
--                     hs.timer.doAfter(0.5, function() window:focus(); end)
--                 end
--             end
--         end
--     end
-- end


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
    print(app)
    hs.application.launchOrFocus(app)
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

-- app_switcher opens mission control and starts monitoring the button presses
-- function app_switcher()
--     if (not e:isEnabled())
--     then
--         mission_control = hs.task.new("/Applications/Mission Control.app/Contents/MacOS/Mission Control", nil)
--         mission_control:start() -- no key will be proccessed until this timer finishes
--         mission_control_opening:start()
--         e:start()
--     end
-- end
--
-- hs.hotkey.bind({}, "F20", app_switcher)

hs.hotkey.bind({"cmd"}, "pagedown", function() hs.deezer.next() end)
hs.hotkey.bind({"cmd"}, "pageup", function() hs.deezer.previous() end)

k = hs.hotkey.modal.new('', 'F20')

for index, value in pairs(key_params) do
    k:bind('', index, function()
        -- hs.timer.waitWhile(
        --     -- if mission_control is still opening, wait for it to finish the animation. wait also for f20 key to be released
        --     function()
        --         -- return f20_event_up:isEnabled() or mission_control_opening:running()
        --         return mission_control_opening:running()
        --     end,
        --     function()
        --         launchOrFocus(key_params[pressed_key])
        --         hs.eventtap.keyStroke({}, "escape")
        --     end,
        --     0.1
        -- )

        launchOrFocus(value)

        if (value == "Gmail")
        then
            gmail_frame = hs.window.focusedWindow():frame()
            p = {x=gmail_frame["x"]+15.0, y=gmail_frame["y"]+60.0}
        end

        k:exit()
    end)
end

k:bind('', 'escape', function() k:exit(); hs.eventtap.keyStroke({}, "escape") end)
-- k:bind('', 'F20', function() k:exit() end)
-- k:bind({'ctrl'}, 'down', function() k:exit() end)

hs.hotkey.bind({'cmd'}, '.', function()
    launchOrFocus("Google Chrome")
    hs.eventtap.keyStroke({'ctrl'}, ".")
end)


function k:entered()
    mission_control = hs.task.new("/Applications/Mission Control.app/Contents/MacOS/Mission Control", nil)
    mission_control:start() -- no key will be proccessed until this timer finishes
    mission_control_opening:start()
    e:start()
end

function k:exited()
    hs.alert'Exited mode'
    e:stop()

    hs.eventtap.keyStroke({}, "escape") -- to exit Mission Control
    if p ~= nil
    then
        print(p)
        hs.timer.doAfter(0.1, function() leftClick(p); p=nil; end)
    end
end

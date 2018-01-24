spaces = require("hs._asm.undocumented.spaces")

--detect when mission control is opening with just a short countdown
point_click = nil -- point in current screen to click on

-- mission control timer. for opening it if there was no choice made after 1 second
mission_control_soon = hs.timer.doAfter(0.1, function() hs.task.new("/Applications/Mission Control.app/Contents/MacOS/Mission Control", nil):start(); end)
mission_control_soon:stop()

-- timer that tells whether screen is animating and I can't do anything else
animating = nil
animating = hs.timer.new(0.4, function() animating:stop(); end)

found_window = nil
all_spaces = nil
visible_spaces = nil

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
    -- ["g"] = {["app"]="Google Chrome", ["win"]="Google Hangouts", ["inclusive"]=false};
    -- ["h"] = {["app"]="Google Chrome", ["win"]="Google Hangouts", ["inclusive"]=true};
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
    ["b"] = "DBeaver";
    ["k"] = "Slack";
    ["r"] = "iBooks";
    ["s"] = "Spotify"
}


function mouseClick(button, point, modifiers)
    local button = button or "left"
    local point = point or hs.mouse.getAbsolutePosition()
    local modifiers = modifiers
    print(button .. '@' .. point.x .. ' , ' .. point.y)
    local clickState = hs.eventtap.event.properties.mouseEventClickState
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types[(button .. "MouseDown")], point, modifiers):setProperty(clickState, 1):post()
    hs.timer.doAfter(0.1, function() hs.eventtap.event.newMouseEvent(hs.eventtap.event.types[(button .. "MouseUp")], point):setProperty(clickState, 1):post(); end)
end

function moveCenterScreen(screen)
    local rect = screen:fullFrame()
    local center = hs.geometry.rectMidPoint(rect)
    hs.mouse.setAbsolutePosition(center)
end

function index_of_space(sp)
    local layout = spaces.layout()
    for screen, spaces in pairs(layout) do
        position = index_of(spaces, sp)
        if position then
            return position
        end
    end
    return false
end

function active_spaces()
    local active_list = spaces.query(spaces.masks.currentSpaces)
    local spaces_layout = spaces.layout()
    local result = {}
    for i, active_space in ipairs(active_list) do
        for uuid, spaces in pairs(spaces_layout) do
            if has_value(spaces, active_space) then
                result[uuid] = active_space
            end
        end
    end
    return result
end

function launchOrFocus(app, win, inclusive)
    local win = win or ''
    local inclusive = inclusive==nil and true or inclusive

    local all_windows = hs.window.filter.new(true)

    for dummy, window in pairs(all_windows:getWindows()) do
        if window:application():name() == app
        then
            local title = window:title()
            if title:len() > 0 and (title:find(win)==nil) ~= inclusive
            then
                found_window = window
                local found_window_space = found_window:spaces()[1] -- can it be in several spaces?
                if not has_value(visible_spaces, found_window_space) then
                    local found_window_space_pos = index_of_space(found_window_space)
                    local visible_space_pos = index_of_space(visible_spaces[found_window:screen():spacesUUID()])
                    local pt = hs.mouse.getAbsolutePosition()
                    moveCenterScreen(window:screen())

                    if found_window_space_pos > visible_space_pos then
                        for i = visible_space_pos,found_window_space_pos,1 do
                            hs.eventtap.keyStroke({'ctrl'}, "right")
                            animating:start()
                        end
                    elseif found_window_space_pos < visible_space_pos then
                        for i = visible_space_pos,found_window_space_pos,-1 do
                            hs.eventtap.keyStroke({'ctrl'}, "left")
                            animating:start()
                        end
                    end

                    hs.mouse.setAbsolutePosition(pt)
                end
                found_window:application():activate(false)
                return
            end
        end
    end

    hs.application.launchOrFocus(app)
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


-- ---------------
-- bind shortcuts
-- ---------------

-- Music control
hs.hotkey.bind({"cmd"}, "pagedown", function() hs.spotify.next() end)
hs.hotkey.bind({"cmd"}, "pageup", function() hs.spotify.previous() end)

event_mmb = hs.eventtap.new({hs.eventtap.event.types.otherMouseDown}, function(event)
    mouse_button_pressed = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
    if mouse_button_pressed == 2 then
        local ptMouse = hs.mouse.getAbsolutePosition()
        event_mmb:stop()
        hs.timer.doAfter(0.0, function() mouseClick("left", ptMouse, "cmd"); event_mmb:start(); end)
    end
    return true
end)
event_mmb:start()

-- Switch to Google Chrome and press ctrl+. for Tabli
hs.hotkey.bind({'cmd'}, '.', function()
    launchOrFocus("Google Chrome")
    hs.eventtap.keyStroke({'ctrl'}, ".")
end)


-- app switching
modal_f20 = hs.hotkey.modal.new('', 'F20')

-- if pressing escape key exit from modal mode
modal_f20:bind('', 'escape', function() modal_f20:exit(); end)
-- if clicking with LMB exit from modal mode
event_lmb = hs.eventtap.new({hs.eventtap.event.types.leftMouseDown}, function(event)
    event_lmb:stop()
    hs.timer.doAfter(0.1, function() modal_f20:exit(); end)
    return false
end)
event_lmb:stop()


-- Assign keypresses to apps while in modal mode
for index, value in pairs(key_params) do
    modal_f20:bind('', index, function()

        mission_control_opened = not mission_control_soon:running()
        mission_control_soon:stop()

        if type(value) == 'string' then
            launchOrFocus(value)
            hs.alert(value)
        else
            local app = value['app']
            launchOrFocus(value['app'], value['win'], value['inclusive'])
            hs.alert(value['app'])
        end

        post_function = value['after'] or function(); end

        if mission_control_opened then
            hs.timer.waitUntil(
                function() return not animating:running(); end,
                function()
                    animating:start()
                    hs.eventtap.keyStroke({}, "escape") -- to exit Mission Control
                    hs.timer.waitUntil(function() return not animating:running(); end, post_function, 0.1)
                end,
                0.1)
        else
            hs.timer.waitUntil(function() return not animating:running(); end, post_function, 0.1)
        end

        modal_f20:exit()
    end)
end


function modal_f20:entered()
    all_spaces = spaces.layout()
    visible_spaces = active_spaces()
    mission_control_soon:start()
    event_lmb:start()
end


function modal_f20:exited()
    event_lmb:stop()
end

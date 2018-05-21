spaces = require("hs._asm.undocumented.spaces")

-- timer that tells whether screen is animating and I can't do anything else
animating = nil
function animating_timer()
    local seconds = 0.5
    if animating == nil then
        animating = hs.timer.new(seconds, function() animating:stop(); end)
    elseif animating:running() then
        animating:setNextTrigger(seconds)
    else
        animating:start()
    end
end
animating_timer()


-- mission control timer. for opening it if there was no choice made after 1 second
mission_control_soon = hs.timer.doAfter(0.2, function() hs.task.new("/Applications/Mission Control.app/Contents/MacOS/Mission Control", nil):start(); animating_timer(); end)
mission_control_soon:stop()

found_window = nil
all_spaces = nil
visible_spaces = nil

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

    local all_windows = hs.window.filter.new(true):getWindows()

    for dummy, window in pairs(all_windows) do
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

                    while visible_space_pos < found_window_space_pos do
                        hs.eventtap.keyStroke({'ctrl'}, "right")
                        visible_space_pos = visible_space_pos + 1
                        animating_timer()
                    end
                    while visible_space_pos > found_window_space_pos do
                        hs.eventtap.keyStroke({'ctrl'}, "left")
                        visible_space_pos = visible_space_pos - 1
                        animating_timer()
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

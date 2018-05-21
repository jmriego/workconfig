-- app switching
modal_f20 = hs.hotkey.modal.new('', 'F20')

-- if pressing escape key exit from modal mode
-- and also press escape if mission control is opened (or opening)
modal_f20:bind('', 'escape', function()
        modal_f20:exit()
        if mission_control_soon:running() then
            mission_control_soon:stop()
        else
            hs.timer.waitUntil(
                function() return not animating:running(); end,
                function()
                    hs.eventtap.keyStroke({}, "escape") -- to exit Mission Control
                end,
                0.1)
        end
    end)

-- if clicking with LMB exit from modal mode and just let the user manage mission control
event_lmb = hs.eventtap.new({hs.eventtap.event.types.leftMouseDown}, function(event)
    event_lmb:stop()
    hs.timer.doAfter(0.1, function() modal_f20:exit(); end)
    return false
end)
event_lmb:stop()

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


function assign_modal_hotkeys(key_params)
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
                        hs.eventtap.keyStroke({}, "escape") -- to exit Mission Control
                        animating_timer()
                        hs.timer.waitUntil(function() return not animating:running(); end, post_function, 0.1)
                    end,
                    0.1)
            else
                hs.timer.waitUntil(function() return not animating:running(); end, post_function, 0.1)
            end

            modal_f20:exit()
        end)
    end
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

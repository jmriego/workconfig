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

local module = {}
module.__index = module

function module.send_notification(title, text)
    local title=title or "Alert"
    local text=text or "Alert"
    hs.notify.new({title=title, informativeText=text}):send()
end

return module

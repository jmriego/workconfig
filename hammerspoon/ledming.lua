ledmingOnIcon = [[ASCII:
A......A
........
........
........
........
........
........
A..CD..A
........
........
........
F......E
]]

ledmingOffIcon = [[ASCII:
h........h
..........
..........
..........
..........
..........
..........
..........
..........
..........
..........
..........
..........
h........h
]]

ledming = hs.menubar.new():setIcon(ledmingOffIcon)
whaevah = ''

function ledmingStatus()
    output, status, typere, rc = hs.execute('/usr/bin/sudo /bin/launchctl list local.ledming')
    whaevah = whaevah .. output .. '\n----------\n'
    -- if is connected it will return 0
    return rc == 0
end

function setLedmingIcon(state)
    if state then
        ledming:setIcon(ledmingOnIcon)
    else
        ledming:setIcon(ledmingOffIcon)
    end
end

function ledmingTriggerVPN(state)
    -- if is connected, then disconnect it
    state = type(state)=="boolean" and state or not ledmingStatus()
    if state then
        hs.execute('/usr/bin/sudo /bin/launchctl unload /Library/LaunchAgents/org.openvpn.plist')
        hs.execute('/usr/bin/sudo /bin/launchctl load /Library/LaunchAgents/org.openvpn.plist')
    else
        hs.execute('/usr/bin/sudo /bin/launchctl unload /Library/LaunchAgents/org.openvpn.plist')
    end
    setLedmingIcon(ledmingStatus())
end

if ledming then
    ledming:setClickCallback(ledmingTriggerVPN)
    setLedmingIcon(ledmingStatus())
end

-- sync in one of these directions: get, put or both
function syncLedming(direction)
    if direction == 'both' or direction == 'get' then
        hs.execute('/usr/local/bin/task sync')
        hs.execute('/usr/local/bin/rclone copy onedrive:NewDatabase.kdbx ~/Downloads')
        hs.execute('/usr/local/bin/rclone copy "ledming:/mnt/sda2/udisk1/Fitness/*.txt" ~/Documents/Fitness')
    end
    if direction == 'both' or direction == 'put' then
        hs.execute('/usr/local/bin/rclone copy ~/Documents/Fitness/Fitness.ods ledming:/mnt/sda2/udisk1/Fitness')
    end
end

fitness_updated = nil
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/Documents/Fitness/", function()
    fitness_updated:stop()
    fitness_updated:start()
end):start()

put_then_disconnect = false
fitness_updated = hs.timer.doAfter(10, function()
    VPNstatus = ledmingStatus()
    myWatcher:stop()
    if not VPNstatus then
        put_then_disconnect = true
        ledmingTriggerVPN(true)
    else
        syncLedming('put')
    end
    hs.timer.doAfter(30, function() myWatcher:start() end)
end)
fitness_updated:stop()

-- open -g "hammerspoon://ledming?what=vpn"
hs.urlevent.bind("ledming", function(eventName, params)
  if params["what"] == 'vpn' then
    syncLedming('get')
    if put_then_disconnect then
        syncLedming('put')
        ledmingTriggerVPN(false)
        put_then_disconnect = false
    end
    hs.notify.new({title='Hi', informativeText='all done'}):send()
  end
end)

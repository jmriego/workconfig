-- Notifications
-- open -g "hammerspoon://show_notification?title=Pay Attenttion&text=I just finished this long proccess"
-- the title and text and optional parameters
hs.urlevent.bind("ledming", function(eventName, params)

  if params["what"] == 'vpn' then
    hs.execute('/usr/local/bin/task sync')
    hs.execute('/usr/local/bin/rclone copy onedrive:NewDatabase.kdbx ~/Downloads')
    hs.execute('/usr/local/bin/rclone copy "ledming:/mnt/sda2/udisk1/Fitness/Way of Dom.txt" ~/Documents/Fitness')
    hs.notify.new({title='Hi', informativeText='all done'}):send()
  end
end)

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

function ledmingClicked()
    -- if is connected, then disconnect it
    if ledmingStatus() then
        hs.execute('/usr/bin/sudo /bin/launchctl unload /Library/LaunchAgents/org.openvpn.plist')
    else
        hs.execute('/usr/bin/sudo /bin/launchctl unload /Library/LaunchAgents/org.openvpn.plist')
        hs.execute('/usr/bin/sudo /bin/launchctl load /Library/LaunchAgents/org.openvpn.plist')
    end
    setLedmingIcon(ledmingStatus())
end

if ledming then
    ledming:setClickCallback(ledmingClicked)
    setLedmingIcon(ledmingStatus())
end

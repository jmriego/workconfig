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

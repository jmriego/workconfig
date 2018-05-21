-- Window Management
-- move window to left half of current screen
function split_window_left(win)
  local win = win or hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end

-- move window to right half of current screen
function split_window_right(win)
  local win = win or hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x + (max.w / 2)
  f.y = max.y
  f.w = max.w / 2
  f.h = max.h
  win:setFrame(f)
end

-- make window take the entire screen
function maximize_window(win)
  local win = win or hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  f.x = max.x
  f.y = max.y
  f.w = max.w
  f.h = max.h
  win:setFrame(f)
end

-- make window take the entire screen
function fullscreen_window(win)
  local win = win or hs.window.focusedWindow()
  win:setFullScreen(not win:isFullScreen())
end

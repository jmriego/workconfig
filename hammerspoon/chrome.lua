local module = {}
module.__index = module

function module.switch_tab(urlSearchString)
  local script = ([[(function() {
      var browser = Application('Google Chrome');
      browser.activate();

      for (win of browser.windows()) {
        var tabIndex =
          win.tabs().findIndex(tab => tab.url().match(/%s/));

        if (tabIndex != -1) {
          win.activeTabIndex = (tabIndex + 1);
          win.index = 1;
        }
      }
    })();
  ]]):format(urlSearchString)
  hs.osascript.javascript(script)
end

return module

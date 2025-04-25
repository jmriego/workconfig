local module = {}
module.__index = module

function module.assign_app_shortcuts(key_params)
    for index, value in pairs(key_params) do
        hs.hotkey.bind({"cmd", "alt"}, index, nil, function()

            local app;
            if type(value) == 'string' then
                app = value
            else
                app = value['app']
            end

            hs.application.launchOrFocus(app)
            hs.alert(app)

            if value['after'] then
                value['after']()
            end
        end)
    end
end

return module

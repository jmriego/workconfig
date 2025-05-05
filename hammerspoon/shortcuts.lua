local module = {}
module.__index = module

function module.assign_app_shortcuts(default_modifiers, key_params)
    for index, value in pairs(key_params) do
        local app
        local modifiers

        if type(value) == 'string' then
            app = value
            modifiers = default_modifiers
        else
            app = value['app']
            modifiers = value['modifiers'] or default_modifiers
        end

        hs.hotkey.bind(modifiers, index, nil, function()
            hs.application.launchOrFocus(app)
            hs.alert(app)

            if value['after'] then
                value['after']()
            end
        end)
    end
end

return module

-- is the value in the table?
function has_value(tab, val)
    for index, value in pairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function index_of(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end

    return false
end

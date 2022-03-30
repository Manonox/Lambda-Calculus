return function(...)
    local r = {}
    for _, s in ipairs({...}) do
        local ns = s
        if type(s) == "string" then
            ns = require("utils.escapedstring")
        end
        table.insert(r, ns)
    end
    print(table.unpack(r))
end


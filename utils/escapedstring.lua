return function(s)
    local ns = s
    if type(s) == "string" then
        if s == "" then
            ns = "\"\""
        else
            ns = s:gsub("\n", "\\n")
        end
    end
    return ns
end


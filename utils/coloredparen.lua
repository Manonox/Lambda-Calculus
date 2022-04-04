local coloredparen = {}
coloredparen.reset_color = "\27[0m"
coloredparen.colors = {
    "\27[31m",
    "\27[33m",
    "\27[32m",
    "\27[34m",
    "\27[36m",
    "\27[35m",
}

local coloredparen_mt = {}
function coloredparen_mt.__call(t, p, i)
    local col = coloredparen.colors[(i % #coloredparen.colors) + 1]
    return col .. p .. coloredparen.reset_color
end
setmetatable(coloredparen, coloredparen_mt)

return coloredparen


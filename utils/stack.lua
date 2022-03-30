---@class Stack
---@field private _tbl table
local Stack = class("Stack")

function Stack:initialize()
    self._tbl = {}
end

function Stack:push(x)
    table.insert(self._tbl, x, 1)
end

function Stack:pop()
    return table.remove(self._tbl, 1)
end

function Stack:empty()
    return #self._tbl == 0
end

function Stack:size()
    return #self._tbl
end

return Stack


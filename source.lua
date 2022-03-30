---@class Source
---@field text string
---@field fname string
local Source = class("Source")

function Source:initialize(str, fname)
    -- Fix line endings
    str = str:gsub("\r\n", "\n"):gsub("\r", "\n")
    if str:sub(#str, #str) ~= "\n" then
        str = str .. "\n"
    end

    self.text = str
    self.fname = fname
end

function Source:copy()
    local source = Source(self.text, self.fname)
    return source
end

function Source:getLine(line)
    local text = self.text
    while line > 1 do
        line = line - 1
        local npos = text:find("\n")
        if not npos then return end
        text = text:sub(npos + 1)
    end

    local npos = text:find("\n")
    if npos then
        return text:sub(1, npos)
    else
        return text
    end
end

function Source:__tostring()
    if self.fname then return self.fname end
    return "stdin"
end

return Source


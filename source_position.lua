local Source = require("source")


---@class SourcePosition
---@field source Source
---@field line number
---@field col number
---@field line_cache string
---@field col_cache string
local SourcePosition = class("SourcePosition")

function SourcePosition:initialize(source, line, col)
    line = line or 1
    col = col or 1

    self.source = source
    self.line = line
    self.col = col
    self.charpos = 0

    self.is_eof = false


    local text = self.source.text
    while line > 1 do
        line = line - 1
        local npos = text:find("\n")
        if not npos then
            self.is_eof = true
            break
        end
        self.charpos = self.charpos + npos
        text = text:sub(npos + 1)
    end

    self.charpos = self.charpos + self.col
end

function SourcePosition:copy()
    local source_pos = SourcePosition(self.source, self.line, self.col)
    source_pos.is_eof = self.is_eof
    return source_pos
end

function SourcePosition:_getRemainder()
    return self.source.text:sub(self.charpos)
end

function SourcePosition:match(pattern)
    local str = self:_getRemainder()
    return str:match("^" .. pattern)
end

function SourcePosition:getChar()
    return self.source.text:sub(self.charpos, self.charpos)
end

function SourcePosition:advance(x)
    if x then
        while x > 0 do
            x = x - 1
            self:advance()
        end
        return
    end

    if self.is_eof then error("End of file reached.") end

    if self:getChar() == "\n" then
        self.line = self.line + 1
        self.col = 1
    else
        self.col = self.col + 1
    end

    self.charpos = self.charpos + 1

    if self.charpos > #self.source.text then
        self.is_eof = true
    end
end

function SourcePosition:__tostring()
    return tostring(self.source) .. ":" .. self.line .. ":" .. self.col
end

return SourcePosition


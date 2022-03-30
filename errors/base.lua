---@class Error
---@field details string
---@field pos_end SourcePosition
---@field pos_start SourcePosition
local Error = class("Error")

function Error:initialize(details, pos_start, pos_end)
    self.details = details
    self.pos_start = pos_start
    self.pos_end = pos_end
end

function Error:__tostring()
    return self.class.name .. "@" .. tostring(self.pos_start) .. ": " .. self.details
end


return Error


local Error = require("errors.base")


---@class InvalidSyntaxError : Error
local InvalidSyntaxError = class("InvalidSyntaxError", Error)

return InvalidSyntaxError


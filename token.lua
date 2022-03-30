---@class Token
---@field type string
---@field value any
---@field pos_start SourcePosition
---@field pos_end SourcePosition
local Token = class("Token")
Token.static.types = {
    variable = {
        pattern = "[a-z][0-9]*",
        -- [0-9]* Allows for variables such as a1, b1, c3, etc...
        parse = function(str) return str, #str end,
        name = "Variable",
        -- priority = 0,
    },

    definition = {
        pattern = "[^%p%l%(%)%s%c%z%<%>]+",
        parse = function(str) return str, #str end,
        name = "Definition",
    },

    equals = {
        pattern = ":?=",
        name = "Equals",
    },

    lambda = {
        pattern = "[%^L]",
        name = "Lambda",
        priority = 100,
    },

    dot = {
        pattern = "%.",
        name = "Dot",
    },

    lparen = {
        pattern = "%(",
        name = "LParen",
    },

    rparen = {
        pattern = "%)",
        name = "RParen",
    },

    include = {
        pattern = "@([^\n]+)\n",
        parse = function(str) return str:gsub("^%s+", ""):gsub("%s+$", ""), #str + 2 end,
        name = "Include",
    },

    cout = {
        pattern = "<<?",
        name = "COut",
    },

    cin = {
        pattern = ">>?",
        name = "CIn",
    },


    newline = {
        pattern = "[\n;]+",
        name = "NewLine",
    },

    eof = {
        name = "EOF",
    }
}

function Token:initialize(type, value)
    self.type = type
    self.value = value
    self.pos_start = nil
    self.pos_end = nil
end

function Token:getTypeData()
    return Token.static.types[self.type]
end

function Token:__tostring()
    local data = self:getTypeData()
    local value = ""
    if self.value then
        value = "[" .. tostring(self.value) .. "]"
    end
    return data.name .. value
end

return Token


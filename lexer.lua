local Token = require("token")
local SourcePosition = require("source_position")


---@class Lexer
---@field source string
---@field pos SourcePosition
---@field current_char string
local Lexer = class("Lexer")

function Lexer:initialize(source)
    self.source = source
    self.pos = SourcePosition(self.source)
end

function Lexer:makeToken()
    local result
    local length = 0
    local priority = -math.huge
    for type, data in pairs(Token.static.types) do
        local new_result
        local new_length
        local new_priority = data.priority or 0

        if data.pattern then
            local match = {self.pos:match(data.pattern)}
            if #match > 0 then
                if data.parse then
                    local value, len = data.parse(table.unpack(match))
                    new_result = {type, value}
                    new_length = len
                else
                    new_result = {type}
                    new_length = #(match[1])
                end
            end
        end

        if new_result then
            local longer = new_length > length
            local equal_but_prioritized = new_length == length and new_priority > priority
            if longer or equal_but_prioritized then
                result = new_result
                length = new_length
                priority = new_priority
            end
        end
    end

    if not result then return end

    local token = Token(table.unpack(result))
    token.pos_start = self.pos:copy()
    token.pos_end = self.pos:copy()
    token.pos_end:advance(length)

    return token, length
end


local advance_skip = {[" "] = true}
function Lexer:_step()
    local char = self.pos:getChar()
    while advance_skip[char] and not self.pos.is_eof do
        self.pos:advance()
        char = self.pos:getChar()
    end

    local comment = self.pos:match("//[^\n]*\n")
    if comment then
        self.pos:advance(#comment - 1)
        return
    end

    if self.pos.is_eof then return end

    local token, length = self:makeToken()
    if token then
        table.insert(self.tokens, token)
        self.pos:advance(length)
    else
        local pos_start, pos_end = self.pos:copy(), self.pos:copy()
        pos_end:advance()
        self.error = require("errors.illegal_char")("'" .. require("utils.escapedstring")(self.pos:getChar()) .. "'", pos_start, pos_end)
    end
end

function Lexer:_trim()
    -- Newlines at the beginning
    while self.tokens[1] and self.tokens[1].type == "newline" do
        table.remove(self.tokens, 1)
    end

    -- Newlines at the end
    while
        #self.tokens > 1 and
        self.tokens[#self.tokens-1].type == "newline" and
        self.tokens[#self.tokens].type == "newline"
        do
        table.remove(self.tokens)
    end
end

function Lexer:tokenize()
    self.tokens = {}
    self.error = nil
    while not self.pos.is_eof and not self.error do
        self:_step()
    end

    self:_trim()
    table.insert(self.tokens, Token("eof"))

    return self.tokens, self.error
end


return Lexer


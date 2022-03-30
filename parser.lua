local ParseResult


---@class Parser
---@field tokens Token[]
---@field current_token Token
---@field index number
---@field private depth number
local Parser = class("Parser")

function Parser:initialize(tokens)
    self.tokens = tokens
    self.current_token = nil
    self.index = 0
    self.depth = 1

    self:advance()
end

function Parser:advance()
    self.index = self.index + 1
    -- if self.index > #self.tokens then
    self.current_token = self.tokens[self.index]
end

function Parser:printDebug()
    self:depthPrint("[" .. self.index .. "] " .. tostring(self.current_token))
end
function Parser:depthPrint(s)
    s = tostring(s)
    local prefix = ""
    if self.depth > 0 then
        prefix = string.rep("| ", math.max(self.depth - 1, 0))
    end
    print(prefix .. s)
end
function Parser:depthIn()
    self.depth = self.depth + 1
end
function Parser:depthOut()
    self.depth = self.depth - 1
end

function Parser:parse()
    self.depth = 0

    local result = self:_line()
    if result.node then
        Parser.fixparents(result.node)
    end
    return result
end

local VariableNode = require("nodes.variable")
local AbstractionNode = require("nodes.abstraction")
local ApplicationNode = require("nodes.application")

function Parser.fixparents(node, parent)
    node.parent = parent

    if node.class == AbstractionNode then
        Parser.fixparents(node.exp, node)
        Parser.fixparents(node.var, node)
    end

    if node.class == ApplicationNode then
        Parser.fixparents(node.left, node)
        Parser.fixparents(node.right, node)
    end
end

function Parser:_line()
    self:depthIn()

    local result = ParseResult()


    local exp = result:register(self:_exp_noparen())
    if result.error then self:depthOut() return result end

    if self.current_token.type == "newline" then
        result:register_advancement()
        self:advance()
        self:depthOut()
        return result:success(exp)
    else
        self:depthOut()
        return result:failure(require("errors.invalid_syntax")(
            "wtf",
            self.current_token.pos_start,
            self.current_token.pos_end
        ))
    end
end


function Parser:_exp()
    --self:printDebug()
    self:depthIn()

    local result = ParseResult()
    local token = self.current_token

    if token.type == "variable" then
        local var = result:register(self:_var())
        if result.error then self:depthOut() return result end
        self:depthOut()
        return result:success(var)

    elseif token.type == "lambda" then
        result:register_advancement()
        self:advance()

        local vars = {}
        while self.current_token.type == "variable" do
            local var = result:register(self:_var())
            if result.error then self:depthOut() return result end
            table.insert(vars, var)
        end

        if #vars > 0 and self.current_token.type == "dot" then
            result:register_advancement()
            self:advance()
            local exp = result:register(self:_exp_noparen())
            if result.error then self:depthOut() return result end
            while #vars > 0 do
                exp = AbstractionNode(table.remove(vars), exp)
            end
            self:depthOut()
            return result:success(exp)
        else
            self:depthOut()
            return result:failure(require("errors.invalid_syntax")(
                "Expected '.' or another variable",
                self.current_token.pos_start,
                self.current_token.pos_end
            ))
        end

    elseif token.type == "lparen" then
        result:register_advancement()
        self:advance()

        local exp = result:register(self:_exp_noparen())
        if result.error then self:depthOut() return result end

        if self.current_token.type == "rparen" then
            result:register_advancement()
            self:advance()
            return result:success(exp)
        else
            self:depthOut()
            return result:failure(require("errors.invalid_syntax")(
                "Expected ')'",
                self.current_token.pos_start,
                self.current_token.pos_end
            ))
        end

    else
        self:depthOut()
        return result:failure(require("errors.invalid_syntax")(
            "Unexpected token '" .. tostring(self.current_token) .. "'",
            self.current_token.pos_start,
            self.current_token.pos_end
        ))

    end
end

local exp_starts = {
    variable = true,
    lambda = true,
    lparen = true,
}
function Parser:_exp_noparen()
    local result = ParseResult()

    local exps = {}
    while exp_starts[self.current_token.type] do
        local exp = result:register(self:_exp())
        if result.error then self:depthOut() return result end
        table.insert(exps, exp)
    end

    if #exps == 0 then
        self:depthOut()
        return result:failure(require("errors.invalid_syntax")(
            "Empty expression",
            self.current_token.pos_start,
            self.current_token.pos_end
        ))
    end

    if #exps == 1 then
        self:depthOut()
        return result:success(exps[1])
    end

    local exp = table.remove(exps, 1)
    while #exps > 0 do
        exp = ApplicationNode(exp, table.remove(exps, 1))
    end

    self:depthOut()
    return result:success(exp)
end

function Parser:_var()
    self:depthIn()

    local result = ParseResult()
    local token = self.current_token

    if token.type == "variable" then
        result:register_advancement()
        self:advance()

        self:depthOut()
        local node = VariableNode(token.value, token)
        return result:success(node)
    else
        return result:failure(require("errors.invalid_syntax")(
            "Unexpected token '" .. self.current_token .. "'",
            self.current_token.pos_start,
            self.current_token.pos_end
        ))
    end
end


---@class ParseResult
---@field error Error
---@field node Node
ParseResult = class("ParseResult")
Parser.static.ParseResult = ParseResult

function ParseResult:initialize()
    self.error = nil
    self.node = nil
    self.advance_count = 0
end

function ParseResult:register_advancement()
    self.advance_count = self.advance_count + 1
end

function ParseResult:register(result)
    self.advance_count = self.advance_count + result.advance_count
    if result.error then self.error = result.error end
    return result.node
end

function ParseResult:success(node)
    self.node = node
    return self
end

function ParseResult:failure(error)
    if not self.error or self.advance_count == 0 then
        self.error = error
    end
    return self
end

function ParseResult:__tostring()
    local t = self.error and "Error" or "Success"
    local s = self.error or self.node
    return "ParseResult[".. t .. "] " .. tostring(s)
end


return Parser


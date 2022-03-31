local Source = require("source")
local Error = require("errors.base")
local Source = require("source")
local Lexer = require("lexer")
local Parser = require("parser")
local Reducer = require("reducer")


local LambdaVM = class("LambdaVM")

function LambdaVM:initialize()

end

function LambdaVM:runString(text, origin)
    local source = Source(text, origin)
    local lexer = Lexer(source)
    local tokens, error = lexer:tokenize()

    if error then
        return self:onError(error)
    end

    local parser = Parser(tokens)
    local result = parser:parse()

    if result.error then
        return self:onError(result.error)
    end

    local ast = result.node

    local reducer = Reducer(ast)

    local modified
    repeat
        modified = reducer:step()
        if self.show_steps then print(reducer.ast) end
    until not modified

    return reducer.ast
end

function LambdaVM:onError(error)
    -- print("Failed.")
    -- print("----------")
    -- print(error)
    return error
end

return LambdaVM


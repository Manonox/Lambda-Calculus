class = require("libs.middleclass")

local LambdaVM = require("lambdavm")


local function run(s)
    local lvm = LambdaVM()
    return tostring(lvm:runString(s))
end

local function parse(s, astree)
    local lexer = require("lexer")(require("source")(s))
    local tokens, error = lexer:tokenize()

    if error then
        return error
    end

    local parser = require("parser")(tokens)
    local result = parser:parse()

    if result.error then
        return result.error
    end

    local ast = result.node
    return astree and ast or tostring(ast)
end



local current_test
local fail_state = false
local function assert_func(func, s_in, s_out)
    local result = func(s_in)
    local success = s_out == result
    local symb = success and "v" or "x"

    print("[" .. symb .. "] | Result: " .. result .. (success and "" or (" | Must be: " .. s_out)))
end

local function test_print(name)
    if current_test then
        print("--------------------------")
        print(fail_state and "FAILURE" or "SUCCESS")
        print("================================")
    end

    if not name then return end

    fail_state = false
    current_test = name
    print(name)
    print("--------------------------")
end





print("================================")

test_print("TEST_PARSE_0")
do
    --[[
    local tree = parse("^x.xyz", true)
    tree:treePrint()
    ]]

    assert_func(parse, "(xyz)", "(xy)z")
    assert_func(parse, "xyz", "(xy)z")
    assert_func(parse, "^x.xyz", "^x.((xy)z)")
    assert_func(parse, "^x.xy z ^p.q u", "^x.(((xy)z)(^p.(qu)))")

    assert_func(parse, "^xyz.zyx", "^x.(^y.(^z.((zy)x)))")

    assert_func(parse, "(^xy.yx) qp", "((^x.(^y.(yx)))q)p")
    assert_func(parse, "^x.xz^y.yxz", "^x.((xz)(^y.((yx)z)))")
end

test_print("TEST_SUBS_1")
do
    assert_func(run, "(^x.x) y", "y")
end

test_print("TEST_SUBS_2")
do
    assert_func(run, "(^x.y) z", "y")
end

test_print("TEST_SUBS_3")
do
    assert_func(run, "(^x.xy) z", "zy")
    assert_func(run, "(^xy.yx) qp", "pq")
    assert_func(run, "(^xy.yxz) qp", "(pq)z")
end

test_print("TEST_SUBS_4")
do
    assert_func(run, "(^x.^x.x) z", "^x.x")
    assert_func(run, "(^x.^x.y) z", "^x.y")
    assert_func(run, "(^x.^x.z) z", "^x.z")
end

test_print("TEST_SUBS_5")
do
    assert_func(run, "(^x.^y.y) z", "^y.y")
    assert_func(run, "(^x.^y.z) z", "^y.z")
end

test_print("TEST_SUBS_6")
do
    assert_func(run, "(^x.^y.x) z", "^y.z")
    assert_func(run, "(^x.^y.^f.xx(xx)x) z", "^y.(^f.(((zz)(zz))z))")
end


test_print("TEST_SUBS_7")
do
    assert_func(run, "(^x.^y.x) y", "^y0.y")

    assert_func(run, "(^x.x^y.yx) (vw)", "(vw)(^y.(y(vw)))")

    assert_func(run, "(^yx.yzx) x", "^x0.((xz)x0)")
end


test_print()


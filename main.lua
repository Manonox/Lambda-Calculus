class = require("libs.middleclass")

local Error = require("errors.base")
local LambdaVM = require("lambdavm")

local lvm = LambdaVM()

while true do
    io.write("> ")
    local inp = io.read()
    lvm.show_steps = true
    local r = lvm:runString(inp)
    if r.class:isSubclassOf(Error) then
        print(tostring(r))
    else
        print("Normal form: " .. r:toprettytext())
    end
end


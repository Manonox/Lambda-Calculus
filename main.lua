class = require("libs.middleclass")

local LambdaVM = require("lambdavm")






--[[local src = Source([[

// ((z ^x.^y.z) (x y) a)

^xy.x p q

]]--)
--local src = Source("^xy.x ^z.y p q")

-- (^x.^y.(^z.(^x.z x) (^y.z y)) (x y))
--[[
// Y = Lf. (Lx.f(xx)) (Lx.f(xx))
// @ std.lmbd

//F = Lx.x; F2 = Lxy.x

//>> X; << F X
]]

local lvm = LambdaVM()

local r = tostring(lvm:runString("(^y.xy) z"))

print("Normal form: " .. r)


local AbstractionNode = require("nodes.abstraction")
local ApplicationNode = require("nodes.application")
local VariableNode = require("nodes.variable")

local Stack = require("utils.stack")

---@class Reducer
---@field ast Node
local Reducer = class("Reducer")

function Reducer:initialize(ast)
    self.ast = ast
end

function Reducer:findRedex(root)
    root = root or self.ast

    if root.class == VariableNode then return end

    if root.class == ApplicationNode then
        if root.left.class == AbstractionNode then
            return root
        end

        local rl = self:findRedex(root.left)
        if rl then return rl end

        local rr = self:findRedex(root.right)
        if rr then return rr end

        return
    end

    if root.class == AbstractionNode then
        local re = self:findRedex(root.exp)
        if re then return re end

        return
    end
end


local function set(...)
    local t = {}
    for _, v in ipairs({...}) do
        t[v] = true
    end
    return t
end
local function union(t1, t2)
    local r = {}
    for k, v in pairs(t1) do r[k] = v end
    if type(t2) == "table" then
        for k, v in pairs(t2) do r[k] = v end
    else
        r[t2] = v
    end
    return r
end
local function remove(t1, t2)
    local r = {}
    for k, v in pairs(t1) do r[k] = v end
    if type(t2) == "table" then
        for k, v in pairs(t2) do r[k] = nil end
    else
        r[t2] = nil
    end
    return r
end

local function getFV(exp)
    if exp.class == VariableNode then
        return set(exp.name)
    end

    if exp.class == AbstractionNode then
        return remove(getFV(exp.exp), exp.var.name)
    end

    return union(getFV(exp.left), getFV(exp.right))
end

local function getBV(exp)
    if exp.class == VariableNode then
        return {}
    end

    if exp.class == AbstractionNode then
        return union(getBV(exp.exp), exp.var.name)
    end

    return union(getBV(exp.left), getBV(exp.right))
end

local function incrementVariableName(name)
    local n = name:match("[0-9]+")
    if n then
        return name:sub(1, 1) .. tostring(tonumber(n)+1)
    end

    return name .. "0"
end

local function substitute(in_exp, what_var, for_exp)
    local in_exp = in_exp:deepcopy()

    if in_exp.class == VariableNode then
        -- 2.
        if in_exp.name ~= what_var then
            return in_exp
        end

        -- 1.
        return for_exp:deepcopy()
    end

    if in_exp.class == ApplicationNode then
        -- 3.
        in_exp.left = substitute(in_exp.left, what_var, for_exp)
        in_exp.right = substitute(in_exp.right, what_var, for_exp)
        return in_exp
    end

    -- in_exp.class == AbstractionNode

    local variable = in_exp.var

    if variable.name == what_var then
        -- 4.
        return in_exp
    end

    local fvP = getFV(in_exp.exp)
    local fvN = getFV(for_exp)

    if not fvP[what_var] then
        -- 5.
        return in_exp
    end

    if not fvN[variable.name] then
        -- 6.
        in_exp.exp = substitute(in_exp.exp, what_var, for_exp)
        return in_exp
    end

    -- 7.
    local new_var_name = variable.name

    while fvN[new_var_name] or fvP[new_var_name] do
        new_var_name = incrementVariableName(new_var_name)
    end

    in_exp.var = VariableNode(new_var_name)
    in_exp.exp = substitute(substitute(in_exp.exp, variable.name, in_exp.var), what_var, for_exp)

    return in_exp
end


function Reducer:step()
    local node = self:findRedex()
    if not node then return false end

    local result = substitute(node.left.exp, node.left.var.name, node.right)


    if not node.parent then
        self.ast = result
        result.parent = nil
        return true
    end

    result.parent = node

    if node.parent.class == AbstractionNode then
        node.parent.exp = result
    else
        if node.parent.left == node then
            node.parent.left = result
        else
            node.parent.right = result
        end
    end

    return true
end

--[[
if (root == dummy) return;
print_lnr(root->left, depth + 1);
for (unsigned long long i = 0; i < depth; i++)
    std::cout << '\t';
std::cout << root->data << std::endl;
print_lnr(root->right, depth + 1);
]]

return Reducer


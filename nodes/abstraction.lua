local Node = require("nodes.base")


---@class AbstractionNode : Node
---@field var VariableNode
---@field exp Node
local AbstractionNode = class("AbstractionNode", Node)

function AbstractionNode:initialize(var, exp)
    self.var = var
    self.exp = exp
end

function AbstractionNode:deepcopy()
    local v = self.var:deepcopy()
    local e = self.exp:deepcopy()
    local n = AbstractionNode(v, e)
    v.parent = n
    e.parent = n
    n.parent = self.parent
    return n
end

function AbstractionNode:treeText()
    return "^"
end
function AbstractionNode:treePrint(depth)
    depth = depth or 0
    self.exp:treePrint(depth + 1)
    Node.treePrint(self, depth)
    self.var:treePrint(depth + 1)
end

function AbstractionNode:__tostring()
    return (self.parent and "(" or "") ..
        "^" .. tostring(self.var) .. "." .. tostring(self.exp) ..
        (self.parent and ")" or "")
end

local underline = "\27[4m"
local reset = "\27[0m"
local colorParen = require("utils.coloredparen")
function AbstractionNode:toprettytext(depth, underline_node)
    local should_underline = (underline_node == self) or (underline_node == true)
    local und = should_underline and underline or ""
    local underline_pass = should_underline and true or underline_node

    depth = depth or 0

    local dot = (self.exp.class == AbstractionNode) and "" or "."
    dot = und .. dot .. reset

    if not self.parent then
        return und .. "^" .. self.var:toprettytext(depth, underline_pass) ..
            dot .. self.exp:toprettytext(depth, underline_pass) .. reset
    end

    if self.parent.class == AbstractionNode then
        return und .. self.var:toprettytext(depth, underline_pass) ..
            dot .. self.exp:toprettytext(depth, underline_pass) .. reset
    end

    local lp = colorParen(und .. "(" .. reset, depth)
    local rp = colorParen(und .. ")" .. reset, depth)
    return lp .. und .. "^" .. self.var:toprettytext(depth + 1, underline_pass) ..
        dot .. self.exp:toprettytext(depth + 1, underline_pass) .. reset .. rp
end

return AbstractionNode


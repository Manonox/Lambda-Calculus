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
    local n = AbstractionNode(self.var:deepcopy(), self.exp:deepcopy())
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

return AbstractionNode


local Node = require("nodes.base")


---@class VariableNode : Node
---@field token Token
local VariableNode = class("VariableNode", Node)

function VariableNode:initialize(name, token)
    self.name = name
    self.token = token
end

function VariableNode:deepcopy()
    local n = VariableNode(self.name, self.token)
    n.parent = self.parent
    return n
end

function VariableNode:treeText()
    return self.name
end

function VariableNode:__tostring()
    return self.name
end

return VariableNode


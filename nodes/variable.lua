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

local underline = "\27[4m"
local reset = "\27[0m"
function VariableNode:toprettytext(depth, underline_node)
    local should_underline = (underline_node == self) or (underline_node == true)
    local und = should_underline and underline or ""

    return und .. tostring(self) .. reset
end

return VariableNode


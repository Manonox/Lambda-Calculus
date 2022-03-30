local Node = require("nodes.base")


---@class ApplicationNode : Node
---@field left Node
---@field right Node
local ApplicationNode = class("ApplicationNode", Node)

function ApplicationNode:initialize(left, right)
    self.left = left
    self.right = right
end

function ApplicationNode:deepcopy()
    local n = ApplicationNode(self.left:deepcopy(), self.right:deepcopy())
    n.parent = self.parent
    return n
end

function ApplicationNode:treeText()
    return "App"
end
function ApplicationNode:treePrint(depth)
    depth = depth or 0
    self.right:treePrint(depth + 1)
    Node.treePrint(self, depth)
    self.left:treePrint(depth + 1)
end

function ApplicationNode:__tostring()
    return (self.parent and "(" or "") ..
        tostring(self.left) .. tostring(self.right) ..
        (self.parent and ")" or "")
end

return ApplicationNode


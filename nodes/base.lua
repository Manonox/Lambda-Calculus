---@class Node
---@field parent Node
local Node = class("Node")

function Node:deepcopy()
end

function Node:treetext()
    return "Node"
end
function Node:treePrint(depth)
    depth = depth or 0
    print(string.rep("\t", depth) .. self:treeText())
end

return Node


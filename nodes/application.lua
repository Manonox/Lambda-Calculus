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
    local l = self.left:deepcopy()
    local r = self.right:deepcopy()
    local n = ApplicationNode(l, r)
    l.parent = n
    r.parent = n
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


local underline = "\27[4m"
local reset = "\27[0m"
local colorParen = require("utils.coloredparen")
function ApplicationNode:toprettytext(depth, underline_node)
    local should_underline = (underline_node == self) or (underline_node == true)
    local und = should_underline and underline or ""
    local underline_pass = should_underline and true or underline_node

    depth = depth or 0

    if not self.parent then
        return und .. self.left:toprettytext(depth, underline_pass) ..
            self.right:toprettytext(depth, underline_pass) .. reset
    end

    if self.parent.class == require("nodes.abstraction") then
        return und .. self.left:toprettytext(depth, underline_pass) ..
            self.right:toprettytext(depth, underline_pass) .. reset

    elseif self.parent.class == ApplicationNode then
        if self.parent.left == self then
            return und .. self.left:toprettytext(depth, underline_pass) ..
                self.right:toprettytext(depth, underline_pass) .. reset
        end
    end

    local lp = colorParen(und .. "(" .. reset, depth)
    local rp = colorParen(und .. ")" .. reset, depth)
    return lp .. und .. self.left:toprettytext(depth + 1, underline_pass) ..
        self.right:toprettytext(depth + 1, underline_pass) .. reset .. rp
end

return ApplicationNode


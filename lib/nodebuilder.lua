sudo()

local Node

local NodeTree = Def.ActorFrame { }

-- We can make new "nodes" with this function
local function new(obj)
    --lua.ReportScriptError('Node:New')
    local t
    if type(obj) == 'string' then
        t = { Type = obj }
    else
        t = obj or {}
    end
    setmetatable(t, Node)
    return t
end
-- We can attach a script, which will load ready() into SelfCommand and update() into UpdateMessageCommand
local function AttachScript(self, scriptpath)
    --lua.ReportScriptError('Node:AttachScript')
    local ready, update = assert(loadfile(SongDir .. scriptpath))()
    self.ReadyCommand = ready
    self.UpdateMessageCommand = update
end
-- We can detach a script, which will make our UpdateMessageCommand nil
local function DetachScript(self)
    --lua.ReportScriptError('Node:DetachScript')
    self.UpdateMessageCommand = nil
end
-- We can add it to the node tree
local function AddToNodeTree(self)
    --lua.ReportScriptError('Node:AddToNodeTree')
    table.insert(NodeTree, self)
end
-- We can remove it from the node tree
local function RemoveFromNodeTree(self)
    for i, v in ipairs(NodeTree) do
        if v == self then table.remove(NodeTree, i) end
    end
end
-- And finally we can get the node tree to see what we have in it
local function GetNodeTree()
    --lua.ReportScriptError('Node:GetNodeTree')
    return NodeTree
end
-- This would be used for extending the metatable of the node, I hope? For whatever reason...
function extends(nodeType)
end

Node = {
    new = new,
    AttachScript = AttachScript,
    DetachScript = DetachScript,
    AddToNodeTree = AddToNodeTree,
    RemoveFromNodeTree = RemoveFromNodeTree,
    GetNodeTree = GetNodeTree,
}
Node.__index = Node
return Node

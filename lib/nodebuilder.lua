sudo()

local Node
local NodeTree = Def.ActorFrame { }


local function new(obj)
    local t
    if type(obj) == 'string' then
        t = { Type = obj }
    else
        t = obj or {}
    end
    setmetatable(t, Node)
    return t
end
local function AttachScript(self, scriptpath)
    local ready, update = assert(loadfile(SongDir .. scriptpath))()
    self.ReadyCommand = function(self)
        ready(self)
    end
    self.UpdateMessageCommand = function(self)
        update(self, DT)
    end
end
local function DetachScript(self)
    self.UpdateMessageCommand = nil
end
local function AddToNodeTree(self)
    table.insert(NodeTree, self)
end
local function GetNodeTree()
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

sudo()

local Node
local NodeTree = Def.ActorFrame { }


-- This would be used for extending the metatable of the node, I hope? For whatever reason...
local function extends(self, nodeType)
end

local function new(obj)
	--Trace('Node.new')
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
	--Trace('Node:AttachScript')
	local ready, update = assert(loadfile(SongDir .. scriptpath))()
	self.ReadyCommand = function(self)
		return ready(self)
	end
	self.UpdateMessageCommand = function(self)
		return update(self, DT)
	end
end
local function SetReady(self, func)
	self.ReadyCommand = function(self)
		return func(self)
	end
end
local function SetUpdate(self, func)
	self.UpdateMessageCommand = function(self)
		return func(self, DT)
	end
end
local function AddToNodeTree(self)
	--Trace('Node:AddToNodeTree')
	setmetatable(self, Def[self.Type](self))
	table.insert(NodeTree, self)
end
local function GetNodeTree()
	--Trace('Node.GetNodeTree')
	return NodeTree
end

Node = {
	new = new,
	AttachScript = AttachScript,
	SetReady = SetReady,
	SetUpdate = SetUpdate,
	AddToNodeTree = AddToNodeTree,
	GetNodeTree = GetNodeTree
}
Node.__index = Node
return Node

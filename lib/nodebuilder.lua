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
	local ready, update, input = assert(loadfile(SongDir .. scriptpath))()
	self.ReadyCommand = function(self)
		return ready(self)
	end
	self.UpdateMessageCommand = function(self)
		return update(self, DT)
	end
	self.InputMessageCommand = function(self, args)
		return input(self, args[1])
	end
end
local function SetReady(self, func)
	--Trace('Node:SetReady')
	self.ReadyCommand = function(self)
		return func(self)
	end
end
local function SetUpdate(self, func)
	--Trace('Node:SetUpdate')
	self.UpdateMessageCommand = function(self)
		return func(self, DT)
	end
end
local function SetInput(self, func)
	self.InputMessageCommand = function(self, args)
		return func(self, args[1])
	end
end
local function AddToNodeTree(self)
	--Trace('Node:AddToNodeTree')
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
	SetInput = SetInput,
	AddToNodeTree = AddToNodeTree,
	GetNodeTree = GetNodeTree
}
Node.__index = Node
return Node

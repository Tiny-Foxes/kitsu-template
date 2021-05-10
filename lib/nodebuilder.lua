sudo()

local Node
local NodeTree = Def.ActorFrame { }


-- This would be used for extending the metatable of the node, I hope? For whatever reason...
local function extends(self, nodeType)
end

local function new(obj)
	--printerr('Node.new')
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
	--printerr('Node:AttachScript')
	kitsu = {
		ready = nil,
		update = nil,
		input = nil,
	}
	assert(loadfile(SongDir .. scriptpath))()
	local src = deepcopy(kitsu)
	self.ReadyCommand = function(self)
		if src.ready then return src.ready(self) end
	end
	self.UpdateMessageCommand = function(self)
		if src.update then return src.update(self, DT) end
	end
	self.InputMessageCommand = function(self, args)
		if src.input then return src.input(self, args[1]) end
	end
end
local function SetReady(self, func)
	--printerr('Node:SetReady')
	self.ReadyCommand = function(self)
		return func(self)
	end
end
local function SetUpdate(self, func)
	--printerr('Node:SetUpdate')
	self.UpdateMessageCommand = function(self)
		return func(self, DT)
	end
end
local function SetInput(self, func)
	--printerr('Node:SetInput')
	self.InputMessageCommand = function(self, args)
		return func(self, args[1])
	end
end
local function AddToNodeTree(self)
	--printerr('Node:AddToNodeTree')
	table.insert(NodeTree, self)
end
local function GetNodeTree()
	--printerr('Node.GetNodeTree')
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

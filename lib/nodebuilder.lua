Node = {}
local NodeTree = Def.ActorFrame { }

-- This would be used for extending the metatable of the node, I hope? For whatever reason...
local function extends(self, nodeType)
	self = Def[nodeType](self)
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
		draw = nil,
	}
	sudo(assert(loadfile(SongDir .. scriptpath)))()
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
	self.DrawMessageCommand = function(self)
		if src.draw then self:SetDrawFunction(src.draw) end
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
local function SetSRTStyle(b)
	--printerr('Node.SetSRTStyle')
	if type(b) == 'boolean' and b then
		local PP = {}
		local PJ = {}
		local PC = {}
		for pn = 1, #GAMESTATE:GetEnabledPlayers() do
			PP[pn] = Node.new('ActorProxy')
			PP[pn]:SetReady(function(self)
				self:SetTarget(PL[pn].Player)
			end)
			PJ[pn] = Node.new('ActorProxy')
			PJ[pn]:SetReady(function(self)
				self:SetTarget(PL[pn].Judgment)
				self:x(SCX * (pn-.5))
				self:y(SCY)
			end)
			PC[pn] = Node.new('ActorProxy')
			PC[pn]:SetReady(function(self)
				self:SetTarget(PL[pn].Combo)
				self:x(SCX * (pn-.5))
				self:y(SCY)
			end)
			PP[pn]:AddToNodeTree()
			PJ[pn]:AddToNodeTree()
			PC[pn]:AddToNodeTree()
		end
		SRT_STYLE = b
	elseif type(b) ~= 'boolean' then
		printerr('Node.SetSRTStyle: argument must be boolean value')
	end
end
local function GetNodeTree()
	--printerr('Node.GetNodeTree')
	return NodeTree
end

Node = {
	extends = extends,
	new = new,
	AttachScript = AttachScript,
	SetReady = SetReady,
	SetUpdate = SetUpdate,
	SetInput = SetInput,
	AddToNodeTree = AddToNodeTree,
	SetSRTStyle = SetSRTStyle,
	GetNodeTree = GetNodeTree,
}
Node.__index = Node
sudo(assert(loadfile(SongDir .. 'lua/nodes.lua')))()

return Def.ActorFrame {
	InitCommand = function(self)
	end,
	NodeTree
}

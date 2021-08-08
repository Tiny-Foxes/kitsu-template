

Node = {}

local ease_table = {}
local node_idx = 1

local function UpdateTweens()
	for i, v in ipairs(ease_table) do
		local actor
		if type(v[1]) == 'string' then
			actor = _G.sudo[v[1]]
		else
			actor = v[1]
		end
		if not actor then return end
		local func = v[7]
		if BEAT >= v[2] and BEAT < (v[2] + v[3]) then
			local ease = v[4]((BEAT - v[2]) / (v[3]))
			local amp = ease * (v[6] - v[5]) + v[5]
			actor[func](actor, amp)
		elseif BEAT >= (v[2] + v[3]) then
			actor[func](actor, v[6])
			table.remove(ease_table, i)
		end
	end
end
local NodeTree = Def.ActorFrame {
	InitCommand = function(self)
		Node.GetNodeTree = function() return self end
		Node.GetFGActor = function(this) return self:GetChild(this) end
		for k, v in pairs(self:GetChildren()) do
			_G.sudo[v:GetName()] = v
		end
	end,
}

-- This would be used for extending the metatable of the node, I hope? For whatever reason...
local function extends(self, nodeType)
	local _mt = Node
	local t = Def[nodeType](self)
	for k, v in pairs(t) do
		_mt[k] = v
	end
	setmetatable(getmetatable(self), _mt)
end

local function new(obj)
	--printerr('Node.new')
	local t
	if type(obj) == 'string' then
		t = { Type = obj }
	else
		t = obj or {}
	end
	if not t.Name then t.Name = 'Node'..node_idx end
	node_idx = node_idx + 1
	setmetatable(t, Node)
	return t
end
local function ease(t)
	if type(t) ~= 'table' then
		printerr('Node.ease: Table expected, got '..type(t))
	end
	table.insert(ease_table, t)
	return ease
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
local function Tween(self, t)
	if type(t) ~= 'table' then
		printerr('Node.ease: Table expected, got '..type(t))
	end
	table.insert(t, 1, self.Name)
	table.insert(ease_table, t)
	return self
end

local function SetName(self, name)
	self.Name = name
	_G.sudo[name] = self
	return self
end
local function SetReady(self, func)
	--printerr('Node:SetReady')
	self.ReadyCommand = function(self)
		return func(self)
	end
	return self
end
local function SetUpdate(self, func)
	--printerr('Node:SetUpdate')
	self.UpdateMessageCommand = function(self)
		return func(self, DT)
	end
	return self
end
local function SetInput(self, func)
	--printerr('Node:SetInput')
	self.InputMessageCommand = function(self, args)
		return func(self, args[1])
	end
	return self
end
local function AddToNodeTree(self, idx, name)
	--printerr('Node:AddToNodeTree')
	if type(idx) == 'string' then
		name = idx
		idx = nil
	end
	if name then self:SetName(name) end
	table.insert(NodeTree, idx or #NodeTree, self)
	return self
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
			--table.insert(NodeTree, 1, {PP, PJ, PC})
			PP[pn]:AddToNodeTree(1)
			PJ[pn]:AddToNodeTree(2)
			PC[pn]:AddToNodeTree(3)
		end
		SRT_STYLE = b
	elseif type(b) ~= 'boolean' then
		printerr('Node.SetSRTStyle: argument must be boolean value')
	end
end
local function GetNodeTree(s)
	--printerr('Node.GetNodeTree')
	return NodeTree[s] or NodeTree.FG
end

local AFTSprite = Def.Sprite {
	Name = 'MainSprite',
	InitCommand = function(self)
		Node.AFT = self
		Node.ease = ease
		self:Center():diffusealpha(0)
	end,
}

local af = Def.ActorFrame {
	ReadyCommand = function(self)
		local mainA = self:GetChild('MainAFT')
		local mainS = mainA:GetChild('MainSprite')
		local actorS = self:GetChild('ShowActors')
		local recA = self:GetChild('RecursiveAFT')
		local recS = recA:GetChild('RecursiveSprite')

		actorS:SetTexture(mainA:GetTexture())
		recS:SetTexture(mainA:GetTexture())
		mainS:SetTexture(recA:GetTexture())
	end,
	UpdateMessageCommand = function(self)
		UpdateTweens()
	end,
	Def.ActorFrameTexture {
		Name = 'MainAFT',
		InitCommand = function(self)
			self
				:SetSize(SW, SH)
				:EnableFloat(false)
				:EnableDepthBuffer(true)
				:EnableAlphaBuffer(true)
				:EnablePreserveTexture(false)
				:Create()
		end,
		LoadActor(THEME:GetPathG('Common', 'fallback background')),
		AFTSprite,
		NodeTree,
	},
	Def.ActorFrameTexture {
		Name = 'RecursiveAFT',
		InitCommand = function(self)
			self
				:SetSize(SW, SH)
				:EnableFloat(false)
				:EnableDepthBuffer(true)
				:EnableAlphaBuffer(false)
				:EnablePreserveTexture(true)
				:Create()
		end,
		Def.Sprite {
			Name = 'RecursiveSprite',
			InitCommand = function(self) self:Center() end,
		},
	},
	Def.Sprite {
		Name = 'ShowActors',
		InitCommand = function(self) self:Center() end,
	},
}

Node = {
	extends = extends,
	new = new,
	ease = ease,
	AttachScript = AttachScript,
	Tween = Tween,
	SetName = SetName,
	SetReady = SetReady,
	SetUpdate = SetUpdate,
	SetInput = SetInput,
	AddToNodeTree = AddToNodeTree,
	SetSRTStyle = SetSRTStyle,
	GetNodeTree = GetNodeTree,
	GetActor = function(this) printerr('Node.GetActor: Function not available before ready()') end,
	AFT = AFTSprite,
}
Node.__index = Node
sudo(assert(loadfile(SongDir .. 'lua/nodes.lua')))()

return af

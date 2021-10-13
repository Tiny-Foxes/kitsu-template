-- nodebuilder.lua --

Node = {}

local ease_table = {}
local func_table = {}
local msg_table = {}

local node_idx = 1

local function UpdateEases()
	for i, v in ipairs(ease_table) do
		local actor
		if type(v[1]) == 'string' then
			actor = _G.sudo[v[1]]
		else
			actor = v[1]
		end
		if not actor then
			printerr('Cannot find actor ('..tostring(v[1])..')')
			table.remove(ease_table, i)
			return
		end
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
local function UpdateFuncs()
	for i, v in ipairs(func_table) do
		local actor
		if type(v[1]) == 'string' then
			actor = _G.sudo[v[1]]
		else
			actor = v[1]
		end
		local func = v[7]
		if type(func) ~= 'function' then return end
		if BEAT >= v[2] and BEAT < (v[2] + v[3]) then
			local ease = v[4]((BEAT - v[2]) / v[3]) - v[5]
			local amp = ease * (v[6] - v[5])
			if actor then func(actor, amp) else func(amp) end
		elseif BEAT >= (v[2] + v[3]) then
			if actor then func(actor, v[6]) else func(v[6]) end
			table.remove(func_table, i)
		end
	end
end
local function UpdateSignals()
	for i, v in ipairs(msg_table) do
		local msg = v[2]
		if BEAT >= v[1] then
			MESSAGEMAN:Broadcast(msg)
			table.remove(msg_table, i)
		end
	end
end

local NodeTree = Def.ActorFrame {
	InitCommand = function(self)
		Node.GetNodeTree = function() return self end
		Node.GetActor = function(self, this) return self:GetChild(this) end
		local function NameActors(self)
			for i = 1, self:GetNumChildren() do
				local this = self:GetChildAt(i)
				_G.sudo[this:GetName()] = this
				if this.GetChildren then NameActors(this) end
			end
		end
		NameActors(self)
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
	--print('Node.new')
	local t
	if type(obj) == 'string' then
		t = { Type = obj }
		if obj == 'BitmapText' then t.Font = 'Common Normal' end
	else
		t = obj or {}
	end
	if not t.Name then t.Name = 'Node'..node_idx end
	node_idx = node_idx + 1
	setmetatable(t, Node)
	return t
end
local function FromFile(path)
	local t = sudo(assert(loadfile(SongDir..'lua/'..path..'.lua')))()
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
local function func(t)
	if type(t) ~= 'table' then
		printerr('Node.ease: Table expected, got '..type(t))
	end
	table.insert(func_table, t)
	return func
end

local function signal(t)
	if type(t) ~= 'table' then
		printerr('Node.ease: Table expected, got '..type(t))
	end
	table.insert(msg_table, t)
	return signal
end

local function AttachScript(self, scriptpath)
	--print('Node:AttachScript')
	kitsu = {
		ready = nil,
		update = nil,
		input = nil,
		draw = nil,
	}
	sudo(assert(loadfile(SongDir .. scriptpath .. '.lua')))()
	local src = DeepCopy(kitsu)
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
local function AddEase(self, t)
	if type(t) ~= 'table' then
		printerr('Node.AddEase: Table expected, got '..type(t))
		return
	end
	if self.Name == '' then
		printerr('Node.AddEase: Node name is blank')
		return
	end
	table.insert(t, 1, self.Name)
	table.insert(ease_table, t)
	return self
end
local function AddFunc(self, t)
	if type(t) ~= 'table' then
		printerr('Node.AddEase: Table expected, got '..type(t))
		return
	end
	if self.Name == '' then
		printerr('Node.AddEase: Node name is blank')
		return
	end
	table.insert(t, 1, self.Name)
	table.insert(func_table, t)
	return self
end

local function SetName(self, name)
	self.Name = name
	--_G.sudo[name] = self
	return self
end
local function SetTexture(self, path)
	if self.Type ~= 'Sprite' then
		printerr('Node.SetTexture: Cannot set texture of type'..self.Type)
		return
	end
	self.Texture = path
	return self
end
local function SetReady(self, func)
	--print('Node:SetReady')
	self.ReadyCommand = function(self)
		return func(self)
	end
	return self
end
local function SetUpdate(self, func)
	--print('Node:SetUpdate')
	self.UpdateMessageCommand = function(self)
		return func(self, DT)
	end
	return self
end
local function SetInput(self, func)
	--print('Node:SetInput')
	self.InputMessageCommand = function(self, args)
		return func(self, args[1])
	end
	return self
end
local function SetCommand(self, name, func)
	--print('Node:SetCommand')
	if type(func) ~= 'function' then
		printerr('Node.SetCommand: Invalid argument #2 (expected function, got '..type(func)..')')
		return
	end
	self[name..'Command'] = function(self)
		return func(self)
	end
	return self
end
local function GetCommand(self, name)
	--print('Node:GetCommand')
	return self[name..'Command']
end
local function SetMessage(self, name, func)
	--print('Node:SetMessage')
	if type(func) ~= 'function' then
		printerr('Node.SetMessage: Invalid argument #2 (expected function, got '..type(func)..')')
		return
	end
	self[name..'MessageCommand'] = function(self)
		return func(self)
	end
	return self
end
local function GetMessage(self, name)
	--print('Node:GetMessage')
	return self[name..'MessageCommand']
end
local function SetAttribute(self, attr, val)
	--print('Node:SetAttribute')
	self[attr] = val
	return self
end
local function GetAttribute(self, attr)
	--print('Node:GetAttribute')
	return self[attr]
end
local function AddChild(self, child, idx, name)
	--print('Node:AddChild')
	if self.Type ~= 'ActorFrame' and self.Type ~= 'ActorFrameTexture' then
		printerr('Node.AddChild: Cannot add child to type '..self.Type)
		return
	end
	if type(idx) == 'string' then
		name = idx
		idx = nil
	end
	if name then child:SetName(name) end
	child = Def[child.Type](child)
	if idx then
		table.insert(self, idx, child)
	else
		table.insert(self, child)
	end
	return self
end
local function GetChildIndex(self, name)
	--print('Node:GetChildIndex')
	if self.Type ~= 'ActorFrame' and self.Type ~= 'ActorFrameTexture' then
		printerr('Node.AddChild: Cannot add child to type '..self.Type)
		return
	end
	for i, v in ipairs(self) do
		if v.Name == name then
			return i
		end
	end
end
local function AddToNodeTree(self, idx, name)
	--print('Node:AddToNodeTree')
	if type(idx) == 'string' then
		name = idx
		idx = nil
	end
	if name then
		self:SetName(name)
	end
	if idx then
		table.insert(NodeTree, idx, self)
	else
		table.insert(NodeTree, self)
	end
	return self
end
local function HideOverlay(b)
	--print('Node.HideOverlay')
	if type(b) == 'boolean' and b then
		SRT_STYLE = b
	elseif type(b) ~= 'boolean' then
		printerr('Node.HideOverlay: argument must be boolean value')
	end
end
local function GetNodeTree()
	--print('Node.GetNodeTree')
	return NodeTree
end

Node = {
	extends = extends,
	new = new,
	FromFile = FromFile,
	ease = ease,
	func = func,
	signal = signal,
	AttachScript = AttachScript,
	AddEase = AddEase,
	AddFunc = AddFunc,
	SetName = SetName,
	SetTexture = SetTexture,
	SetReady = SetReady,
	SetUpdate = SetUpdate,
	SetInput = SetInput,
	SetCommand = SetCommand,
	SetMessage = SetMessage,
	SetAttribute = SetAttribute,
	AddChild = AddChild,
	GetChildIndex = GetChildIndex,
	AddToNodeTree = AddToNodeTree,
	HideOverlay = HideOverlay,
	GetNodeTree = GetNodeTree,
	GetActor = function(this) printerr('Node.GetActor: Function not available before ready()') end,
	AFT = AFTSprite,
}
Node.__index = Node
run 'lua/nodes'

return Def.ActorFrame {
	InitCommand = function(self)
		Node.ease = ease
		Node.AddEase = AddEase
	end,
	NodeTree,
}

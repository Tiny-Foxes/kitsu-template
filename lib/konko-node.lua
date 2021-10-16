-- konko-node.lua --

---------------------------
--	Node.new(type) - Creates a new Node
--	Node.FromFile(path) - Loads an Actor from a file
--	Node.ease({actor, start, len, ease, amt1, amt2, property}, ...) - Eases an Actor property
--	Node.func({start, len, ease, amt, amt2, function}, ...) - Eases a function
--	Node.signal({beat, message}, ...) - Broadcasts a message command
--	Node.HideOverlay(hide) - Sets hiding of overlay at the start of the file
--	Node.GetNodeTree() - Gets NodeTree
--	Node:AttachScript(path) - Attaches a script with init, ready, update, and input functions
--	Node:SetAttribute(attr, value) - Sets an attribute of a Node
--	Node:SetCommand(cmd, function) - Sets the command of a Node
--	Node:GetCommand(cmd) - Gets the command of a Node
--	Node:SetMessage(msg, function) - Sets the message command of a Node
--	Node:GetMessage(msg) - Gets the message command of a Node
--	Node:AddChild(node, index, name) - Adds a child to a Node (Must inherit ActorFrame)
--	Node:AddToNodeTree(name, index) - Adds a Node to the NodeTree (Name and index can be in any order)
---------------------------
local std = import 'stdlib'

local Node = {}

local ease_table = {}
local func_table = {}
local msg_table = {}

local node_idx = 1

local function UpdateEases()
	local BEAT = std.BEAT()
	for i, v in ipairs(ease_table) do
		local actor
		if type(v[1]) == 'string' then
			actor = _G.sudo[v[1]]
		else
			actor = v[1]
		end
		if not actor then
			std.printerr('Cannot find actor ('..tostring(v[1])..')')
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
	local BEAT = std.BEAT()
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
			local ease = v[4]((BEAT - v[2]) / v[3])
			local amp = ease * (v[6] - v[5]) + v[5]
			if actor then func(actor, amp) else func(amp) end
		elseif BEAT >= (v[2] + v[3]) then
			if actor then func(actor, v[6]) else func(v[6]) end
			table.remove(func_table, i)
		end
	end
end
local function UpdateSignals()
	local BEAT = std.BEAT()
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
		local s = self
		Node.GetNodeTree = function() return s end
		Node.GetActor = function(this) return s:GetChild(this) end
		local function NameActors(actor)
			for i = 1, actor:GetNumChildren() do
				local this = actor:GetChildAt(i)
				_G.sudo[this:GetName()] = this
				if this.GetChildren then NameActors(this) end
			end
		end
		NameActors(s)
		print('NodeTree')
	end,
	UpdateMessageCommand = function(self)
		UpdateEases()
		UpdateFuncs()
		UpdateSignals()
	end,
}

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
	local t = run('lua/'..path)
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
		init = nil,
		ready = nil,
		update = nil,
		input = nil,
	}
	run(scriptpath)
	local src = DeepCopy(kitsu)
	self.InitCommand = function(self)
		if src.init then src.init(self) end
	end
	self.ReadyCommand = function(self)
		if src.ready then return src.ready(self) end
	end
	self.UpdateMessageCommand = function(self, param)
		if src.update then return src.update(self, param[1]) end
	end
	self.InputMessageCommand = function(self, param)
		if src.input then return src.input(self, param[1]) end
	end
	kitsu = nil
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
local function SetInit(self, func)
	--print('Node:SetInit')
	return self:SetCommand('Init', func)
end
local function SetReady(self, func)
	--print('Node:SetReady')
	return self:SetCommand('Ready', func)
end
local function SetUpdate(self, func)
	--print('Node:SetUpdate')
	self.UpdateMessageCommand = function(self)
		return func(self, std.DT)
	end
	return self
end
local function SetInput(self, func)
	--print('Node:SetInput')
	self.InputMessageCommand = function(self, param)
		return func(self, param[1])
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
local function GetOverlay()
	local ret = {}
	ret[#ret + 1] = SCREEN:GetChild('Underlay')
	for i = 1, #std.PL do
		ret[#ret + 1] = std.PL[i].Life
		ret[#ret + 1] = std.PL[i].Score
	end
	ret[#ret + 1] = SCREEN:GetChild('Overlay')
	return ret
end
local function HideOverlay(b)
	--print('Node.HideOverlay')
	if type(b) == 'boolean' then
		for _, v in ipairs(GetOverlay()) do
			v:visible(tobool(not b))
		end
	else
		printerr('Node.HideOverlay: argument must be boolean value')
	end
end
local function GetNodeTree()
	--print('Node.GetNodeTree')
	return NodeTree
end

Node = {
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
	SetInit = SetInit,
	SetReady = SetReady,
	SetUpdate = SetUpdate,
	SetInput = SetInput,
	SetCommand = SetCommand,
	SetMessage = SetMessage,
	SetAttribute = SetAttribute,
	AddChild = AddChild,
	GetChildIndex = GetChildIndex,
	AddToNodeTree = AddToNodeTree,
	GetOverlay = GetOverlay,
	HideOverlay = HideOverlay,
	GetNodeTree = GetNodeTree,
	GetActor = function(this) printerr('Node.GetActor: Function not available before ready()') end,
}
Node.__index = Node

FG[#FG + 1] = NodeTree

print('Loaded Konko Node')
return Node

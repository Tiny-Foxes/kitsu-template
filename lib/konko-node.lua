-- konko-node.lua --

---------------------------
--	Node.new(type) - Creates a new Node
--	Node.FromFile(path) - Loads an Actor from a file
--	Node.ease({actor, start, len, ease, amt1, amt2, property}, ...) - Eases an Actor property
--	Node.func({start, len, ease, amt, amt2, function}, ...) - Eases a function
--	Node.signal({beat, message}, ...) - Broadcasts a message command
--	Node.HideOverlay(hide) - Sets hiding of overlay at the start of the file
--	Node.GetTree() - Gets NodeTree
--	Node:AttachScript(path) - Attaches a script with init, ready, update, and input functions
--	Node:SetAttribute(attr, value) - Sets an attribute of a Node
--	Node:SetCommand(cmd, function) - Sets the command of a Node
--	Node:GetCommand(cmd) - Gets the command of a Node
--	Node:SetMessage(msg, function) - Sets the message command of a Node
--	Node:GetMessage(msg) - Gets the message command of a Node
--	Node:AddChild(node, index, name) - Adds a child to a Node (Must inherit ActorFrame)
--	Node:AddToTree(name, index) - Adds a Node to the NodeTree (Name and index can be in any order)
---------------------------
local std = import 'stdlib'

local Node = {}

-- Version number
local VERSION = '1.1'

local env = getfenv(2)

local ease_table = {}
local func_table = {}
local msg_table = {}

local node_idx = 1

-- These run every frame. They update the eases, functions, and signals.
local function UpdateEases()
	local BEAT = std.BEAT
	for i, v in ipairs(ease_table) do
		local actor
		if type(v[1]) == 'string' then
			actor = env[v[1]]
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
	local BEAT = std.BEAT
	for i, v in ipairs(func_table) do
		local actor
		if type(v[1]) == 'string' then
			actor = env[v[1]]
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
	local BEAT = std.BEAT
	for i, v in ipairs(msg_table) do
		local msg = v[2]
		if BEAT >= v[1] then
			MESSAGEMAN:Broadcast(msg)
			table.remove(msg_table, i)
		end
	end
end

local function GetActor(this)
	for i, v in ipairs(Node.GetTree()) do
		if v.Name == this then return v end
	end
end
local NodeTree = Def.ActorFrame {
	InitCommand = function(self)
		local s = self
		Node.GetTree = function() return s end
		Node.GetActor = function(this) return s:GetChild(this) end
		local function NameActors(actor)
			for i = 1, actor:GetNumChildren() do
				local this = actor:GetChildAt(i)
				env[this:GetName()] = this
				if this.GetChildren then NameActors(this) end
			end
		end
		NameActors(s)
	end,
	ReadyCommand = function(self)
		self:queuecommand('Node')
	end,
	UpdateMessageCommand = function(self)
		UpdateEases()
		UpdateFuncs()
		UpdateSignals()
	end,
}

local function new(obj, len, pat)
	--print('Node.new')
	local t
	if type(obj) == 'string' then
		t = { Type = obj }
		if obj == 'BitmapText' then t.Font = 'Common Normal' end
	else
		t = obj or {}
	end
	if t.Type == 'ProxyWall' then
		local rotframe = Node.new('ActorFrame')
		rotframe.IsProxyWall = true
		return rotframe
	end
	if not t.Name then t.Name = 'Node'..node_idx end
	node_idx = node_idx + 1
	setmetatable(t, Node)
	return t
end
local function FromFile(path)
	--print('Node.FromFile')
	local t = run('lua/'..path)
	if not t.Name then t.Name = 'Node'..node_idx end
	node_idx = node_idx + 1
	setmetatable(t, Node)
	return t
end
local function ease(t)
	--print('Node.ease')
	if type(t) ~= 'table' then
		printerr('Node.ease: Table expected, got '..type(t))
	end
	table.insert(ease_table, t)
	return ease
end
local function func(t)
	--print('Node.func')
	if type(t) ~= 'table' then
		printerr('Node.ease: Table expected, got '..type(t))
	end
	table.insert(func_table, t)
	return func
end

local function signal(t)
	--print('Node.signal')
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
	--print('Node:AddEase')
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
	--print('Node:AddFunc')
	if type(t) ~= 'table' then
		printerr('Node.AddEase: Table expected, got '..type(t))
		return
	end
	if self.Name == '' then
		printerr('Node.AddEase: Node name cannot be blank')
		return
	end
	table.insert(t, 1, self.Name)
	table.insert(func_table, t)
	return self
end

local function SetName(self, name)
	--print('Node:SetName')
	self.Name = name
	--env[name] = self
	return self
end
local function SetTexture(self, path)
	--print('Node:SetTexture')
	if self.Type ~= 'Sprite' then
		printerr('Node.SetTexture: Cannot set texture of type '..self.Type)
		return
	end
	self.Texture = std.DIR..'lua/'..path
	return self
end
local function SetFont(self, font)
	--print('Node:SetFont')
	if self.Type ~= 'BitmapText' then
		printerr('Node.SetFont: Cannot set font of type '..self.Type)
		return
	end
	self.Font = font
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
	self.UpdateCommand = function(self)
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
local function SetCommand(self, name, func)
	--print('Node:SetCommand')
	if type(func) ~= 'function' then
		printerr('Node.SetCommand: Invalid argument #2 (expected function, got '..type(func)..')')
		return
	end
	if name == 'Node' then
		printerr('Node.SetCommand: Forbidden command "Node"')
		return
	end
	self[name..'Command'] = function(self)
		func(self)
	end
	return self
end
local function GetCommand(self, name)
	--print('Node:GetCommand')
	return self[name..'Command']
end
local function SetSignal(self, name, func)
	--print('Node:SetSignal')
	if type(func) ~= 'function' then
		printerr('Node.SetSignal: Invalid argument #2 (expected function, got '..type(func)..')')
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
	if attr == 'Texture' then val = std.DIR..'lua/'..val end
	self[attr] = val
	return self
end
local function GetAttribute(self, attr)
	--print('Node:GetAttribute')
	return self[attr]
end
local function SetDraw(self, func)
	if self.Type ~= 'ActorFrame' and self.Type ~= 'ActorFrameTexture' then
		printerr('Node.SetDraw: Cannot set draw function of type '..self.Type)
		return
	end
	local ready = FG.ReadyCommand
	FG.ReadyCommand = function(this)
		local self = self
		local func = func
		ready(this)
		self:SetDrawFunction(func)
	end
	return self
end

-- ActorFrame
local function AddChild(self, child, idx, name)
	--print('Node:AddChild')
	if self.Type ~= 'ActorFrame' and self.Type ~= 'ActorFrameTexture' then
		printerr('Node.AddChild: Cannot add child to type '..self.Type)
		return
	end
	if child.IsProxyWall then
		ConfigWall(child)
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
	print('Node:GetChildIndex')
	if self.Type ~= 'ActorFrame' and self.Type ~= 'ActorFrameTexture' then
		printerr('Node.GetChildIndex: Cannot add child to type '..self.Type)
		return
	end
	for i, v in ipairs(self) do
		if v.Name == name then
			return i
		end
	end
end

-- ProxyWall
local function ConfigWall(self)
	if not self.IsProxyWall then
		printerr('Node.ConfigWall: Cannot config proxy wall of type '..self.Type)
		return
	end
	local len = self.Length or math.ceil(std.SW * 1.5 / 256)
	local pat = self.Pattern or {1, 2}
	--local rotframe = Node.new('ActorFrame')
	--rotframe.IsProxyWall = true
	for idx, _ in ipairs(self) do
		table.remove(self, idx)
	end
	local proxyframe = Node.new('ActorFrame')
	proxyframe.NodeCommand = function(self)
		self:GetParent()
			:Center()
			:fov(70)
			:rotafterzoom(false)
	end
	proxyframe.UpdateCommand = function(self)
		local rot = self:GetParent()
		local pos = {
			x = rot:GetX() - std.SCX,
			y = rot:GetY() - std.SCY,
			z = rot:GetZ(),
		}
		self:x(self:GetX() + pos.x)
		self:y(self:GetY() + pos.y)
		self:z(self:GetZ() + pos.z)
		rot:Center()
		rot:z(0)
	end
	for i = 1, len do
		-- Scaling all of this sucked. Be thankful. ~Sudo
		local width = (std.COLNUM * (64))
		local px = -(len * width * 0.75) + (width * i)
		px = px * (std.SH / 480)
		local proxy = proxyframe[i] or Node.new('ActorProxy')
		proxy.NodeCommand = function(self)
			self:GetParent()
				:fov(70)
				:rotafterzoom(false)
			local pn = pat[((i - 1) % #pat) + 1]
			local plr = std.PL[pn].Player
			self
				:SetTarget(plr:GetChild('NoteField'))
				:basezoom(std.SH / 480)
				:x(px)
				:rotafterzoom(false)
		end
		proxy.UpdateCommand = function(self)
			local pn = pat[((i - 1) % #pat) + 1]
			local wall = self:GetParent()
			local wx = wall:GetX() / wall:GetZoom()
			local offx = math.floor((wx / width / (std.SH / 480)) / #pat) * width * #pat * (std.SH / 480)
			wall:x(wall:GetX() - offx)
		end
		proxyframe:AddChild(proxy)
	end
	self:AddChild(proxyframe)
	return self
end
local function SetNumProxies(self, len)
	if not self.IsProxyWall then
		printerr('Node.SetNumProxies: Cannot set number of proxies for type'..self.Type)
		return
	end
	if type(len) ~= 'number' then
		printerr('Node.SetNumProxies: Length must be a number')
		return
	end
	self.Length = math.ceil(len)
	self = ConfigWall(self)
	return self
end
local function SetPattern(self, pat)
	if not self.IsProxyWall then
		printerr('Node.SetPattern: Cannot set proxy pattern for type'..self.Type)
		return
	end
	if type(pat) ~= 'table' then
		printerr('Node.SetPattern: Pattern must be table containing player sequence')
		return
	end
	self.Pattern = pat
	self = ConfigWall(self)
	return self
end

local function HideOverlay(b)
	if not SCREENMAN:GetTopScreen().HideGameplayElements then return end
	if b == nil then
		printerr('Node.HideOverlay: Must have boolean argument')
		return
	elseif type(b) ~= 'boolean' then
		printerr('Node.HideOverlay: Argument must be boolean')
		return
	end
	if b then
		SCREENMAN:GetTopScreen():HideGameplayElements()
	end
end
local function AddToTree(self, idx, name)
	--print('Node:AddToTree')
	if type(idx) == 'string' then
		name = idx
		idx = nil
	end
	if name then
		self:SetName(name)
	end
	if self.IsProxyWall then
		self = ConfigWall(self)
	end
	if idx then
		table.insert(NodeTree, idx, self)
	else
		table.insert(NodeTree, self)
	end
	return self
end
local function GetTree()
	--print('Node.GetTree')
	return NodeTree
end

Node = {
	VERSION = VERSION,
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
	SetFont = SetFont,
	SetInit = SetInit,
	SetReady = SetReady,
	SetUpdate = SetUpdate,
	SetInput = SetInput,
	SetCommand = SetCommand,
	SetSignal = SetSignal,
	SetMessage = SetSignal,
	SetAttribute = SetAttribute,
	SetDraw = SetDraw,
	AddChild = AddChild,
	GetChildIndex = GetChildIndex,
	SetNumProxies = SetNumProxies,
	SetPattern = SetPattern,
	HideOverlay = HideOverlay,
	AddToTree = AddToTree,
	GetTree = GetTree,
	GetActor = GetActor,
}
Node.__index = Node

print('Loaded Konko Node v'..Node.VERSION)
return Node

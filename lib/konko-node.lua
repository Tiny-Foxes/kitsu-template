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
depend ('konko-node', std, 'stdlib')

Node = {}

-- Version and author
local VERSION = '1.4'
local AUTHOR = 'Sudospective'

local env = getfenv(2)

local ease_table = {}
local func_table = {}
local msg_table = {}

local active_ease, active_func, active_msg = {}, {}, {}

local node_idx = 1

-- From the Mirin template. It just works? Fuck me... ~Sudo
local function insertion_sort(t, l, h, c)
	for i = l + 1, h do
		local k = l
		local v = t[i]
		for j = i, l + 1, -1 do
			if c(v, t[j - 1]) then
				t[j] = t[j - 1]
			else
				k = j
				break
			end
		end
		t[k] = v
	end
end
local function merge(t, b, l, m, h, c)
	if c(t[m], t[m + 1]) then
		return
	end
	local i, j, k
	i = 1
	for j = l, m do
		b[i] = t[j]
		i = i + 1
	end
	i, j, k = 1, m + 1, l
	while k < j and j <= h do
		if c(t[j], b[i]) then
			t[k] = t[j]
			j = j + 1
		else
			t[k] = b[i]
			i = i + 1
		end
		k = k + 1
	end
	for k = k, j - 1 do
		t[k] = b[i]
		i = i + 1
	end
end
local magic_number = 12
local function merge_sort(t, b, l, h, c)
	if h - l < magic_number then
		insertion_sort(t, l, h, c)
	else
		local m = math.floor((l + h) / 2)
		merge_sort(t, b, l, m, c)
		merge_sort(t, b, m + 1, h, c)
		merge(t, b, l, m, h, c)
	end
end
local function default_comparator(a, b) return a < b end
local function flip_comparator(c) return function(a, b) return c(b, a) end end
local function stable_sort(t, c)
	if not t[2] then return t end
	c = c or default_comparator
	local n = t.n
	local b = {}
	b[math.floor((n + 1) / 2)] = t[1]
	merge_sort(t, b, 1, n, c)
	return t
end

-- Helper function for ModPlayer
local function metric(str)
	return tonumber(THEME:GetMetric('Player', str))
end

-- These run every frame. They update the eases, functions, and signals.
local function UpdateEases()
	local BEAT = std.BEAT
	for i, v in ipairs(active_ease) do
		local actor
		if type(v[1]) == 'string' then
			actor = env[v[1]]
		else
			actor = v[1]
		end
		local func = v[7]
		if BEAT >= v[2] and BEAT < (v[2] + v[3]) then
			local ease = v[4]((BEAT - v[2]) * OFMath.oneoverx(v[3]))
			local amp = ease * (v[6] - v[5]) + v[5]
			actor[func](actor, amp)
		elseif BEAT >= (v[2] + v[3]) then
			actor[func](actor, v[6])
			--table.remove(ease_table, i)
		end
	end
end
local function UpdateFuncs()
	local BEAT = std.BEAT
	for i, v in ipairs(active_func) do
		local actor
		if type(v[1]) == 'string' then
			actor = env[v[1]]
		else
			actor = v[1]
		end
		local func = v[7]
		if not func then func = v[4] end
		if type(func) ~= 'function' then return end
		if BEAT >= v[2] and BEAT < v[2] + (v[3] or 0) then
			local amp
			if #v > 4 then
				local ease = v[4]((BEAT - v[2]) * OFMath.oneoverx(v[3]))
				amp = ease * (v[6] - v[5]) + v[5]
			else
				amp = 0
			end
			if actor then func(actor, amp) else func(amp) end
		elseif BEAT >= v[2] + (v[3] or 0) then
				local amp = (#v > 4 and v[6]) or 1
				if actor then func(actor, amp) else func(amp) end
				--table.remove(func_table, i)
		end
	end
end
local function UpdateSignals()
	local BEAT = std.BEAT
	for i, v in ipairs(active_msg) do
		local msg = v[2]
		local params = v[3] or {}
		if BEAT >= v[1] then
			MESSAGEMAN:Broadcast(msg, params)
			--table.remove(msg_table, i)
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
		local compare = function(a, b)
			return a[2] < b[2]
		end
		func_table.n = #func_table
		ease_table.n = #ease_table
		msg_table.n = #msg_table
		stable_sort(func_table, compare)
		stable_sort(ease_table, compare)
		stable_sort(msg_table, function(a, b)
			return a[1] < b[1]
		end)
		local s = self
		Node.GetTree = function() return s end
		Node.GetActor = function(this) return s:GetChild(this) end
		local function NameActors(actor)
			for i = 1, actor:GetNumChildren() do
				local this = actor:GetChildAt(i)
				local name = this:GetName()
				if name:find('%.D') then
					this:name(name:sub(1, -3))
					env[this:GetName()] = this
				end
				if this.GetChildren then NameActors(this) end
			end
		end
		NameActors(s)
	end,
	OnCommand = function(self)
		self:playcommand('Node')
	end,
	UpdateCommand = function(self)
		active_ease, active_func, active_msg = {}, {}, {}
		for v in ivalues(func_table) do
			if std.BEAT >= v[2] then
				table.insert(active_func, v)
			end
		end
		for v in ivalues(ease_table) do
			if std.BEAT >= v[2] then
				table.insert(active_ease, v)
			end
		end
		for v in ivalues(msg_table) do
			if std.BEAT >= v[1] then
				table.insert(active_msg, v)
			end
		end
		UpdateFuncs()
		UpdateEases()
		UpdateSignals()
		for i, v in ipairs(func_table) do
			if std.BEAT >= v[2] + v[3] then
				table.remove(func_table, i)
			end
		end
		for i, v in ipairs(ease_table) do
			if std.BEAT >= v[2] + v[3] then
				table.remove(ease_table, i)
			end
		end
		for i, v in ipairs(msg_table) do
			if std.BEAT >= v[1] then
				table.remove(msg_table, i)
			end
		end
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
	if t.Type == 'ModPlayer' then
		local plr = Node.new('ActorFrame')
		plr.IsModPlayer = true
		plr
			:SetAttribute('FOV', 45)
		local nf = Node.new('NoteField')
		nf
			:SetAttribute('DrawDistanceAfterTargetsPixels', metric 'DrawDistanceAfterTargetsPixels')
			:SetAttribute('DrawDistanceBeforeTargetsPixels', metric 'DrawDistanceBeforeTargetsPixels')
			:SetAttribute('YReverseOffsetPixels', metric 'ReceptorArrowsYReverse' - metric 'ReceptorArrowsYStandard')
		plr.NoteField = nf
		plr.NodeCommand = function(self)
			local po = self:GetChild('NoteField'):GetPlayerOptions('ModsLevel_Current')
			local vanishx = self.vanishpointx
			local vanishy = self.vanishpointy
			function self:vanishpointx(n)
				local offset = scale(po:Skew(), 0, 1, self:GetX(), SCX)
				vanishx(self, offset + n)
				return self
			end
			function self:vanishpointy(n)
				local offset = SCY
				vanishy(self, offset + n)
				return self
			end
			function self:vanishpoint(x, y)
				return self:vanishpointx(x):vanishpointy(y)
			end
			local nfmid = (metric 'ReceptorArrowsYStandard' + metric 'ReceptorArrowsYReverse') / 2
			self
				:Center()
				:zoom(std.SH / 480)
			self:GetChild('NoteField')
				:y(nfmid)
				
		end
		nf:SetName('NoteField')
		table.insert(plr, nf)
		return plr
	elseif t.Type == 'ActorProxyWall' then
		local width = std.PLRWIDTH[1] * SH / 480
		t.Length = t.Length or math.ceil(std.SW * 1.5 / width)
		t.Pattern = t.Pattern or {1, 2}
		t.Spacing = t.Spacing or 0
		local len = t.Length
		local spacing = t.Spacing
		local pwall = Node.new('ActorScroller')
			:SetAttribute('UseScroller', true)
			:SetAttribute('SecondsPerItem', 0)
			:SetAttribute('NumItemsToDraw', len)
			:SetAttribute('ItemPaddingStart', 0)
			:SetAttribute('ItemPaddingEnd', 0)
			:SetAttribute('TransformFunction', function(self, offset, itemIndex, numItems)
				self:x((offset + ((len - 1) % 2) * 0.5) * width * (1 + (spacing * 0.01)))
			end)
		for v in ivalues(t.Pattern) do
			-- Scaling all of this sucked. Be thankful. ~Sudo
			local proxy = Node.new('ActorProxy')
			proxy.NodeCommand = function(p)
				local pn = v
				if not std.PL[pn] then
					p:sleep(p:GetEffectDelta()):queuecommand('Node')
					return
				end
				local plr = std.PL[pn].Player
				p
					:SetTarget(plr:GetChild('NoteField'))
					:basezoom(std.SH / 480)
					:rotafterzoom(false)
			end
			pwall:AddChild(proxy)
		end
		pwall.IsProxyWall = true
		return pwall
	elseif t.Type == 'ActorCamera' then
		local camRot = Node.new('ActorFrame')
		camRot.IsCamera = true
		local camPivot = Node.new('ActorFrame')
		local camPos = Node.new('ActorFrame')
		local camBG = Node.new('ActorFrame')
		local camFG = Node.new('ActorFrame')
		camPos.NodeCommand = function(pos)
			local pivot = pos:GetParent()
			local rot = pivot:GetParent()
			rot.CamFOV = 60
			local function fixfov(fov)
				return 360 / math.pi * math.atan(math.tan(math.pi * fov / 360) * SW / SH * 0.75)
			end
			local function calcoffset(fov)
				return SCX / math.tan(math.rad(fixfov(fov) / 2))
			end
			function rot:x(x)
				pos:x(x - SCX)
				Actor.x(self, SCX)
				return self
			end
			function rot:y(y)
				pos:y(y - SCY)
				Actor.y(self, SCY)
				return self
			end
			function rot:z(z)
				pivot:z(z - calcoffset(self.CamFOV))
				Actor.z(self, calcoffset(self.CamFOV))
				return self
			end
			function rot:xy(x, y)
				self:x(x):y(y)
				return self
			end
			function rot:xyz(x, y, z)
				self:xy(x, y):z(z)
				return self
			end
			function rot:Center()
				self:xy(SCX, SCY)
				return self
			end
			function rot:GetX()
				return pos:GetX()
			end
			function rot:GetY()
				return pos:GetY()
			end
			function rot:GetZ()
				return pivot:GetZ() + calcoffset(self.CamFOV)
			end
			function rot:GetOffset()
				return calcoffset(self.CamFOV)
			end
			local function applyfov(actor, fov)
				if actor.fov then
					actor:fov(fov)
				end
				if not actor.GetChildren then return end
				for i, v in ipairs(actor:GetChildren()) do
					applyfov(v, fov)
				end
			end
			local function applyfardist(actor, fardist)
				if actor.fardistz then
					actor:fardistz(fardist)
				end
				if not actor.GetChildren then return end
				for i, v in ipairs(actor:GetChildren()) do
					applyfardist(v, fardist)
				end
			end
			function rot:fov(fov)
				if not fov then return self.CamFOV end
				self.CamFOV = fov
				ActorFrame.fov(self, fixfov(fov))
				--self:z(pos:GetZ() + calcoffset(fov))
				for pn = 1, #std.PL do
					std.PL[pn].Player:fov(fixfov(fov))
				end
				applyfov(pivot, fixfov(fov))
				return self
			end
			function rot:PivotRotX(p)
				--[[
				self
					:rotationx(p)
					:y(math.sin(math.rad(-p)) * -self:GetOffset())
					:z((math.cos(math.rad(p)) - 1) * self:GetOffset())
				--]]
				pivot:rotationx(p)
				return self
			end
			function rot:PivotRotY(p)
				--[[
				self
					:rotationy(p)
					:x(math.sin(math.rad(-p)) * self:GetOffset())
					:z((math.cos(math.rad(-p)) - 1) * -self:GetOffset())
				--]]
				pivot:rotationy(p)
				return self
			end
			function rot:PivotRotZ(p)
				pivot:rotationz(p)
				return self
			end
			function rot:PivotRotXY(x, y)
				self:PivotRotX(x):PivotRotY(y)
				return self
			end
			function rot:PivotRotYZ(y, z)
				self:PivotRotY(y):PivotRotZ(z)
				return self
			end
			function rot:PivotRotXZ(x, z)
				self:PivotRotX(x):PivotRotZ(z)
				return self
			end
			function rot:PivotRotXYZ(x, y, z)
				self:PivotRotXY(x, y):PivotRotZ(z)
				return self
			end
			--applyfardist(rot, 1000000)
			rot:fardistz(1000000)
			for pn = 1, #std.PL do
				std.PL[pn].Player:fardistz(1000000)
			end
			rot:fov(rot.CamFOV)
			rot:xyz(0, 0, 0)
			pos:GetChildAt(1):visible(false)
			pos:GetChildAt(2):visible(true)
		end
		camPos.UpdateCommand = function(self)
			local pivot = self:GetParent()
			local rotx = math.abs(self:GetRotationX() + pivot:GetRotationX()) % 360
			local roty = math.abs(self:GetRotationY() + pivot:GetRotationY()) % 360
			if (rotx > 90) and (rotx < 270) or (roty > 90) and (roty < 270) then
				self:GetChildAt(1):visible(true)
				self:GetChildAt(2):visible(false)
			else
				self:GetChildAt(1):visible(false)
				self:GetChildAt(2):visible(true)
			end
		end
		camPos:AddChild(camFG)
		camPos:AddChild(camBG, 1)
		camPivot:AddChild(camPos)
		camRot:AddChild(camPivot)
		return camRot
	end
	if not t.Name then t.Name = 'Node'..node_idx end
	node_idx = node_idx + 1
	t.IsNode = true
	setmetatable(t, Node)
	local actortable = env[t.Type] or Actor
	if t.Type == 'Quad' or t.Type == 'Sprite' then
		actortable = Actor
		for k, v in pairs(Sprite) do
			actortable[k] = v
		end
	end
	for k, v in pairs(actortable) do
		t[k] = function(self, ...)
			local nodefunc = self.NodeCommand
			local args = {...}
			self.NodeCommand = function(subself)
				if nodefunc then nodefunc(subself) end
				v(subself, table.unpack(args))
			end
			return self
		end
	end
	return t
end
local function FromFile(path)
	--print('Node.FromFile')
	local t = run(path)
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
	if type(t[3]) ~= 'string' then
		table.insert(t, 2, 0)
		table.insert(t, 3, Tweens.linear)
	end
	if type(t[4]) ~= 'string' then
		table.insert(t, 4, 0)
		table.insert(t, 5, 1)
	end
	table.insert(ease_table, t)
	return ease
end
local function func(t)
	--print('Node.func')
	if type(t) ~= 'table' then
		printerr('Node.func: Table expected, got '..type(t))
	end
	if type(t[2]) == 'function' then
		table.insert(t, 2, 0)
		table.insert(t, 3, Tweens.linear)
	end
	if type(t[4]) == 'function' then
		table.insert(t, 4, 0)
		table.insert(t, 5, 1)
	end
	table.insert(t, 1, nil)
	table.insert(func_table, t)
	return func
end

local function signal(t)
	--print('Node.signal')
	if type(t) ~= 'table' then
		printerr('Node.signal: Table expected, got '..type(t))
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
	return self
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

local function SetName(self, name, declarative)
	--print('Node:SetName')
	self.Name = name
	--env[name] = self
	if declarative then self.Name = name..'.D' end
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
	self[env._scope..'InputMessageCommand'] = function(self, param)
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
	if not _G[self.Type].GetChildren then
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

-- ProxyWall
local function ConfigWall(self)
	if not self.IsProxyWall then
		printerr('Node.ConfigWall: Cannot config proxy wall of type '..self.Type)
		return
	end
	local width = std.PLRWIDTH[1] * SH / 480
	self.Length = self.Length or math.ceil(std.SW * 1.5 / width)
	self.Pattern = self.Pattern or {1, 2}
	self.Spacing = self.Spacing or 0
	for idx in ipairs(self) do
		table.remove(self, idx)
	end
	local t = Node.new {
		Type = 'ActorProxyWall',
		Length = self.Length,
		Pattern = self.Pattern,
		Spacing = self.Spacing,
	}
	for k, v in pairs(self) do
		if type(k) == 'string' and k:find('Command') then
			t[k] = v
		end
	end
	local len = self.Length
	t.NodeCommand = function(subself)
		function subself:wallx(offset)
			subself:SetCurrentAndDestinationItem(offset)
			return subself
		end
		-- offsets from 0 and goes in percent of column width
		function subself:wallspacing(offset)
			subself:SetTransformFromFunction(function(subsubself, off)
				subsubself:x((off + ((len - 1) % 2) * 0.5) * width * (1 + (offset * 0.01)))
			end)
			return subself
		end
		function subself:SetSpacing(offset)
			return subself:wallspacing(offset)
		end
		subself
			:SetLoop(true)
			:SetFastCatchup(true)
			:fov(70)
			:rotafterzoom(false)
			
		if subself:GetNumWrapperStates() < 1 then
			subself:AddWrapperState()
		end
		local wrapper = subself:GetWrapperState(1)
		wrapper
			:Center()
			:fov(70)
			:rotafterzoom(false)
		function subself:rotationx(n)
			wrapper:rotationx(n)
			return subself
		end
		function subself:rotationy(n)
			wrapper:rotationy(n)
			return subself
		end
		function subself:rotationz(n)
			wrapper:rotationz(n)
			return subself
		end
	end
	return t
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
	return self
end
local function SetPattern(self, pat)
	if not self.IsProxyWall then
		printerr('Node.SetPattern: Cannot set proxy pattern for type '..self.Type)
		return
	end
	if type(pat) ~= 'table' then
		printerr('Node.SetPattern: Pattern must be table containing player sequence')
		return
	end
	self.Pattern = pat
	return self
end
local function SetSpacing(self, spacing)
	if not self.IsProxyWall then
		printerr('Node.SetSpacing: Cannot set spacing for type '..self.Type)
		return
	end
	if type(spacing) ~= 'number' then
		printerr('Node.SetSpacing: Spacing must be number')
	end
	self.Spacing = spacing
	return self
end
local function SetPlayer(self, pn)
	if not self.IsModPlayer and self.Type ~= 'NoteField' then
		printerr('Node.SetPlayer: Cannot set Player for type '..self.Type)
		return
	end
	if self.Type == 'NoteField' then
		nf = self
	elseif self.IsModPlayer then
		nf = self.NoteField
	end
	nf
		:SetAttribute('Player', pn - 1)
		:SetAttribute('NoteSkin', GAMESTATE:GetPlayerState(pn - 1):GetPlayerOptions('ModsLevel_Stage'):NoteSkin())
	
	nf.NodeCommand = function(self)
		local poptions = GAMESTATE:GetPlayerState(pn - 1):GetPlayerOptions('ModsLevel_Song')
		local mini = 1 - 0.5 * poptions:Mini()
		local tilt = 1 - (0.1 * math.abs(poptions:Tilt()))
		local rotx = -30 * poptions:Tilt()
		self
			:zoom(mini * tilt)
			:rotationx(rotx)
			:sleep(self:GetEffectDelta())
			:queuecommand('Node')
	end
	return self
end
local function SetAutoplay(self, b)
	if not self.IsModPlayer and self.Type ~= 'NoteField' then
		printerr('Node.SetAutoplay: Cannot set Autoplay for type '..self.Type)
		return
	end
	if self.Type == 'NoteField' then
		nf = self
	elseif self.IsModPlayer then
		nf = self.NoteField
	end
	nf:SetAttribute('AutoPlay', b)
	return self
end
local function SetFieldID(self, id)
	if not self.IsModPlayer and self.Type ~= 'NoteField' then
		printerr('Node.SetFieldID: Cannot set FieldID for type '..self.Type)
		return
	end
	if self.Type == 'NoteField' then
		nf = self
	elseif self.IsModPlayer then
		nf = self.NoteField
	end
	nf:SetAttribute('FieldID', id)
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

-- ActorFrame
local function AddChild(self, child, idx, name)
	--print('Node:AddChild')
	if not _G[self.Type].GetChildren then
		printerr('Node.AddChild: Cannot add child to type '..self.Type)
		return
	end
	if child.IsProxyWall then
		child = ConfigWall(child)
	end
	if type(idx) == 'string' then
		name = idx
		idx = nil
	end
	if name then child:SetName(name, true) end
	if child.IsNode then
		child = Def[child.Type](child)
	end
	local parent = self
	if self.IsCamera and self.CameraSet then
		local t = {}
		for i, v in ipairs(parent[1][1]) do
			t[i] = v
		end
		BG = t[1]
		FG = t[2]
		local i = idx or #FG + 1
		local proxy = Def.ActorProxy {
			NodeCommand = function(self)
				local FG = self:GetParent():GetParent():GetChildAt(2)
				self:SetTarget(FG:GetChildAt(i))
			end
		}
		if idx then
			table.insert(BG, (#BG + 1) - (idx - 1), proxy)
			table.insert(FG, idx, child)
		else
			table.insert(BG, 1, proxy)
			table.insert(FG, child)
		end
		return self
	end
	if idx then
		table.insert(parent, idx, child)
	else
		table.insert(parent, child)
	end
	if child.IsCamera then child.CameraSet = true end
	return self
end
local function GetChildIndex(self, name)
	--print('Node:GetChildIndex')
	if not _G[self.Type].GetChildren then
		printerr('Node.GetChildIndex: Cannot get child index of type '..self.Type)
		return
	end
	for i, v in ipairs(self) do
		if v.Name == name then
			return i
		end
	end
end
local function AddToTree(self, idx, name)
	--print('Node:AddToTree')
	if self.IsProxyWall then
		self = ConfigWall(self)
	end
	if type(idx) == 'string' then
		name = idx
		idx = nil
	end
	if name then self:SetName(name, true) end
	if idx then
		table.insert(NodeTree, idx, self)
	else
		table.insert(NodeTree, self)
	end
	if self.IsCamera then self.CameraSet = true end
	return self
end
local function GetTree()
	--print('Node.GetTree')
	return NodeTree
end

Node = {
	VERSION = VERSION,
	AUTHOR = AUTHOR,
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
	SetSpacing = SetSpacing,
	SetPlayer = SetPlayer,
	SetAutoplay = SetAutoplay,
	SetFieldID = SetFieldID,
	HideOverlay = HideOverlay,
	AddToTree = AddToTree,
	GetTree = GetTree,
	GetActor = GetActor,
}
Node.__index = Node

print('Loaded Konko Node v'..Node.VERSION)

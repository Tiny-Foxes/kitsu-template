---------------------------
-- Use this file for your nodes

--	Node.new({Actor}/'Actor') - Creates a new node
--      {Actor} - OutFox actor table
--      'Actor' - Alternatively, use a type name
--	Node:AttachScript(scriptpath) - Attaches a script to a node
--      scriptpath - Path to Lua script
--		(See 'lua/scripts/empty.lua' for example script)
--	Node:SetReady(func) - Attaches a function to the ready command
--      func - Function to attach
--	Node:SetUpdate(func) - Attaches a function to the update command
--      func - Function to attach (requires 1 parameter!)
--	Node:SetInput(func) - Attaches a function to the input command
--		func - Function to attach (requires 1 parameter!)
--	Node:AddToNodeTree() - Adds a node to the node tree
--	Node.GetNodeTree() - Gets the node tree

-- Nodes can be manipulated like normal actors, but most work
-- should be done in a dedicated script to keep space clean.

-- Update and Input functions all require 1 parameter, even if you don't plan to use them.

-- Use CENTER_PLAYERS to place all players in the center of the screen.

-- Use Node.SetSRTStyle to hide overlays and underlays and set player-related proxies like in modern modfiles.

-- Use the ready and update functions in this script for already established actors
-- (like players and other screen elements)
-- They will not work with nodes. Use the set functions above for them instead.
---------------------------

---------------------------
-- Uncomment for example --
---------------------------
---[[
local QuadPad = {}
local PadDirs = {"Left", "Down", "Up", "Right"}

for i = 1, 4 do
	QuadPad[i] = Node.new('Quad')
	QuadPad[i]:SetReady(function(self)
		self:Center()
		self:SetWidth(64)
		self:SetHeight(64)
		if i == 1 then
			self:addx(-64) -- Left
		elseif i == 2 then
			self:addy(64) -- Down
		elseif i == 3 then
			self:addy(-64) -- Up
		else
			self:addx(64) -- Right
		end
	end)
	QuadPad[i]:SetUpdate(function(self, dt)
	end)
	QuadPad[i]:SetInput(function(self, event)
		if event.button == PadDirs[i] then
			local col = event.DeviceInput.level
			if event.PlayerNumber == PLAYER_1 and (SCREEN and SCREEN:GetName() ~= 'ScreenGameplay' or not SCREEN:IsPaused()) then
				if event.type == 'InputEventType_Release' then
					self:diffuse(1, 1, 1, 1)
				else
					self:diffuse(col, 0, 1 - col, 1)
				end
			end
		end
	end)
	--QuadPad[i]:AddToNodeTree()
end
--]]
---------------------------

-- This centers the player if there's only one
if #PL == 1 then
	CENTER_PLAYERS = true
end
-- This hides the song overlay and underlay like modern modfiles do
Node.SetSRTStyle(true)

-- Set up nodes here --

-- Modify pre-existing actors here --
function ready()
	for pn = 1, 2 do
		PL[pn].Player:rotafterzoom(false)
		--PL[pn].Player:zoomz(4)
	end
end

function update(dt)
end

function input(event)
end

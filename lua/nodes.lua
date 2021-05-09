---------------------------
-- Use this file for your nodes

-- Node.new({Actor}/'Actor') - Creates a new node
--      {Actor} - OutFox actor table
--      'Actor' - Alternatively, use a type name
-- Node:AttachScript(scriptpath) - Attaches a script to a node
--      scriptpath - Path to Lua script
--      (MUST return ready, update, and input functions, update and input both require 1 parameter!)
--		(See 'lua/scripts/empty.lua' for example)
-- Node:SetReady(func) - Attaches a function to the ready command
--      func - Function to attach
-- Node:SetUpdate(func) - Attaches a function to the update command
--      func - Function to attach (requires 1 parameter!)
-- Node:SetInput(func) - Attaches a function to the input command
--		func - Function to attach( requires 1 parameter!)
-- Node:AddToNodeTree() - Adds a node to the node tree
-- Node.GetNodeTree() - Gets the node tree

-- Nodes can be manipulated like normal actors, but most work
-- should be done in a dedicated script to keep space clean.

-- Update functions require a 'dt' parameter, even if you don't plan to use it.

-- Set SRT_STYLE to true to hide overlays and underlays like in common SRT files.

-- Use the ready and update functions in this script for already established actors
-- (like players and other screen elements)
-- They will not work with nodes. Use the set functions for them instead.
---------------------------

sudo()

---------------------------
-- Uncomment for example --
---------------------------
--[[
local nummy = Node.new('Quad')

nummy:SetReady(function(self)
	self:Center()
	self:SetWidth(64)
	self:SetHeight(64)
end)
nummy:SetUpdate(function(self, dt)
	self:addrotationz(360 * dt)
end)
nummy:SetInput(function(self, event)
	local offset = {0, 0}
	if event.button == "Left" then offset[1] = -1
	elseif event.button == "Right" then offset[1] = 1
	elseif event.button == "Up" then offset[2] = -1
	elseif event.button == "Down" then offset[2] = 1
	end
	if not SCREEN:IsPaused() then
		if event.type == "InputEventType_FirstPress" then
			self:addx(offset[1] * 32)
			self:addy(offset[2] * 32)
		elseif event.type == "InputEventType_Release" then
			self:addx(offset[1] * -32)
			self:addy(offset[2] * -32)
		end
	end
end)

nummy:AddToNodeTree()
--]]
---------------------------

-- This centers the player if there's only one
if #PL == 1 then
	CENTER_PLAYERS = true
end
-- This hides the song overlay and underlay like common SRT modfiles do
SRT_STYLE = true

-- Set up nodes here --

-- Modify pre-existing actors here --
function ready()
end

function update(dt)
end

function input(event)
end

return Node.GetNodeTree()

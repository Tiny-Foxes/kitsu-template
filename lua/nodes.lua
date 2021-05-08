---------------------------
-- Use this file for your nodes

-- Node.new({Actor}/'Actor') - Creates a new node
--      {Actor} - OutFox actor table
--      'Actor' - Alternatively, use a type name
-- Node:AttachScript(scriptpath) - Attaches a script to a node
--      scriptpath - Path to Lua script
--      (MUST return a ready function and an update function, update requires 'dt' parameter!)
-- Node:SetReady(func) - Attaches a function to the ready command
--      func - Function to attach
-- Node:SetUpdate(func) - Attaches a function to the update command
--      func - Function to attach (requires 'dt' parameter!)
-- Node:AddToNodeTree() - Adds a node to the node tree
-- Node.GetNodeTree() - Gets the node tree

-- Nodes can be manipulated like normal actors, but most work
-- should be done in a dedicated script to keep space clean.

-- Update functions require a 'dt' parameter, even if you don't plan to use it.

-- Set SRT_STYLE to true to hide overlays and underlays like in common SRT files.

-- Use the ready and update functions in this script for already established actors
-- (like players and other screen elements)
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

nummy:AddToNodeTree()
--]]
---------------------------

SRT_STYLE = false



function ready()
end

function update(dt)
end

return Node.GetNodeTree()

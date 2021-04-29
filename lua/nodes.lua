sudo()
-- Use this file for your nodes

-- Node.new({Actor}/'Actor') - Creates a new node
--      {Actor} - OutFox actor table
--      'Actor' - Alternatively, use a type name
-- Node:AttachScript(scriptpath) - Attaches a script to a node
--      scriptpath - Path to Lua script
--      (MUST return a ready function and an update function)
-- Node:AddToNodeTree() - Adds a node to the node tree

-- Nodes can be manipulated like normal actors, but most work
-- should be done in a dedicated script to keep space clean.

local QuadNode = Node.new('Quad')

-- QuadNode:AttachScript('this/doesnt/actually/lead/to.lua')

QuadNode:AddToNodeTree()

return Node.GetNodeTree()

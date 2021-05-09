# Kitsu Template
#### For Outfox
The Kitsu Template is a template designed to make modcharting in Outfox feel more friendly to the object-oriented mindset. It also aims to make minigame creation fun, easy, and accessible to those used to making games in Love2D or most other high-level languaged, update-loop focused game engines.

## Creating a Node
Nodes are Kitsu's form of actors with embedded scripts or functions. To create one, simply call the `Node.new` function.
```lua
local MyNode = Node.new('Quad') -- You can optionally pass in a string for the type, or an entire Outfox-style actor for convenience.
```
Once you've created your node, you can attach a script with `AttachScript`.
```lua
MyNode:AttachScript('lua/script/empty.lua') -- You can use the empty script here for an example of setup
```
If you don't want to create a script, you can directly set the ready and update functions.
```lua
MyNode:SetReady(function(self)
 self:Center()
 self:SetWidth(64)
 self:SetHeight(64)
end)
MyNode:SetUpdate(function(self, dt)
 self:addrotationz(360 * dt) -- dt stands for "delta time" - the amount of seconds since last frame.
end)
```
Finally, you can add your node to the node tree.
```lua
MyNode:AddToNodeTree()
```
More documentation avaiable in `nodes.lua`.

## Creating a Mod
Mods are done quite differently in the Kitsu template in the sense that even the mods are objects.
```lua
local MyMods = Mods.new()
```
You can insert mods into a mod branch using three different functions.
```lua
-- In-house method
MyMods:InsertMod(0, 4, Tweens.inoutexpo, {
 {20, 'Drunk'},
 {20, 'Tipsy'}
})
-- Mirin Method
MyMods:MirinMod {4, 4, Tweens.inoutcircle, 100, 'Invert'}
-- Exschwasion Method
MyMods:ExschMod(8, 4, Tweens.inoutback, 100, 0, 'Invert')
```
And just like with nodes, you can add your mod branches to the mod tree.
```lua
MyMods:AddToModTree()
```
More documentation available in `mods.lua`.

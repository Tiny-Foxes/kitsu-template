# Getting Started
To make a simple modfile, open the `mods.lua` file in a text editor and type the following:
```lua
local Intro = Mods.new()
Intro:InsertMod(0, 4, Tweens.inoutexpo, {{100, 'invert'}})
Intro:AddToModTree()
```
This will exponentially ease in and out the percentage of invert from 0 to 100 over 4 beats.
Notice that we called our new mods branch `Intro`. This is because we can identify it as the branch of mods that start at the intro of the song. We can name it anything we want, but a good naming convention is to name it after sections of the song you're modding.

To make a quad node, open the `nodes.lua` file and type:
```lua
local SquareBoy = Node.new('Quad')
SquareBoy:SetReady(function(self)
    self:x(SCX)
    self:y(SCY)
    self:SetWidth(64)
    self:SetHeight(64)
end)
SquareBoy:AddToNodeTree()
```
This will create a new quad, center it on the screen, and set its size to 64x64. Again, we can name this new node anything we want, but it's good to choose a name that makes it easy to tell what it's being used for.

Full references avaiable for:  
[NotITG](/kitsu-template/notitg/reference)  
[Outfox](/kitsu-template/outfox/reference)  

###### [Return to Home](/kitsu-template)

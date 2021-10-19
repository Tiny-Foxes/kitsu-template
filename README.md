# Kitsu Template
#### For Outfox
The Kitsu Template is designed with the mindset that a template should be fully customizable, yet easy to get started with. It remedies this with only including vital functions at the core of its code, and layering libraries on top that can be added, exchanged, or even removed if desired. Everything you need is included, and anything you want is supported.

You can view the docs [here](https://tiny-foxes.github.io/kitsu-template).  
The NotITG version (albeit no longer maintained) can be found [here](https://github.com/sudospective/kitsu-template-notitg).

# Getting Started
Kitsu template is special in the sense that you don't have to use a built-in mod loader. You can use a different mod loader or even make your own. You don't even have to use the included standard library; you can make an entirely custom one and use that instead!

You can include libraries in `mods.lua` by using the `import` function.
```lua
local std = import 'stdlib' -- Kitsu Standard Library
local Node = import 'konko-node' -- Konko Node
local Mods = import 'konko-mods' -- Konko Mods
```

There are more libraries you can find [here](https://github.com/Tiny-Foxes/kitsu-template-libraries/).

## Using Konko Node
Konko Node allows a new, streamlined syntax that reduces the need for actor tables.To create a node, simply call the `Node.new` function.
```lua
local MyNode = Node.new('Sprite') -- You can pass in a string naming the type of Actor, or an entire Actor itself.
```
Once you've created your node, you can set its `init`, `ready`, `update`, and `input` functions.
```lua
MyNode:SetInit(function(self)
  self:Center()
end)
MyNode:SetReady(function(self)
  self:SetWidth(64)
  self:SetHeight(64)
end)
MyNode:SetUpdate(function(self, dt)
  self:addrotationz(360 * dt) -- dt stands for "delta time" - the amount of seconds since last frame.
end)
MyNode:SetInput(function(self, event)
  if event.type == "InputEventType_FirstPress" then
    SCREENMAN:SystemMessage(event.button)
  end
end)
-- You can also set custom commands and messages.
MyNode:SetCommand('Custom1', function(self) end)
MyNode:SetMessage('Custom2', function(self) end)
-- You can even set attributes!
MyNode:SetAttribute('Texture', 'path/to/texture.png')
```

Finally, you can add your node to the node tree. You can give it a name, and index, both, or neither. Giving it a name will allow you to use this node in its Actor form after its construction.
```lua
MyNode:AddToTree('MyNode', 1)
```
More documentation avaiable in `konko-nodes.lua`.

## Using Konko Mods
Mods are straightforward if you've used other templates. You can insert a mod via the `Mods` object.

```lua
Mods:Insert(0, 2, Tweens.outelastic, {{100, 'invert'}})
```
This will ease `invert` at its current percent to `100` starting at beat `0` for two beats.

You can insert mods using three different functions. These examples all do the same thing, but each with their own syntax and advantages.
```lua
-- In-house method - Recommended for inserting tables of percent-mod pairs
Mods:Insert(0, 4, Tweens.outelastic, {
  {100, 'invert'},
  {100, 'tipsy'}
})

-- Mirin Method - Recommended for fast mod prototyping
Mods:Mirin {0, 4, Tweens.outelastic, 100, 'invert', 100, 'tipsy'}

-- Exschwasion Method - Recommended for easy troubleshooting
Mods:Exsch(0, 4, 0, 100, 'invert', 'len', Tweens.outelastic)
Mods:Exsch(0, 4, 0, 100, 'tipsy', 'len', Tweens.outelastic)
```

You can also set default mods using `Mods:Default`.
```lua
Mods:Default({
	{1.5, 'xmod'},
	{100, 'stealthtype'},
	{100, 'modtimersong'},
	{100, 'tinyusesminicalc'}
})
```

More documentation available in `konko-mods.lua`.

## Writing Libraries

There's really no limit to what you can write for a library. Since the only requirements you have are the requirements you give yourself, you can write any library you want, but there are a few important things to consider.

1. If you need a certain library to function, include it! remember to use `import` for anything you'll need.
1. Try to keep your library local to avoid interfering with other libraries. Even the included standard library is local!
2. If you write a library and you need to add an actor, you should do this with `FG[#FG + 1] = Def.ActorFrame {}`. This is the same `FG` that is created in `env.lua` and added to the ActorFrame in `init.lua`. This `FG` ActorFrame has an update loop already provided that will call `UpdateCommand` every frame.
3. Another thing to consider if you write your own standard library is that you may need to write your own mod loader as well. This is why one is included. It may not make writing a mod loader clear, but it will give you an idea of what it may expect from your standard library.
4. You're more than welcome to submit your library to the [Template Library Repository](https://github.com/Tiny-Foxes/kitsu-template-libraries/)! Once approved, it will be listed with others in an easy-to-find location.

Generally, a library is written as follows:
```lua
-- You can import libraries in your library, too! That's what we call a dependency.
local std = import 'stdlib'

-- We will fill this and return it in the end.
local MyLib = {}
setmetatable(MyLib, {})

-- We write our library definitions here.
local MyVar = std.SCX
local function MyFunc(n)
	return MyVar + n
end

-- List only what you want to export. Internal variables should stay hidden to prevent other things from messing with them.
MyLib = {
	VERSION = '1.0',
	var = MyVar,
	func = MyFunc
}
MyLib.__index = MyLib

-- It's a nice gesture to let the log know we've loaded in.
print('Loaded MyLib v'..MyLib.VERSION)
return MyLib
```

You should name be able to import your library into `mods.lua` or other libraries by using `import`.
```lua
local lib = import 'MyLib'

print(lib.var) -- Will print the value of SCREEN_CENTER_X
local newvar = lib.func(7)
print(newvar) -- Will print the value of SCREEN_CENTER_X + 7
```

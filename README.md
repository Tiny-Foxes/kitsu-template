# Kitsu Template
#### For Outfox
The Kitsu Template is a template designed to make modcharting feel more friendly to the object-oriented mindset. It also aims to make minigame creation fun, easy, and accessible to those used to making games in Love2D or most other high-level languaged, update-loop focused game engines.

You can view the docs [here](https://tiny-foxes.github.io/kitsu-template).  
NotITG version (albeit rarely maintained) [here](https://github.com/sudospective/kitsu-template-notitg)

# Getting Started
Kitsu template is special in the sense that you don't have to use a built-in mod loader. You can use a different mod loader or even make your own. You don't even have to use the included standard library; you can make an entirely custom one and use that instead!

You can include libraries in `mods.lua` by using the `import` function.
```lua
local std = import 'stdlib' -- Kitsu Standard Library
local Node = import 'konko-node' -- Konko Node
local Mods = import 'konko-mods' -- Konko Mods
```

There are two other libraries included that you can use if you wish, `mirin-syntax` and `ease-names`.
- `mirin-syntax` will stylize the Konko Mods syntax to be like Mirin, and allow you to call `mirin.ease` instead of `Mods:Mirin`.
- `ease-names` will allow you to use different names for ease functions like `inOutExpo` instead of `Tweens.inoutexpo`.

You can include them like this:
```lua
local mirin = import 'mirin-syntax'
import 'ease-names'
```

(If you import `mirin-syntax`, you do not have to import `konko-mods`, unless you want to still be able to use the `Mods` object directly.)

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
MyNode:AddToNodeTree('MyNode', 1)
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

There's really no limit to what you can write for a library. Since the only requirements you have are the requirements you give yourself, you can write any library you want. `mirin-syntax` is a good starting example on how to write a library for the Kitsu template, but there are some important things to consider.

1. If you need a certain library to function, include it! remember to use `import` for anything you'll need.
1. Try to keep your library local to avoid interfering with other libraries. Even the included standard library is local!
1. If you write your own standard library, a good practice is to set an ActorFrame for the foreground. You should do this with `FG = FG or Def.ActorFrame {}`. This is the same `FG` that is returned in `mods.lua`.
1. Another thing to consider if you write your own standard library is that you may need to write your own mod loader as well. This is why one is included. It may not make writing a mod loader clear, but it will give you an idea of what it may expect from your standard library.

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

-- List only what you want to export. internal variables should stay hidden to prevent other things from messing with them.
MyLib = {
	var = MyVar,
	func = MyFunc
}
MyLib.__index = MyLib

-- It's a nice gesture to let the log know we've loaded in.
print('Loaded MyLib')
return MyLib
```

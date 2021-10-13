-- libloader.lua --

-- Add libraries using import 'filename' here
-- This should always return an Actor, even if it's an empty one
std = import 'stdlib' -- Kitsu Standard Library by Sudospective
Node = import 'nodebuilder' -- Kitsu Nodebuilder by Sudospective
Mods = import 'modsbuilder' -- Kitsu Modsbuilder by Sudospective

-- Add your Actors to this ActorFrame to load them
return Def.ActorFrame {
	std,
	Node,
	Mods,
}
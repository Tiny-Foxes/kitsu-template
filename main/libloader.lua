Node = import "nodebuilder" -- Nodebuilder
Mods = import "new-modsbuilder" -- Modsbuilder

-- Corope needs a Def.Actor wrapper
local Corope = Def.Actor {
	InitCommand = sudo(function(self)
		Async = import("corope")({errhand = printerr})
	end)
}

-- Add libraries using import "[library_name]"



-- Return your libraries as an Actor or ActorFrame and add here
return Def.ActorFrame {
	Node,
	Mods,
	Corope
}
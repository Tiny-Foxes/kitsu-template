local std = import 'stdlib'
mirin = import 'mirin-syntax'

local PL = std.PL
local P = {}
for pn = 1, #PL do
	P[pn] = PL[pn].Player
end

using 'mirin' (function()

	-- Default mods
	setdefault {
		1.5, 'xmod',
		100, 'modtimersong',
		0, 'rotationz'
	}
	-- Mode code goes hode

end)

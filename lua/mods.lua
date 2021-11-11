-- Libraries
std = import 'stdlib'
mirin = import 'mirin-syntax'


-- Variables
getfrom 'fg' {
	'SW', 'SH',
	'SCX', 'SCY',
	'PL', 'BEAT',
	'POS', 'HideOverlay',
}


-- Called on ReadyCommand
function ready()

	HideOverlay()

	P, PP, PJ, PC = {}, {}, {}, {}
	for pn = 1, #PL do
		P[pn] = PL[pn].Player
		PP[pn] = PL[pn].ProxyP
		PJ[pn] = PL[pn].ProxyJ
		PC[pn] = PL[pn].ProxyC
	end

	-- Mods
	using 'mirin' (function()
	
		-- Default mods
		setdefault {
			1.5, 'xmod',
			100, 'modtimersong'
		}
		-- Mode code goes hode
	
	end)

end


-- Actors
table.insert(Actors.Mods, Def.ActorFrame {

	

})

-- Libraries
mirin = import 'mirin-syntax'


-- Called on ReadyCommand
function ready()

	-- Variables
	getfrom 'fg' {
		'SW', 'SH',
		'SCX', 'SCY',
		'PL', 'BEAT',
		'HideOverlay',
		'PP', 'PJ', 'PC',
	}
	
	-- Mods
	using 'mirin' (function()

		for pn = 1, #PL do
			P[pn] = PL[pn].Player
			L[pn] = PL[pn].Life
			S[pn] = PL[pn].Score
		end
	
		-- Default mods
		setdefault {
			1.5, 'xmod',
			100, 'modtimersong'
		}
		-- Mode code goes hode
	
	end)

	HideOverlay(true)

end


-- Actors
table.insert(Actors.Mods, Def.ActorFrame {})

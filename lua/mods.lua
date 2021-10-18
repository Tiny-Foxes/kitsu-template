-- Libraries
local std = import 'stdlib'
local Node = import 'konko-node'
local Mods = import 'konko-mods'


-- Variables
local SW, SH = std.SW, std.SH
local SCX, SCY = std.SCX, std.SCY


-- Proxies
local P = {}
local PP, PJ, PC = {}, {}, {}
for pn = 1, #GAMESTATE:GetEnabledPlayers() do
	PP[pn] = std.ProxyPlayer(pn)
	PJ[pn] = std.ProxyJudgment(pn)
	PC[pn] = std.ProxyCombo(pn)
end


-- Called on InitCommand
function init()

end

-- Called on ReadyCommand
function ready()
	
	-- Hide overlay elements
	Node.HideOverlay(true)

	-- Player shorthand variables
	for pn = 1, #std.PL do
		P[pn] = std.PL[pn].Player
	end

	-- Default mods
	Mods:Default {
		{1.5, 'xmod'},
		{100, 'modtimersong'}
	}

	-- Mod code here

end

-- Called on UpdateMessageCommand
function update(dt)

end

-- Called on InputMessageCommand
function input(event)

end


-- Actors
table.insert(FG, 1,

	Def.ActorFrame {
		-- Proxies
		table.unpack(PP),
		table.unpack(PJ),
		table.unpack(PC),

		-- Actor code here

	}

)

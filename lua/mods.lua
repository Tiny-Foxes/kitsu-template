-- Libraries
local std = import 'stdlib'
local Node = import 'konko-node'
local Mods = import 'konko-mods'


-- Variables
local SW, SH = std.SW, std.SH
local SCX, SCY = std.SCX, std.SCY

-- Proxies
local P, PL = {}, {}
local PP, PJ, PC = {}, {}, {}
for pn = 1, #GAMESTATE:GetEnabledPlayers() do
	PP[pn] = std.ProxyPlayer(pn, 'PP'..pn)
	PJ[pn] = std.ProxyJudgment(pn, 'PJ'..pn)
	PC[pn] = std.ProxyCombo(pn, 'PC'..pn)
end


-- Called on InitCommand
function init()

end

-- Called on ReadyCommand
function ready()
	
	-- Hide overlay elements
	Node.HideOverlay(true)

	-- Player shorthand variables
	PL = std.PL
	for pn = 1, #PL do
		P[pn] = PL[pn].Player
	end

	-- Default mods
	Mods:Default {
		{1.5, 'xmod'},
		{100, 'modtimersong'},
	}
	-- Mode code here
	for beat = 0, 300 do
		Mods
			:Mirin {beat - 0.25, 0.5, Tweens.inoutquad, 100, 'flip', -100, 'invert', 100, 'drunk', -100, 'tipsy'}
			:Mirin {beat + 0.25, 0.5, Tweens.inoutquad, 0, 'flip', 0, 'invert', -100, 'drunk', 100, 'tipsy'}
	end

end

-- Called on InputMessageCommand
function input(event)

end

-- Called on UpdateCommand
function update(dt)
	
end

-- Called on FG.Draw
function draw()

end


-- Actors
table.insert(FG, Def.ActorFrame {
	table.unpack(PP),
	table.unpack(PJ),
	table.unpack(PC),
	Node.GetTree(),
})

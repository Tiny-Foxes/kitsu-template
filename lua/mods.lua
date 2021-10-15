local std = import 'stdlib'
local Node = import 'konko-node'
local Mods = import 'konko-mods'

for pn = 1, #GAMESTATE:GetEnabledPlayers() do
	Node.new('ActorProxy'):AddToNodeTree('PP'..pn)
	Node.new('ActorProxy'):AddToNodeTree('PJ'..pn)
	Node.new('ActorProxy'):AddToNodeTree('PC'..pn)
end

-- Called on InitCommand
function init()

end
-- Called on ReadyCommand
function ready()

	local PL = std.PL
	-- Variables for iterating proxies
	local PP, PJ, PC = table.unpack {
		{PP1, PP2},
		{PJ1, PJ2},
		{PC1, PC2}
	}

	-- Setting up proxies
	for pn = 1, #PL do
		PP[pn]
			:SetTarget(PL[pn].Player)
		PJ[pn]
			:SetTarget(PL[pn].Judgment)
			:xy(PL[pn].Player:GetX(), std.SCY)
		PC[pn]
			:SetTarget(PL[pn].Combo)
			:xy(PL[pn].Player:GetX(), std.SCY)
		PL[pn].Player
			:visible(false)
		PL[pn].Judgment
			:visible(false)
			:sleep(9e9)
		PL[pn].Combo
			:visible(false)
			:sleep(9e9)
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

return FG

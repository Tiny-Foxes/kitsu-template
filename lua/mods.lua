-- Import libraries here, whichever you need.
import 'stdlib' -- Kitsu Standard Library
local Node = import 'konko-node' -- Konko Node
local Mods = import 'konko-mods' -- Konko Core
local mirin = import 'mirin-syntax' -- Mirin Syntax
import 'ease-names' -- NotITG ease names


-- Here is how proxies for the players are typically set up.
-- First, let's initialize some varibles.
local PP, PJ, PC

-- Now for each enabled player.
for pn = 1, #GAMESTATE:GetEnabledPlayers() do

	-- First, the player proxy. Simple enough, just set the target, then hide the player.
	-- Then we add it to our node tree.
	Node.new('ActorProxy')
		:SetReady(function(self)
			self:SetTarget(PL[pn].Player)
			PL[pn].Player:visible(false)
		end)
		:AddToNodeTree('PP'..pn)

	-- Now the judgments. We have to position these, and also sleep the original actors.
	Node.new('ActorProxy')
		:SetReady(function(self)
			self:SetTarget(PL[pn].Judgment)
			self:x(SCX * (pn-.5))
			self:y(SCY)
			PL[pn].Judgment:visible(false)
			PL[pn].Judgment:sleep(9e9)
		end)
		:AddToNodeTree('PJ'..pn)

	-- Same with the combos. Target, position, sleep, add to tree.
	Node.new('ActorProxy')
		:SetReady(function(self)
			self:SetTarget(PL[pn].Combo)
			self:x(SCX * (pn-.5))
			self:y(SCY)
			PL[pn].Combo:visible(false)
			PL[pn].Combo:sleep(9e9)
		end)
		:AddToNodeTree('PC'..pn)
end


-- Mod code here
Mods:Default {
	{1.5, 'xmod'},
	{100, 'stealthtype'},
	{100, 'modtimersong'}
}


-- Called on InitCommand
function init()
end
-- Called on ReadyCommand
function ready()
	-- Variables for iterating proxies
	PP, PJ, PC = table.unpack {
		{PP1, PP2},
		{PJ1, PJ2},
		{PC1, PC2}
	}
end

-- Called on UpdateCommand
function update(dt)
end

-- Called on InputMessageCommand
function input(event)
end

return FG

-- This is a little syntax sugar to make the Mirin modders feel more at home.
-- Thank you for being patient. Have fun <3
local ease, set = import 'mirin-convert'
import 'ease-names'

local PP = {}
local PJ = {}
local PC = {}

do
	-- Here is how proxies for the players are typically set up.
	for pn = 1, #PL do

		-- First, the player proxy. Simple enough, just set the target, then hide the player.
		-- Then we add it to our node tree.
		PP[pn] = Node.new('ActorProxy')
		PP[pn]
			:SetReady(function(self)
				self:SetTarget(PL[pn].Player)
			end)
			:AddToNodeTree('PP['..pn..']')
		PL[i].Player:visible(false)

		-- Now the judgments. We have to position these, and also sleep the original actors.
		PJ[pn] = Node.new('ActorProxy')
		PJ[pn]
			:SetReady(function(self)
				self:SetTarget(PL[pn].Judgment)
				self:x(SCX * (pn-.5))
				self:y(SCY)
			end)
			:AddToNodeTree('PJ['..pn..']')
		PL[i].Judgment:visible(false)
		PL[i].Judgment:sleep(9e9)

		-- Same with the combos. Target, position, add to tree, sleep.
		PC[pn] = Node.new('ActorProxy')
		PC[pn]
			:SetReady(function(self)
				self:SetTarget(PL[pn].Combo)
				self:x(SCX * (pn-.5))
				self:y(SCY)
			end)
			:AddToNodeTree('PC['..pn..']')
		PL[i].Combo:visible(false)
		PL[i].Combo:sleep(9e9)
	end
end

-- Called on InitCommand
function init()
end

-- Called on ReadyCommand
function ready()
end

-- Called on UpdateCommand
function update(dt)
end

-- Called on InputMessageCommand
function input(event)
end

-- If you REALLY want it, the good ol' Def.ActorFrame is here, too.
return Def.ActorFrame {}

-- Libraries
std = import 'stdlib'
Node = import 'konko-node'
Mods = import 'konko-mods'
mirin = import 'mirin-syntax'


-- Constants from stdlib
getfrom 'std' {
	'SCREEN',
	'SW', 'SH',
	'SCX', 'SCY',
	'PL', 'POS',
}

-- Proxies
local cam = Node.new('ActorCamera'):AddToTree('Camera')
for pn = 1, #GAMESTATE:GetEnabledPlayers() do
	cam:AddChild(
		Node.new('ActorProxy'):SetReady(function(self)
			std.ProxyPlayer(self, pn)
		end), 1 * pn
	)
	cam:AddChild(
		Node.new('ActorProxy'):SetReady(function(self)
			std.ProxyJudgment(self, pn)
		end), 2 * pn
	)
	cam:AddChild(
		Node.new('ActorProxy'):SetReady(function(self)
			std.ProxyCombo(self, pn)
		end), 3 * pn
	)
end


--[[
	Constants:
	-	Screen Width -> SW
	-	Screen Height -> SH
	-	Screen Center X -> SCX
	-	Screen Center Y -> SCY

	Variables:
	-	Current Beat -> BEAT

	Actors:
	-	Top Screen -> SCREEN
	-	Player -> PL[pn].Player
	-	Judgment -> PL[pn].Judgment
	-	Combo -> PL[pn].Combo
	-	Player Proxies -> PL[pn].ProxyP[i]
	-	Add Player Proxy -> std.ProxyPlayer(proxy, pn)
]]


-- Mods
using 'mirin' (function()

	-- Default mods
	setdefault {
		1.5, 'xmod',
		100, 'modtimersong',
	}
	-- Mode code goes hode

end)
-- Node functions
using 'Node' (function()

	func {std.START, function()
		HideOverlay(true)
		for pn = 1, #PL do
			PL[pn].ProxyP[1]:x(SCX)
		end
	end}

end)

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

-- Called on Actors.Mods:Draw()
function draw()

end


-- Actors
return Def.ActorFrame {

	Node.GetTree(),
	Def.Actor {
		InitCommand = function(self)
			DummyDumbDumb = self
		end
	}

}

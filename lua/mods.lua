-- Libraries
import 'stdlib'
import 'konko-node'
import 'konko-mods'
import 'mirin-syntax'


-- Constants from stdlib
getfrom 'std' {
	'SW', 'SH',
	'SCX', 'SCY',
	'PL', 'POS',
}

-- Proxies
for pn = 1, #GAMESTATE:GetEnabledPlayers() do

	local proxyp = Node.new('ActorProxy')
	local proxyj = Node.new('ActorProxy')
	local proxyc = Node.new('ActorProxy')

	proxyp
		:SetReady(function(self)
			std.ProxyPlayer(self, pn, true)
		end)
		:AddToTree()
	proxyj
		:SetReady(function(self)
			std.ProxyJudgment(self, pn)
		end)
		:AddToTree()
	proxyc
		:SetReady(function(self)
			std.ProxyCombo(self, pn)
		end)
		:AddToTree()

end

--[[

	How the Node library works:

	1. Create a new Node.
		local goodboy = Node.new('Quad')

	2. Call Actor methods on Node.
		goodboy:Center():SetSize(64, 64):spin()

	3. Call special Node methods.
		goodboy:SetUpdate(function(self, dt)
			self:aux(self:getaux() + dt):y(SCY + sin(self:getaux() * 2) * 64)
		end)

	4. Add Node to tree.
		goodboy:AddToTree()

--]]

--[[
	Constants:
	-	Screen Width		-> SW
	-	Screen Height		-> SH
	-	Screen Center X		-> SCX
	-	Screen Center Y		-> SCY
	-	Screen Left			-> SL
	-	Screen Right		-> SR
	-	Screen Top			-> ST
	-	Screen Bottom		-> SB

	Variables:
	-	Current Beat		-> BEAT

	Actors:
	-	Top Screen			-> SCREEN
	-	Foreground			-> FG
	-	Player				-> PL[pn].Player
	-	Judgment			-> PL[pn].Judgment
	-	Combo				-> PL[pn].Combo
	-	Player Proxies		-> PL[pn].ProxyP[i]
	-	Add Player Proxy	-> std.ProxyPlayer(proxy, pn, offsetvanish)
--]]

-- Mods
-- (You can look into the konko-mods library to see how these functions work)
Mods
	:Default({
		{1.5, 'XMod'},
		{100, 'ModTimerSong'}
	})
	:Insert(0, 1, Tweens.outexpo, {
		{100, 'Invert'}
	})
	--:Define()
	--:Exsch()
	--:Mirin {}

-- Mirin functions
using 'mirin' (function()
	
	-- You can use Mirin modifiers here if you have the 'mirin-syntax' library imported.
	--ease {0, 1, Tweens.outexpo, 100, 'invert'}

end)

-- Node functions
using 'Node' (function()

	func {std.START, function()
		Node.HideOverlay(true)
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

}

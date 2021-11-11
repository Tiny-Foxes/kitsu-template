-- Libraries
std = import 'stdlib'
Node = import 'konko-node'


-- Variables
getfrom 'std' {
	'SW', 'SH',
	'SCX', 'SCY',
	'PL', 'BEAT',
	'POS',
}
getfrom 'Node' {'HideOverlay'}

-- Proxies
for pn = 1, #GAMESTATE:GetEnabledPlayers() do
	Node.new('ActorProxy'):AddToTree()
		:SetReady(function(self) std.ProxyPlayer(self, pn) end)
	Node.new('ActorProxy'):AddToTree()
		:SetReady(function(self) std.ProxyJudgment(self, pn) end)
	Node.new('ActorProxy'):AddToTree()
		:SetReady(function(self) std.ProxyCombo(self, pn) end)
end


-- Called on InitCommand
function init()

end

-- Called on ReadyCommand
function ready()

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
table.insert(Actors.FG, Def.ActorFrame {

	Node.GetTree(),

})

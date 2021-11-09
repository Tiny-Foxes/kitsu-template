-- Libraries
local std = import 'stdlib'
local Node = import 'konko-node'


-- Variables
local SW, SH = std.SW, std.SH
local SCX, SCY = std.SCX, std.SCY

-- Nodes
Node.new('Quad'):AddToTree(1, 'HideEvent')
	:SetInit(function(self)
		self
			:FullScreen()
			:diffuse(color('#000000'))
	end)


-- Called on InitCommand
function init()

end

-- Called on ReadyCommand
function ready()
	HideEvent
		:sleep(math.abs(std.POS:GetMusicSeconds()))
		:easeoutexpo(1)
		:diffusebottomedge(color('#101010'))
		:diffuserightedge(color('#202020'))
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

	Node.GetTree()

})

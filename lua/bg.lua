-- Libraries
std = import 'stdlib'
Node = import 'konko-node'


-- Variables
getfrom 'std' {
	'SW', 'SH',
	'SCX', 'SCY',
	'BEAT', 'POS', 'PL',
}


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
		:sleep(math.abs(POS:GetMusicSeconds()))
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

-- Called on Actors.BG:Draw()
function draw()

end


-- Actors
return Def.ActorFrame {

	Node.GetTree(),

}

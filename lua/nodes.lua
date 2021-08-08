if GAMESTATE:GetNumSidesJoined() < 2 then
	CENTER_PLAYERS = true
end
Node.SetSRTStyle(true)


Node.new('Quad')
	:AddToNodeTree(1, 'Sun')
	:SetReady(function(self)
		self
			:Center()
			:SetSize(128, 128)
			:zoom(0)
			:diffusealpha(0.75)
	end)
	:Tween {0, 1, Tweens.outexpo, 0, 1, 'zoom'}
	:Tween {0, 2, Tweens.outexpo, -360, 0, 'rotationz'}
	
Node.new('Quad')
	:AddToNodeTree(1, 'Cover')
	:Tween {0, 1, Tweens.outexpo, 0, 0.25, 'diffusealpha'}


function ready()
	Node.AFT:blend('add')
	Sun
		:wag()
		:effectmagnitude(0, 0, 5)
		:effectperiod(4)
	Cover
		:FullScreen()
		:diffuse(color('#000000'))
		:diffusealpha(0)
	Node.ease
		{Node.AFT, 0, 1, Tweens.outexpo, 0, 0.9, 'diffusealpha'}
		{Node.AFT, 0, 1, Tweens.outexpo, 1, 1.1, 'zoom'}
end

function update(dt)
end

function input(event)
	local type = event.type
	local btn = event.button
end

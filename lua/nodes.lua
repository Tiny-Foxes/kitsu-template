if GAMESTATE:GetNumSidesJoined() < 2 then
	CENTER_PLAYERS = true
end
Node.SetSRTStyle(true)

local Sun = Node.new('Quad')
	:SetReady(function(self)
		self
			:SetSize(128, 128)
			:zoom(0)
			:diffusealpha(0.75)
			:wag()
			:effectmagnitude(0, 0, 5)
			:effectperiod(4)
	end)
	:AddEase {0, 1, Tweens.outexpo, 0, 1, 'zoom'}
	:AddEase {0, 2, Tweens.outexpo, -360, 0, 'rotationz'}

Node.new('ActorFrame')
	:AddChild(Sun)
	:AddToNodeTree(1, 'SunFrame')
	
Node.new('Quad')
	:AddToNodeTree(1, 'Cover')
	:AddEase {0, 1, Tweens.outexpo, 0, 0.5, 'diffusealpha'}


function ready()
	Node.AFT:blend('add')
	SunFrame:Center()
	Cover
		:FullScreen()
		:diffuse(color('#000000'))
		:diffusealpha(0)
	Node.ease
		{Node.AFT, 0, 1, Tweens.outexpo, 0, 0.75, 'diffusealpha'}
		{Node.AFT, 0, 1, Tweens.outexpo, 1, 1.1, 'zoom'}
end

function update(dt)
end

local dir = {x = 0, y = 0}
function input(event)
	local type = event.type:sub(event.type:find('_') + 1)
	local btn = event.button
	if type == 'FirstPress' then
		if btn == 'Left' then
			dir.x = dir.x + 10
		elseif btn == 'Right' then
			dir.x = dir.x - 10
		elseif btn == 'Up' then
			dir.y = dir.y + 10
		elseif btn == 'Down' then
			dir.y = dir.y - 10
		end
	elseif type == 'Release' then
		if btn == 'Left' then
			dir.x = dir.x - 10
		elseif btn == 'Right' then
			dir.x = dir.x + 10
		elseif btn == 'Up' then
			dir.y = dir.y - 10
		elseif btn == 'Down' then
			dir.y = dir.y + 10
		end
	end
	Node.AFT
		:stoptweening()
		:easeoutexpo(0.5)
		:xy(SCX + dir.x, SCY + dir.y)
	SunFrame
		:stoptweening()
		:easeoutexpo(0.5)
		:xy(SCX - dir.x * 2, SCY - dir.y * 2)

end

-- Libraries
std = import 'stdlib'
Node = import 'konko-node'


-- Constants from stdlib
getfrom 'std' {
	'SCREEN',
	'SW', 'SH',
	'SCX', 'SCY',
	'PL', 'POS',
}


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

-- Called on Actors.FG:Draw()
function draw()

end


-- Actors
return Def.ActorFrame {
	
	Node.GetTree(),

}

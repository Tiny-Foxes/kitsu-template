-- init.lua --

-- This is sudo. Not the Unix command, just the environment initializer.
-- See main/env.lua for an explanation why this is now defined.
-- IF YOU DARE
sudo()

-- Now we have our main ActorFrame.
return Def.ActorFrame {
	-- Our InitCommand. We sleep this ActorFrame indefinitely, so that ScreenGameplay can't
	-- immediately unload our Actors after Init is finished.
    InitCommand = function(self)
        self:sleep(9e9)
    end,
	-- This OnCommand is here just to tell everything to ready up.
    OnCommand = function(self)
		self:playcommand('Ready')
    end,
	-- Now it's safe to run out mods.lua.
	run 'lua/mods',
	FG
}

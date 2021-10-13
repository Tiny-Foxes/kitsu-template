-- init.lua --

-- This is sudo. Not the Unix command, just the environment initializer.
-- See main/env.lua for an explanation why this is now defined.
-- IF YOU DARE
sudo()

-- Now we have our main ActorFrame.
return Def.ActorFrame {

	-- Our Init command. We set FG here, so we can call FG and get this ActorFrame for any purpose.
	-- We also sleep this ActorFrame indefinitely, so that ScreenGameplay can't immediately unload
	-- Our Actors after Init is finished.
    InitCommand = function(self)
        FG = self
        self:sleep(9e9)
    end,

	-- OnCommand is here just to tell everything to ready up.
    OnCommand = function(self)
        self:playcommand('Ready')
    end,
	
	-- Our environment variable is global. This means that even after our file
	-- is over, we still have it loaded in Lua.
	-- This OffCommand will fix that.
	OffCommand = function(self)
		-- *snap*
		_G.sudo = nil
	end,

	-- This 'run' function looks like it comes out of nowhere, but it's actually sudo.run because of our environment.
	-- sudo.run will take a shorthand filepath, load the file if it finds one, and execute the return in a sudo environment.
	-- Let's run our library loader. You can import your own libraries and define them in this file.
	run 'main/libloader',
	-- (Trailing commas are okay to have, and help me with my problem of forgetting them.)

	-- If you want, you can add your own stuff here, or you can just use the included
	-- lua/nodes.lua which is powered by the nodebuilder library.
	
}
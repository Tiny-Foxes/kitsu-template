-- default.lua --

--[[

    Woah! You're not supposed to be here! This is the backend!
    I suppose that since you're here, you wanna learn the
    * @ ~ . # - A D V A N C E D   S H I T - # . ~ @ *
    
    This is a very customizable but very experimental template,
	and bugs are to be expected, but the idea of this template
	is having extreme plug-and-play libraries and modability,
	while still having a base to work on or just use directly for
	quick and dirty modfile prototyping. If it looks hard to
	master the backend, that's because it IS hard to master the
	backend. There's a lot of things going on to ensure that
	everything I need is included, but everything YOU need can
	be included alongside or even instead of it. Using the template
	shouldn't be any more difficult than the standard stuff you'd
	expect in OutFox Lua, but if you need help with anything, feel
	more than free to send me a message on Discord. I'll be waiting
	in the OutFox server.

    Have your Lua manual handy, this is some hardcore C-style shit.

]]--

-- If we're in ScreenEdit, don't even do anything. This will be removed after OutFox Alpha 5.
--if SCREENMAN:GetTopScreen() and SCREENMAN:GetTopScreen().GetEditState then return Def.Actor {} end
-- Let's get our song directory real quick.
local dir = GAMESTATE:GetCurrentSong():GetSongDir()
-- This loads the absolutely necessary stuff for the template's environment to work properly.
assert(loadfile(dir .. 'main/env.lua'))()
-- This loads our overarching ActorFrame and initial playground. We need to return this one.
return assert(loadfile(dir .. 'main/init.lua'))()

--[[

	The rest is a deep dive through the files of the template. I really encourage you to explore them.
	I've left a lot of helpful comments. Have fun.
	
	~Sudo

    ---------------------------------------
    | Kitsu (n.): A clever canid creature |
    |   known for its cunning and speed.  |
    ---------------------------------------

--]]

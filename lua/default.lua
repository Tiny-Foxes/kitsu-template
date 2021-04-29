_G.sudo = {}
SongDir = GAMESTATE:GetCurrentSong():GetSongDir()
return Def.ActorFrame {
    InitCommand = function(self)
        sudo.fg = self
        self:sleep(9e9)
    end,
    OnCommand = function(self)
        self:playcommand('Ready')
    end,
    assert(loadfile(SongDir .. 'lib/stdlib.lua'))(), -- Std Library
    assert(loadfile(SongDir .. 'lua/nodes.lua'))(), -- Actors
    assert(loadfile(SongDir .. 'lua/mods.lua'))(), -- Mods
}

--[[

    Woah! You're not supposed to be here! This is the backend!
    I suppose that since you're here, you wanna learn the
    * @ ~ . # - A D V A N C E D   S H I T - # . ~ @ *

    There is a library called Corope in here. This allows for
    asynchronous coroutines. You can use these to call functions
    and methods and continue on without having to wait for them
    to return anything. Alternatively, you can stop everything
    until a certain function or method returns non-falsey.
    
    This is a very rough first release, and bugs are to be expected,
    but the idea of this template is making modfiles with minigames
    and interactive features much easier to manage.

    Next major update is planned to add template-side input support,
    which includes PRESSURE SENSITIVE input.

    I mean, the shit to grab the analog input from is there thanks
    to OutFox fixing up the MIDI drivers.

    Have your Lua manual handy, this is some entry game engine shit.

    ~ Sudo

    ---------------------------------------
    | Kitsu (n.): A clever canid creature |
    |   known for its cunning and speed.  |
    ---------------------------------------

]]--

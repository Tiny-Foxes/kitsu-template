---------------------------
-- Use this file for your mods

-- Mods.new() - Creates new mod branch
-- Mods:InsertMod(start, len, ease, modpairs, [offset], [plr]) - Writes mods to branch
--      start - Starting time
--      len - Length to full percentage
--      ease - Ease function
--      modpairs - {{end_p, mod, [begin_p]}, ...}
--          end_p - Ending percent
--          mod - Mod to activate (MUST be written in PascalCase)
--          begin_p - Beginning percent (optional)
--      offset - Offset between each mod in modpairs (optional)
--      plr - Player to apply mods (optional)
-- Mods:MirinMod({start, len, ease, perc, mod, ...}, [offset], [plr]) - Writes mods to branch Mirin style
-- Mods:ExschMod(start, len, begin_p, end_p, mod, timing, ease, [offset], [plr]) - Write mods to branch Exschwasion style
-- Mods:AddToModTree() - Adds branch to mod tree
-- Mods.GetModTree() - Gets mod tree

-- This is probably much more robust than you need, so you can simply create
-- a new branch using Mods.new() branch and stuff all of your mods into it.
---------------------------

sudo()

---------------------------
-- Uncomment for example --
---------------------------
--[[
local Branch = Mods.new()

Branch:MirinMod {0, 1, Tweens.inoutback, 20, 'Drunk', 20, 'Tipsy', 100, 'Bumpy', 100, 'Invert'}

local modtable = {
    {100, 'Reverse1'},
    {100, 'Reverse2'},
    {100, 'Reverse3'},
    {100, 'Reverse4'},
}
Branch:InsertMod(5, 3, Tweens.outbounce, modtable, 0.25)

Branch:ExschMod(10.0, 14, 100, 0, 'Reverse1', 'end', Tweens.outelastic)
Branch:ExschMod(10.5, 14, 100, 0, 'Reverse2', 'end', Tweens.outelastic)
Branch:ExschMod(11.0, 14, 100, 0, 'Reverse3', 'end', Tweens.outelastic)
Branch:ExschMod(11.5, 14, 100, 0, 'Reverse4', 'end', Tweens.outelastic)

Branch:InsertMod(15, 2, Tweens.outelastic, {{0, 'Invert'}})

Branch:AddToModTree()
--]]
---------------------------

-- Insert mods here --

return Mods.GetModTree()

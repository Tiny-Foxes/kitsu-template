---------------------------
-- Use this file for your mods

--	Mods.new() - Creates new mod branch
--	Mods:InsertMod(start, len, ease, modpairs, [offset], [plr]) - Writes mods to branch
--      start - Starting time
--      len - Length to full percentage
--      ease - Ease function
--      modpairs - {{end_p, mod, [begin_p]}, ...}
--          end_p - Ending percent
--          mod - Mod to activate (MUST be written in PascalCase)
--          begin_p - Beginning percent (optional)
--      offset - Offset between each mod in modpairs (optional)
--      plr - Player to apply mods (optional)
--	Mods:MirinMod({start, len, ease, perc, mod, ...}, [offset], [plr]) - Writes mods to branch Mirin style
--	Mods:ExschMod(start, len, begin_p, end_p, mod, timing, ease, [offset], [plr]) - Write mods to branch Exschwasion style
--	Mods:AddToModTree() - Adds branch to mod tree
--	Mods.GetModTree() - Gets mod tree

-- This is probably much more robust than you need, so you can simply create
-- a new branch using Mods.new() branch and stuff all of your mods into it.
---------------------------

---------------------------
-- Uncomment for example --
---------------------------
--[[
local Intro = Mods.new()

local modtable = {
    {100, 'reverse1'},
    {100, 'reverse2'},
    {100, 'reverse3'},
    {100, 'reverse4'},
}

Intro
	:MirinMod {0, 1, Tweens.inoutback, 20, 'drunk', 20, 'tipsy', 100, 'bumpy', 100, 'invert'}
	:InsertMod(5, 3, Tweens.outbounce, modtable, 0.25)
	:ExschMod(10.0, 14, 100, 0, 'reverse1', 'end', Tweens.outelastic)
	:ExschMod(10.5, 14, 100, 0, 'reverse2', 'end', Tweens.outelastic)
	:ExschMod(11.0, 14, 100, 0, 'reverse3', 'end', Tweens.outelastic)
	:ExschMod(11.5, 14, 100, 0, 'reverse4', 'end', Tweens.outelastic)
	:InsertMod(15, 2, Tweens.outelastic, {{0, 'invert'}})
	:AddToModTree()
--]]
---------------------------

-- Insert mods here --

return Mods.GetModTree()

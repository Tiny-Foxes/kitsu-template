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

Branch:InsertMod(0, 2, Tweens.outexpo, {
    {100, 'Bumpy', 20000},
    {100, 'Beat', 100},
    {0, 'Tiny', -1000}
})

local mirinstyle = {5, 3, Tweens.outbounce, 100, 'Reverse1', 100, 'Reverse2', 100, 'Reverse3', 100, 'Reverse4'}
Branch:MirinMod(mirinstyle, 0.25)

Branch:MirinMod {10, 2, Tweens.outelastic, 0, 'Reverse1', 0, 'Reverse2', 0, 'Reverse3', 0, 'Reverse4'}

Branch:AddToModTree()
--]]
---------------------------

-- Insert mods here

return Mods.GetModTree()

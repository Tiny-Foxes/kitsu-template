sudo()
-- Use this file for your mods

-- Mods.new() - Creates new mod branch
-- Branch:InsertMod(start, len, ease, modpairs, [offset], [plr]) - Writes mods to branch
--      start - Starting time
--      len - Length to full percentage
--      ease - Ease function
--      modpairs - {{end_p, mod, [begin_p]}, ...}
--          end_p - Ending percent
--          mod - Mod to activate (MUST be written in PascalCase)
--          begin_p - Beginning percent (optional)
--      offset - Offset between each mod in modpairs (optional)
--      plr - Player to apply mods (optional)
-- Branch:FromTable({start, len, ease, perc, mod, ...}, [offset], [plr]) - Writes mods to branch Mirin-style
-- Branch:AddToModTree() - Adds branch to mod tree
-- Mods.GetModTree() - Gets mod tree

local Branch = Mods.new()

--local modtable = {{100, 'Bumpy', 20000}, {100, 'Beat', 100}, {0, 'Tiny', -1000}}
--Branch:InsertMod(0, 5, Tweens.outexpo, modtable)

--local mirinstyle = {5, 5, Tweens.inoutexpo, 50, 'Tipsy', 50, 'Drunk'}
--Branch:FromTable(mirinstyle)

Branch:AddToModTree()

return Mods.GetModTree()

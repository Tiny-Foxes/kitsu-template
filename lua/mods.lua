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
--	Mods:Default(modpairs) - Writes default mods to branch
--	Mods:AddToModTree() - Adds branch to mod tree
--	Mods.GetModTree() - Gets mod tree
---------------------------

local m = Mods.new():AddToModTree()

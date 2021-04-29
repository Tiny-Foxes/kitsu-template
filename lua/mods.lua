sudo()
-- Use this file for your mods

-- Mods.new() - Creates new mod branch
-- Branch:Write(start, len, ease, modpairs, [plr]) - Writes mod to branch
--      start - Starting time
--      len - Length to full percentage
--      ease - Ease function
--      modpairs - {{end_p, mod, [begin_p]}, ...}
--          end_p - Ending percent
--          mod - Mod to activate (MUST be written in PascalCase)
--          begin_p - Beginning percent (optional)
--      plr - Player to apply mods (optional)
-- Branch:AddToModTree() - Adds branch to mod tree
-- Mods.GetModTree() - Gets mod tree

local Branch = Mods.new()

-- Branch:Write(0, 5, Tweens.outexpo, {{100, 'Bumpy', 2000}, {100, 'Beat', 100}})

Branch:AddToModTree()

return Mods.GetModTree()

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

-- This is probably much more robust than you need, so you can simply create
-- a new branch using Mods.new() branch and stuff all of your mods into it.
---------------------------

---------------------------------
-- Add to mod tree for example --
---------------------------------

local example1 = Mods.new()
local example2 = Mods.new()
local example3 = Mods.new()

local modtable = {
    {100, 'reverse1'},
    {100, 'reverse2'},
    {100, 'reverse3'},
    {100, 'reverse4'},
}

-- Standard mods
example1
	:Default({{1.5, 'xmod'}})
	:MirinMod {-0.5, 1, Tweens.inoutback, 20, 'drunk', 20, 'tipsy', 100, 'bumpy', 100, 'invert'}
	:InsertMod(5, 3, Tweens.outbounce, modtable, 0.25)
	:ExschMod(10.0, 14, 100, 0, 'reverse1', 'end', Tweens.outelastic)
	:ExschMod(10.5, 14, 100, 0, 'reverse2', 'end', Tweens.outelastic)
	:ExschMod(11.0, 14, 100, 0, 'reverse3', 'end', Tweens.outelastic)
	:ExschMod(11.5, 14, 100, 0, 'reverse4', 'end', Tweens.outelastic)
	:InsertMod(15, 2, Tweens.outelastic, {{0, 'invert'}})
--example1:AddToModTree()

-- Note-specific mods
example2
	:Default({{100, 'tinyusesminicalc'}})
	-- Brush your notes, kids.
	:InsertNoteMod(0, 3, Tweens.inoutsine, {{5, 4, 100, 'movey'}}, 0, 1)
	:InsertNoteMod(3, 2, Tweens.outelastic, {{5, 4, 0, 'movey'}}, 0, 1)
	:InsertNoteMod(2, 2, Tweens.inoutcircle, {
	--	{beat, column, percent, mod}
		{5, 4, 400, 'dizzy'},
		{6, 2, 300, 'bumpy'},
		{7, 3, 100, 'tornado'},
		{8, 1, 200, 'wave'},
		{9, 4, 300, 'beat'}
	})
--example2:AddToModTree()

-- Spo('v')oky Notes
local nd = {}
for pn = 1, #PL do
	nd[pn] = PL[pn].NoteData
	for i = 1, #nd[pn] do
		local beat = nd[pn][i][1]
		local col = nd[pn][i][2]
		if beat % 5 == 4 then
			example3
				:InsertNoteMod(0, 0.25, Tweens.instant, {{beat, col, 100, 'flip'}, {beat, col, 180 * math.pi/1.8, 'confusionoffset'}, {beat, col, 90, 'stealth'}})
				:InsertNoteMod(2, 2, Tweens.inoutquad, {{beat, col, 0, 'flip'}, {beat, col, 0, 'confusionoffset'}})
		end
	end
end
--example3:AddToModTree()

---------------------------

local custom = Mods.new()
custom
	:DefineMod(
		'swingx',
		function(n)
			for pn = 1, #PL do
				PL[pn].Player:rotationx(n)
			end
			return -n * math.pi/1.8
		end,
		'confusionxoffset'
	)
	:InsertMod(0, 10, Tweens.linear, {
		{360, 'swingx'}
	})
	---[[
	:InsertMod(5, 5, Tweens.inoutexpo, {
		{0, 'swingx'}
	})
	--]]
custom:AddToModTree()

--Mods.LoadFromFile('notemod-stress')
--Mods.LoadFromFile('benchmark')

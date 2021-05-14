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
	:MirinMod {0, 1, Tweens.inoutback, 20, 'drunk', 20, 'tipsy', 100, 'bumpy', 100, 'invert'}
	:InsertMod(5, 3, Tweens.outbounce, modtable, 0.25)
	:ExschMod(10.0, 14, 100, 0, 'reverse1', 'end', Tweens.outelastic)
	:ExschMod(10.5, 14, 100, 0, 'reverse2', 'end', Tweens.outelastic)
	:ExschMod(11.0, 14, 100, 0, 'reverse3', 'end', Tweens.outelastic)
	:ExschMod(11.5, 14, 100, 0, 'reverse4', 'end', Tweens.outelastic)
	:InsertMod(15, 2, Tweens.outelastic, {{0, 'invert'}})
	--:AddToModTree()

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
	--:AddToModTree()
example3
	:InsertNoteMod(0, 0.25, Tweens.instant, {{4, 1, 100, 'flip'}, {4, 1, 180 * math.pi/1.8, 'confusionoffset'}, {4, 1, 90, 'stealth'}})
	:InsertNoteMod(2, 2, Tweens.inoutquad, {{4, 1, 0, 'flip'}, {4, 1, 0, 'confusionoffset'}})
	--:AddToModTree()

local notedata = {
	{10, 1, 1},
	{11, 2, 1},
	{12, 3, 1},
	{13, 4, 1},
	{14, 1, 1},
	{15, 4, 1},
	{16, 2, 1},
	{17, 3, 1},
	{18, 1, 1},
	{19, 4, 1},
}
local notedata2 = {
	{6, 1, 1},
	{6.5, 3, 1},
	{7, 2, 1},
	{7.5, 4, 1},
	{8, 1, 1},
	{8.5, 3, 1},
	{9, 2, 1},
	{9.5, 4, 1},
	{10, 1, 1},
	{10.5, 3, 1},
	{11, 2, 1},
	{11.5, 4, 1},
}

local test = Mods.new()
for i = 1, #notedata do
	test
		:Default {{100, 'tinyusesminicalc'}}
		:InsertNoteMod(0, 0.1, Tweens.instant, {{notedata[i][1], notedata[i][2], 100, 'flip'}, {notedata[i][1], notedata[i][2], 180 * math.pi/1.8, 'confusionoffset'}})
		:InsertNoteMod(notedata[i][1] - 5, 2, Tweens.inoutexpo, {{notedata[i][1], notedata[i][2], -5000, 'tinyz'}})
		:InsertNoteMod(notedata[i][1] - 4, 2, Tweens.inoutexpo, {{notedata[i][1], notedata[i][2], 0, 'flip'}, {notedata[i][1], notedata[i][2], 0, 'confusionoffset'}})
		:InsertNoteMod(notedata[i][1] - 3, 2, Tweens.inoutexpo, {{notedata[i][1], notedata[i][2], 0, 'tinyz'}})
end
test:AddToModTree()




---------------------------

-- Insert mods here --


return Mods.GetModTree()

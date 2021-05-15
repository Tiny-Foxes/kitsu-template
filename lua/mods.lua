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
-- Spo('v')oky Notes
example3
	:InsertNoteMod(0, 0.25, Tweens.instant, {{4, 1, 100, 'flip'}, {4, 1, 180 * math.pi/1.8, 'confusionoffset'}, {4, 1, 90, 'stealth'}})
	:InsertNoteMod(2, 2, Tweens.inoutquad, {{4, 1, 0, 'flip'}, {4, 1, 0, 'confusionoffset'}})
	--:AddToModTree()

---------------------------

-- Insert mods here --

local notedata = PL[1].NoteData

local test = Mods.new()
test:InsertMod(-10, 0.1, Tweens.instant, {{100, 'tinyusesminicalc'}, {1, 'xmod'}})
test:InsertMod(notedata[#notedata][1] - 10, 0.1, Tweens.instant, {{2, 'xmod'}})
for i = 1, #notedata - 1 do
	local beat = notedata[i][1]
	local col = notedata[i][2]
	if beat >= 84 and beat < 88 then
		test
			:InsertNoteMod(-10, 0.1, Tweens.instant, {
				{beat, col, 50, 'reverse'},
				{beat, col, -100, 'movey'},
				{beat, col, 100, 'stealth'},
				{beat, 1, 200, 'movex'},
				{beat, 2, 100, 'movex'},
				{beat, 3, 0, 'movex'},
				{beat, 4, -100, 'movex'},
			})
			:InsertNoteMod(82, 2, Tweens.inoutexpo, {
				{beat, col, 0, 'reverse'},
				{beat, col, 0, 'movey'},
				{beat, col, 0, 'stealth'},
				{beat, 1, 0, 'movex'},
				{beat, 2, 0, 'movex'},
				{beat, 3, 0, 'movex'},
				{beat, 4, 0, 'movex'},
			})
	end
	test
		:InsertNoteMod(beat - 10, 0.1, Tweens.instant, {
			{beat, col, 125, 'invert'},
			{beat, col, 25, 'flip'},
			{beat, col, 90 * math.pi/1.8, 'confusionoffset'},
			{beat, col, 200, 'holdtinyx'}
		})
		:InsertNoteMod(beat - 10, 0.1, Tweens.instant, {
			{beat, col, math.random(-2, 1) * 100, 'movey'},
			{beat, col, 645, 'movex'}
		}, nil, 1)
		:InsertNoteMod(beat - 10, 0.1, Tweens.instant, {
			{beat, col, math.random(-2, 1) * 100, 'movey'},
			{beat, col, -645, 'movex'}
		}, nil, 2)
		:InsertNoteMod(beat - 6, 3, Tweens.outelastic, {
			{beat, col, 200, 'movez'},
			{beat, col, -1000, 'tinyz'},
		})
		:InsertNoteMod(beat - 6, 2, Tweens.inoutexpo, {
			{beat, col, 0, 'invert'},
			{beat, col, 0, 'flip'},
			{beat, col, 0, 'confusionoffset'},
			{beat, col, 0, 'movex'}
		})
		:InsertNoteMod(beat - 5, 2, Tweens.inoutexpo, {
			{beat, col, 0, 'movey'}
		})
		:InsertNoteMod(beat - 4, 2, Tweens.inoutexpo, {
			{beat, col, 0, 'movez'},
			{beat, col, 0, 'tinyz'},
		})
		:InsertNoteMod(beat - 3, 2, Tweens.outexpo, {
			{beat, col, 0, 'holdtinyx'}
		})
end
test:InsertNoteMod(-10, 0.1, Tweens.instant, {
	{notedata[#notedata][1], notedata[#notedata][2], 50, 'flip'},
	{notedata[#notedata][1], notedata[#notedata][2], -750, 'tiny'},
})
test:AddToModTree()


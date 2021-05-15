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

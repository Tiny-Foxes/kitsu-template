local test = Mods.new()
local nd = PL[1].NoteData
local mod = 'beat'

--[[
	-- FPS BENCHMARKS --

	[Unfinished, I'm seeing a general pattern of "38 not fast"]

	Boost - 41
	Brake - 42
	Wave - 38
	ParabolaY - 38
	CubicY - 37
	Boomerang - 39
	RandomSpeed - 38
	Expand - 39
	TanExpand - 36
	Centered - 37
	SpiralY - 36
	BumpyY - 39
	TanBumpyY - 37
	BeatY - 38
	AttenuateY - 
	DrunkY
	TanDrunkY
	Tornado
	TanTornado
	BumpyX
	TanBumpyX
	Drunk
	TanDrunk
	Flip
	Invert
	Beat
	Zigzag
	Sawtooth
	ParabolaX
	CubicX
	Asymptote
	SpiralX
	Digital
	TanDigital
	Square
	Bounce
	XMode
	Tiny
	MoveX - 62 High, 28 Low, 35 Avg
	AttenuateX
	ConfusionXOffset
	Roll
	ConfusionYOffset
	Twirl
	ConfusionOffset
	Dizzy
	Confusion
	ConfusionX
	ConfusionY
	NoteSkewX
	NoteSkewY
	MoveY - 70 High, 32 Low, 39 Avg
	Hidden
	Sudden
	Steath
	Blink
	RandomVanish
	TornadoZ
	TanTornadoZ
	Bumpy
	TanBumpy
	SawtoothZ
	ParabolaZ
	CubicZ
	DrunkZ
	TanDrunkZ
	SpiralZ
	BeatZ
	DigitalZ
	TanDigitalZ
	SquareZ
	BounceZ
	MoveZ
	AttenuateZ
	Tiny
	TinyX
	HoldTinyX
	TinyY
	TinyZ
	PulseInner
	PulseOuter
	TanPulseInner
	TanPulseOuten
]]

---[[
for i = 1, #nd do
	local beat = nd[i][1]
	local col = nd[i][2]
	for modbeat = beat - 10, beat - 2, 2 do
		test
			:InsertNoteMod(modbeat, 0.25, Tweens.linear, {
				{beat, col, 50 * ((beat * col) % 10), mod}
			}, nil, 1)
			:InsertNoteMod(modbeat + 0.25, 0.25, Tweens.linear, {
				{beat, col, -50 * ((beat * col) % 10), mod}
			}, nil, 1)
			:InsertNoteMod(modbeat + 0.5, 0.25, Tweens.linear, {
				{beat, col, 50 * ((beat * col) % 10), mod}
			}, nil, 1)
			:InsertNoteMod(modbeat + 0.75, 0.25, Tweens.linear, {
				{beat, col, -50 * ((beat * col) % 10), mod}
			}, nil, 1)
			:InsertNoteMod(modbeat + 1, 0.25, Tweens.linear, {
				{beat, col, 50 * ((beat * col) % 10), mod}
			}, nil, 1)
			:InsertNoteMod(modbeat + 1.25, 0.25, Tweens.linear, {
				{beat, col, -50 * ((beat * col) % 10), mod}
			}, nil, 1)
			:InsertNoteMod(modbeat + 1.5, 0.25, Tweens.linear, {
				{beat, col, 50 * ((beat * col) % 10), mod}
			}, nil, 1)
			:InsertNoteMod(modbeat + 1.75, 0.25, Tweens.linear, {
				{beat, col, -50 * ((beat * col) % 10), mod}
			}, nil, 1)
			:InsertNoteMod(modbeat, 0.25, Tweens.linear, {
				{beat, col, -50 * ((beat * col) % 10), mod}
			}, nil, 2)
			:InsertNoteMod(modbeat + 0.25, 0.25, Tweens.linear, {
				{beat, col, 50 * ((beat * col) % 10), mod}
			}, nil, 2)
			:InsertNoteMod(modbeat + 0.5, 0.25, Tweens.linear, {
				{beat, col, -50 * ((beat * col) % 10), mod}
			}, nil, 2)
			:InsertNoteMod(modbeat + 0.75, 0.25, Tweens.linear, {
				{beat, col, 50 * ((beat * col) % 10), mod}
			}, nil, 2)
			:InsertNoteMod(modbeat + 1, 0.25, Tweens.linear, {
				{beat, col, -50 * ((beat * col) % 10), mod}
			}, nil, 2)
			:InsertNoteMod(modbeat + 1.25, 0.25, Tweens.linear, {
				{beat, col, 50 * ((beat * col) % 10), mod}
			}, nil, 2)
			:InsertNoteMod(modbeat + 1.5, 0.25, Tweens.linear, {
				{beat, col, -50 * ((beat * col) % 10), mod}
			}, nil, 2)
			:InsertNoteMod(modbeat + 1.75, 0.25, Tweens.linear, {
				{beat, col, 50 * ((beat * col) % 10), mod}
			}, nil, 2)
	end
end
--]]

--[[
for i = 1, #nd do
	local beat = nd[i][1]
	local col = nd[i][2]
	test:InsertNoteMod(-10, 0.1, Tweens.instant, {
		{beat, col, 100, mod}
	})
end
--]]
test:AddToModTree()
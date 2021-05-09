-- environment builder stolen this from xero thanks xero
local sudo = setmetatable(sudo, sudo)
sudo.__index = _G
local function nop() end
function sudo:__call(f, name)
	if type(f) == 'string' then
		-- if we call sudo with a string, we need to load it as code
		local err
		-- try compiling the code
		f, err = loadstring( 'return function(self)' .. f .. '\nend', name)
		if err then SCREENMAN:SystemMessage(err) return nop end
		-- grab the function
		f, err = pcall(f)
		if err then SCREENMAN:SystemMessage(err) return nop end
	end
	-- set environment
	setfenv(f or 2, self)
	return f
end

sudo()

-- First set of global variables
printerr = lua.ReportScriptError

SW, SH = SCREEN_WIDTH, SCREEN_HEIGHT -- screen width and height
SCX, SCY = SCREEN_CENTER_X, SCREEN_CENTER_Y -- screen center x and y

TICKRATE = 60 -- tickrate
TICK = 1 / TICKRATE -- seconds since last tick
CONST_TICK = false -- set this to true for automagic frame limiting!!!! o A o

DT = 0 -- seconds since last frame
BEAT = GAMESTATE:GetSongPosition():GetSongBeat() -- current beat
BPS = GAMESTATE:GetSongPosition():GetCurBPS() -- current beats per second
BPM = BPS * 60 -- beats per minute
BPT = TICK * BPS -- beats per tick
SPB = 1 / BPS -- seconds per beat
TPB = SPB * TICKRATE -- ticks per beat
CENTER_PLAYERS = false
SRT_STYLE = false

Node = assert(loadfile(SongDir .. 'lib/nodebuilder.lua'))() -- Nodebuilder
Mods = assert(loadfile(SongDir .. 'lib/modsbuilder.lua'))() -- Modsbuilder
local Corope = assert(loadfile(SongDir .. 'lib/corope.lua'))() -- Corope

Async = Corope({errhand = printerr})

PL = {}

local InputHandler = function(event)
	MESSAGEMAN:Broadcast('Input', {event})
end

return Def.ActorFrame {
	BeginFrameCommand = function(self)
		TICK = 1 / TICKRATE
		if CONST_TICK then
			DT = TICK
		else
			DT = self:GetEffectDelta()
		end
		BEAT = GAMESTATE:GetSongPosition():GetSongBeat()
		BPS = GAMESTATE:GetSongPosition():GetCurBPS()
		BPM = BPS * 60
		BPT = TICK * BPS
		SPB = 1 / BPS
		TPB = SPB * TICKRATE
		MESSAGEMAN:Broadcast('Update')
	end,
	UpdateMessageCommand = function(self)
		Async:update(DT)
		if sudo.update then
			sudo.update(DT)
		end
		self:queuecommand('EndFrame')
	end,
	EndFrameCommand = function(self)
		self:sleep(DT)
		self:queuecommand('BeginFrame')
	end,
	ReadyCommand = function(self)
		-- Second set of global variables
		SCREEN = SCREENMAN:GetTopScreen() -- top screen
		SCREEN:AddInputCallback(InputHandler)
		for i, v in ipairs( GAMESTATE:GetEnabledPlayers() ) do
			local info = {}

			local pl = SCREEN:GetChild('Player'..ToEnumShortString(v))
			info.Player = pl
			info.Combo = pl:GetChild('Combo')
			info.Judgment = pl:GetChild('Judgment')
			info.NoteField = pl:GetChild('NoteField')

			PL[i] = info
		end
		--P1, P2 = SCREEN:GetChild('PlayerP1') or nil, SCREEN:GetChild('PlayerP2') or nil -- player 1 and 2
		--L1, L2 = SCREEN:GetChild('LifeP1') or nil, SCREEN:GetChild('LifeP2') or nil -- life 1 and 2
		--S1, S2 = SCREEN:GetChild('ScoreP1') or nil, SCREEN:GetChild('ScoreP2') or nil -- life 1 and 2
		--C1, C2 = PL[1]:GetChild('Combo') or nil, PL[2]:GetChild('Combo') or nil -- combo 1 and 2
		--J1, J2 = PL[1]:GetChild('Judgment') or nil, PL[2]:GetChild('Judgment') or nil -- judgment 1 and 2
		--N1, N2 = PL[1]:GetChild('NoteField') or nil, PL[2]:GetChild('NoteField') or nil -- notefield 1 and 2
		PL = setmetatable(PL, {
			__index = function(this, number)
				if number < 1 or number > #this then
					printerr( string.format("[PL] No player was found on index %i, using first item instead.", number) )
					return this[1]
				end
				return this
			end
		})
		if sudo.ready then
			sudo.ready()
		end
		if CENTER_PLAYERS then
			for pn = 1, #PL do
				PL[pn].Player:x(SCX)
			end
		end
		if SRT_STYLE then
			for i = 1, #PL do
				SCREEN:GetChild('LifeP'..i):visible(false)
				SCREEN:GetChild('ScoreP'..i):visible(false)
			end
			SCREEN:GetChild('Overlay'):visible(false)
		end
		self:queuecommand('BeginFrame')
	end,
	InputMessageCommand = function(self, args)
		if sudo.input then
			sudo.input(args[1])
		end
	end,
	OffCommand = function(self)
		SCREEN:RemoveInputCallback(InputHandler)
	end
}

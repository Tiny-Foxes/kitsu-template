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
TICK = 1 / TICKRATE -- seconds since last update

DT = 0 -- actual seconds since last update
BEAT = GAMESTATE:GetSongPosition():GetSongBeat() -- current beat
BPS = GAMESTATE:GetSongPosition():GetCurBPS() -- current beats per second
BPM = BPS * 60 -- beats per minute
BPT = TICK * BPS -- beats per tick
SPB = 1 / BPS -- seconds per beat
TPB = SPB * TICKRATE -- ticks per beat

Node = assert(loadfile(SongDir .. 'lib/nodebuilder.lua'))() -- Nodebuilder
Mods = assert(loadfile(SongDir .. 'lib/modsbuilder.lua'))() -- Modsbuilder
local Corope = assert(loadfile(SongDir .. 'lib/corope.lua'))() -- Asynchronous

Async = Corope({errhand = lua.ReportScriptError})

return Def.ActorFrame {
	UpdateMessageCommand = function(self)
		DT = self:GetEffectDelta() -- Set this to TICK for automagic frame limiting!!!! o A o
		BEAT = GAMESTATE:GetSongPosition():GetSongBeat()
		BPS = GAMESTATE:GetSongPosition():GetCurBPS()
		BPM = BPS * 60
		BPT = TICK * BPS
		SPB = 1 / BPS
		TPB = SPB * TICKRATE
		Async:update(DT)
		if sudo.update then
			sudo.update(DT)
		end
		self:queuecommand('On')
	end,
	OnCommand = function(self)
		self:sleep(DT)
		MESSAGEMAN:Broadcast('Update')
	end,
	ReadyCommand = function(self)
		-- Second set of global variables
		SCREEN = SCREENMAN:GetTopScreen() -- top screen
		P1, P2 = SCREEN:GetChild('PlayerP1'), SCREEN:GetChild('PlayerP2') -- player 1 and 2
		L1, L2 = SCREEN:GetChild('LifeP1'), SCREEN:GetChild('LifeP2') -- life 1 and 2
		S1, S2 = SCREEN:GetChild('ScoreP1'), SCREEN:GetChild('ScoreP2') -- life 1 and 2
		C1, C2 = P1:GetChild('Combo'), P2:GetChild('Combo') -- combo 1 and 2
		J1, J2 = P1:GetChild('Judgment'), P2:GetChild('Judgment') -- judgment 1 and 2
		N1, N2 = P1:GetChild('NoteField'), P2:GetChild('NoteField') -- notefield 1 and 2
		if sudo.ready then
			sudo.ready()
		end
	end
}

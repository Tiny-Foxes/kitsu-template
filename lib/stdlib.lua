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

function import(lib)
	return sudo(assert(loadfile(SongDir..'lib/'..lib..'.lua')))()
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

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

if not _G.Tweens.instant then
	Tweens.instant = function(x) return 1 end
end

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
			if not pl and SCREEN:GetName() == 'ScreenEdit' then
				pl = SCREEN:GetChildAt(7)
			end
			info.Player = pl
			info.Life = SCREEN:GetChild('Life'..ToEnumShortString(v))
			info.Score = SCREEN:GetChild('Score'..ToEnumShortString(v))
			info.Combo = pl:GetChild('Combo')
			info.Judgment = pl:GetChild('Judgment')
			info.NoteField = pl:GetChild('NoteField')
			info.NoteData = pl:GetNoteData()
	
			PL[i] = info
		end
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
		self:queuecommand('Start')
	end,
	StartCommand = function(self)
		if CENTER_PLAYERS then
			for pn = 1, #PL do
				PL[pn].Player:x(SCX)
			end
		end
		if SRT_STYLE then
			SCREEN:GetChild('Underlay'):visible(false)
			for i = 1, #PL do
				if PL[i].Life then PL[i].Life:visible(false) end
				if PL[i].Score then PL[i].Score:visible(false) end
			end
			SCREEN:GetChild('Overlay'):visible(false)
		end
		MESSAGEMAN:Broadcast('Draw')
		self:queuecommand('BeginFrame')
	end,
	InputMessageCommand = function(self, args)
		if sudo.input then
			sudo.input(args[1])
		end
	end,
	OffCommand = function(self)
		SCREEN:RemoveInputCallback(InputHandler)
	end,
}

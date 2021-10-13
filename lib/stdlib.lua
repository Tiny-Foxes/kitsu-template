-- stdlib.lua --

-- Environment global variables, mostly shortcuts
songdir = GAMESTATE:GetCurrentSong():GetSongDir()
print = lua.Trace
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
PL = {}

-- A bit of work to get the true start of our FG changes.
local f = RageFileUtil.CreateRageFile()
f:Open(songdir .. 'notes.ssc', 1)
local chart = f:Read()
f:Close()
local fgfirst = chart:find('#FGCHANGES:') + ('#FGCHANGES:'):len()
local fglast = chart:find('=', fgfirst) - 1

MOD_START = chart:sub(fgfirst, fglast)

-- This might not be added on the engine side yet.
if not _G.Tweens.instant then
	Tweens.instant = function(x) return 1 end
end

function aftmult(a)
	return a * 0.9
end

function InitAFT(aft, recursive)
	if not recursive then
		aft
			:SetSize(SW, SH)
			:EnableFloat(false)
			:EnableDepthBuffer(true)
			:EnableAlphaBuffer(true)
			:EnablePreserveTexture(false)
			:Create()
	else
		aft
			:SetSize(SW, SH)
			:EnableFloat(false)
			:EnableDepthBuffer(true)
			:EnableAlphaBuffer(false)
			:EnablePreserveTexture(true)
			:Create()
	end
end

function MapAFT(aft, sprite)
	sprite
		:Center()
		:SetTexture(aft:GetTexture())
end


local InputHandler = function(event)
	MESSAGEMAN:Broadcast('Input', {event})
end

return Def.ActorFrame {
	InitCommand = function(self)
		std = {}
		for k, v in pairs(_G.sudo) do
			if _G.sudo[k] ~= _G[k] then
				std[k] = _G.sudo[k]
			end
		end
	end,
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
		-- Actor variables
		SCREEN = SCREENMAN:GetTopScreen()
		SCREEN:AddInputCallback(InputHandler)
		for i, v in ipairs( GAMESTATE:GetEnabledPlayers() ) do
			local info = {}
	
			local pl = SCREEN:GetChild('Player'..ToEnumShortString(v))
			info.Player = pl
			info.Life = SCREEN:GetChild('Life'..ToEnumShortString(v))
			info.Score = SCREEN:GetChild('Score'..ToEnumShortString(v))
			info.Combo = pl:GetChild('Combo')
			info.Judgment = pl:GetChild('Judgment')
			info.NoteField = pl:GetChild('NoteField')
			info.NoteData = pl:GetNoteData()
			info.Options = GAMESTATE:GetPlayerState(v):GetPlayerOptions('ModsLevel_Song')
	
			PL[i] = info
		end
		PL = setmetatable(PL, {
			__index = function(this, number)
				if number < 1 or number > #this then
					print( string.format("[PL] No player was found on index %i, using first item instead.", number) )
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
				PL[i].Life:visible(false)
				PL[i].Score:visible(false)
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

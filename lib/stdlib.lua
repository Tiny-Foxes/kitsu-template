-- stdlib.lua --

local std = {}
setmetatable(std, {})

-- Standard library variables, mostly shortcuts
local songdir = GAMESTATE:GetCurrentSong():GetSongDir()

local SW, SH = SCREEN_WIDTH, SCREEN_HEIGHT -- screen width and height
local SCX, SCY = SCREEN_CENTER_X, SCREEN_CENTER_Y -- screen center x and y

local DT = 0 -- seconds since last frame

local BEAT = function() return GAMESTATE:GetSongPosition():GetSongBeat() end -- current beat
local BPS = function() return GAMESTATE:GetSongPosition():GetCurBPS() end -- current beats per second
local BPM = function() return BPS() * 60 end -- beats per minute
local SPB = function() return 1 / BPS() end -- seconds per beat
local SRT_STYLE = false
local PL = {}

-- A bit of work to get the true start of our FG changes.
local f = RageFileUtil.CreateRageFile()
f:Open(songdir .. 'notes.ssc', 1)
local chart = f:Read()
f:Close()
local fgfirst = chart:find('#FGCHANGES:') + ('#FGCHANGES:'):len()
local fglast = chart:find('=', fgfirst) - 1

local MOD_START = tonumber(chart:sub(fgfirst, fglast))

-- This might not be added on the engine side yet.
if not _G.Tweens.instant then
	Tweens.instant = function(x) return 1 end
end

function std.aftmult(a)
	return a * 0.9
end

function std.InitAFT(aft, recursive)
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

function std.MapAFT(aft, sprite)
	sprite
		:Center()
		:SetTexture(aft:GetTexture())
end


local InputHandler = function(event)
	MESSAGEMAN:Broadcast('Input', {event})
end

-- Our foreground to put everything in. If FG is not set, this will take its place.
FG[#FG + 1] = Def.Actor {
	InitCommand = function(self)
		if sudo.init then
			sudo.init()
		end
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
	end,
	UpdateMessageCommand = function(self, param)
		DT = param[1]
		if sudo.update then
			sudo.update(DT)
		end
	end,
	OffCommand = function(self)
		SCREEN:RemoveInputCallback(InputHandler)
	end,
}

--[[
for k, v in pairs(fgcmd) do
	local func = FG[k]
	FG[k] = function(self)
		if func then func(self)
		v(self)
	end
end
--]]

std = {
	songdir = songdir,
	SW = SW,
	SH = SH,
	SCX = SCX,
	SCY = SCY,
	TICKRATE = TICKRATE,
	TICK = TICK,
	CONST_TICK = CONST_TICK,
	MOD_START = MOD_START,
	DT = DT,
	BEAT = BEAT,
	BPS = BPS,
	BPM = BPM,
	BPT = BPT,
	SPB = SBT,
	TPB = TPB,
	PL = PL,
	aftmult = aftmult,
	InitAFT = InitAFT,
	MapAFT = MapAFT,
}
std.__index = std

print('Loaded Kitsu Standard Library')
return std

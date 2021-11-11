-- stdlib.lua --

local std = {}
setmetatable(std, {})

std.VERSION = '1.4'

-- Standard library variables, mostly shortcuts
std.POS = GAMESTATE:GetSongPosition()
std.DIR = GAMESTATE:GetCurrentSong():GetSongDir()

std.COLNUM = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
std.GAME = GAMESTATE:GetCurrentGame()

std.SW, std.SH = SCREEN_WIDTH, SCREEN_HEIGHT -- screen width and height
std.SCX, std.SCY = SCREEN_CENTER_X, SCREEN_CENTER_Y -- screen center x and y

std.DT = 0 -- time since last frame in seconds

std.BEAT = std.POS:GetSongBeat() -- current beat
std.BPS = std.POS:GetCurBPS() -- current beats per second
std.BPM = std.BPS * 60 -- beats per minute
std.SPB = 1 / std.BPS -- seconds per beat

std.PL = {}

-- A bit of work to get the true start of our FG changes.
-- Take this out as soon as getting FG changes is possible in Lua. ~Sudo
local f = RageFileUtil.CreateRageFile()
f:Open(std.DIR .. 'notes.ssc', 1)
local chart = f:Read()
f:Close()
local fgfirst = chart:find('#FGCHANGES:') + ('#FGCHANGES:'):len()
local fglast = chart:find('=', fgfirst) - 1

std.MOD_START = tonumber(chart:sub(fgfirst, fglast))

fglast = nil
fgfirst = nil
chart = nil
f = nil

local env = getfenv(2)

-- This might not be added on the engine side yet.
if not Tweens.instant then
	Tweens.instant = function(x) return 1 end
end


local InputHandler = function(event)
	if env.input then
		env.input(event)
	end
	MESSAGEMAN:Broadcast('Input', {event})
end


-- Our foreground to put everything in. If FG is not set, this will take its place.
if FG.stdlib then
	--print('We have stdlib already, loading mini-actor instead')
	FG[#FG + 1] = Def.ActorFrame {
		ReadyCommand = function(self)
			std.SCREEN = SCREENMAN:GetTopScreen()
			for i, v in ipairs( GAMESTATE:GetEnabledPlayers() ) do
				local info = {}
		
				local pl = std.SCREEN:GetChild('Player'..ToEnumShortString(v))
				if not plr and std.SCREEN.GetEditState then
					for _,v in pairs(std.SCREEN:GetChild('')) do
						if string.find(tostring(v),'Player') then
							pl = v
						end
					end
				end
				info.Player = pl
				info.Life = std.SCREEN:GetChild('Life'..ToEnumShortString(v))
				info.Score = std.SCREEN:GetChild('Score'..ToEnumShortString(v))
				info.Combo = pl:GetChild('Combo')
				info.Judgment = pl:GetChild('Judgment')
				info.NoteField = pl:GetChild('NoteField')
				info.NoteData = pl:GetNoteData()
				info.State = GAMESTATE:GetPlayerState(v)
				info.Stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(v)
				info.Options = GAMESTATE:GetPlayerState(v):GetPlayerOptions('ModsLevel_Current')
				info.Columns = pl:GetChild('NoteField'):GetColumnActors()
		
				std.PL[i] = info
			end
			std.PL = setmetatable(std.PL, {
				__index = function(this, number)
					if number < 1 or number > #this then
						print( string.format("[PL] No player was found on index %i, using first item instead.", number) )
						return this[1]
					end
					return this
				end
			})
		end,
		UpdateCommand = function(self)
			std.BEAT = std.POS:GetSongBeat() -- current beat
			std.BPS = std.POS:GetCurBPS() -- current beats per second
			std.BPM = std.BPS * 60 -- beats per minute
			std.SPB = 1 / std.BPS -- seconds per beat
			std.DT = self:GetEffectDelta() -- time since last frame in seconds
		end,
	}
else
	FG.stdlib = true
	FG[#FG + 1] = Def.ActorFrame {
		Name = 'stdlib',
		InitCommand = function(self)
			if init then
				init()
			end
		end,
		ReadyCommand = function(self)
			std.SCREEN = SCREENMAN:GetTopScreen()
			std.SCREEN:AddInputCallback(InputHandler)
			for i, v in ipairs( GAMESTATE:GetEnabledPlayers() ) do
				local info = {}
		
				local pl = std.SCREEN:GetChild('Player'..ToEnumShortString(v))
				if not plr and std.SCREEN.GetEditState then
					for _,v in pairs(std.SCREEN:GetChild('')) do
						if string.find(tostring(v),'Player') then
							pl = v
						end
					end
				end
				info.Player = pl
				info.Number = v
				info.Life = std.SCREEN:GetChild('Life'..ToEnumShortString(v))
				info.Score = std.SCREEN:GetChild('Score'..ToEnumShortString(v))
				info.Combo = pl:GetChild('Combo')
				info.Judgment = pl:GetChild('Judgment')
				info.NoteField = pl:GetChild('NoteField')
				info.NoteData = pl:GetNoteData()
				info.State = GAMESTATE:GetPlayerState(v)
				info.Stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(v)
				info.Options = GAMESTATE:GetPlayerState(v):GetPlayerOptions('ModsLevel_Current')
				info.Columns = pl:GetChild('NoteField'):GetColumnActors()
		
				std.PL[i] = info
			end
			std.PL = setmetatable(std.PL, {
				__index = function(this, number)
					if number < 1 or number > #this then
						print( string.format("[PL] No player was found on index %i, using first item instead.", number) )
						return this[1]
					end
					return this
				end
			})
			-- We need new values for these ASAP, since before init gives us bad values.
			std.BEAT = std.POS:GetSongBeat() -- current beat
			std.BPS = std.POS:GetCurBPS() -- current beats per second
			std.BPM = std.BPS * 60 -- beats per minute
			std.SPB = 1 / std.BPS -- seconds per beat
			std.DT = self:GetEffectDelta() -- time since last frame in seconds
			if ready then
				ready()
			end
			if draw then
				self:SetDrawFunction(draw)
			end
		end,
		UpdateCommand = function(self)
			std.BEAT = std.POS:GetSongBeat()
			std.BPS = std.POS:GetCurBPS()
			std.BPM = std.BPS * 60
			std.SPB = 1 / std.BPS
			std.DT = self:GetEffectDelta()
			if update then
				update(std.DT)
			end
		end,
		OffCommand = function(self)
			std.SCREEN:RemoveInputCallback(InputHandler)
		end,
	}
end


function std.aftmult(a)
	return a * 0.9
end

function std.InitAFT(aft, recursive)
	if not recursive then
		aft
			:SetSize(std.SW, std.SH)
			:EnableFloat(false)
			:EnableDepthBuffer(false)
			:EnableAlphaBuffer(false)
			:EnablePreserveTexture(false)
			:Create()
	else
		aft
			:SetSize(std.SW, std.SH)
			:EnableFloat(false)
			:EnableDepthBuffer(false)
			:EnableAlphaBuffer(true)
			:EnablePreserveTexture(true)
			:Create()
	end
end

function std.MapAFT(aft, sprite)
	sprite
		:Center()
		:SetTexture(aft:GetTexture())
end

function std.ProxyPlayer(proxy, pn)
	local pn_str = ToEnumShortString(GAMESTATE:GetEnabledPlayers()[pn])
	local plr = SCREENMAN:GetTopScreen():GetChild('Player'..pn_str)
	proxy:SetTarget(plr)
	plr:visible(false)
	std.PL[pn].ProxyP = proxy
end

function std.ProxyJudgment(proxy, pn)
	local pn_str = ToEnumShortString(GAMESTATE:GetEnabledPlayers()[pn])
	local plr = SCREENMAN:GetTopScreen():GetChild('Player'..pn_str)
	proxy
		:SetTarget(plr:GetChild('Judgment'))
		:xy(plr:GetX(), std.SCY)
		:zoom(THEME:GetMetric('Common', 'ScreenHeight') / 720)
	plr:GetChild('Judgment')
		:visible(false)
		:sleep(9e9)
	std.PL[pn].ProxyJ = proxy
end

function std.ProxyCombo(proxy, pn)
	local pn_str = ToEnumShortString(GAMESTATE:GetEnabledPlayers()[pn])
	local plr = SCREENMAN:GetTopScreen():GetChild('Player'..pn_str)
	proxy
		:SetTarget(plr:GetChild('Combo'))
		:xy(plr:GetX(), std.SCY)
		:zoom(THEME:GetMetric('Common', 'ScreenHeight') / 720)
	plr:GetChild('Combo')
		:visible(false)
		:sleep(9e9)
	std.PL[pn].ProxyC = proxy
end


std.__index = std

print('Loaded Kitsu Standard Library v'..std.VERSION)

return std

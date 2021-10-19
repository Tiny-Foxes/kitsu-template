-- stdlib.lua --

local std = {}
setmetatable(std, {})

std.VERSION = '1.1'

-- Standard library variables, mostly shortcuts
std.POS = GAMESTATE:GetSongPosition()
std.DIR = GAMESTATE:GetCurrentSong():GetSongDir()

std.SW, std.SH = SCREEN_WIDTH, SCREEN_HEIGHT -- screen width and height
std.SCX, std.SCY = SCREEN_CENTER_X, SCREEN_CENTER_Y -- screen center x and y

std.DT = 0 -- time since last frame in seconds

std.BEAT = std.POS:GetSongBeat() -- current beat
std.BPS = std.POS:GetCurBPS() -- current beats per second
std.BPM = std.BPS * 60 -- beats per minute
std.SPB = 1 / std.BPS -- seconds per beat
std.PL = {}

-- A bit of work to get the true start of our FG changes.
local f = RageFileUtil.CreateRageFile()
f:Open(std.DIR .. 'notes.ssc', 1)
local chart = f:Read()
f:Close()
local fgfirst = chart:find('#FGCHANGES:') + ('#FGCHANGES:'):len()
local fglast = chart:find('=', fgfirst) - 1

std.MOD_START = tonumber(chart:sub(fgfirst, fglast))

-- This might not be added on the engine side yet.
if not Tweens.instant then
	Tweens.instant = function(x) return 1 end
end


local InputHandler = function(event)
	MESSAGEMAN:Broadcast('Input', {event})
end

-- Our foreground to put everything in. If FG is not set, this will take its place.
FG[#FG + 1] = Def.ActorFrame {
	InitCommand = function(self)
		if sudo.init then
			sudo.init()
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
			info.Life = std.SCREEN:GetChild('Life'..ToEnumShortString(v))
			info.Score = std.SCREEN:GetChild('Score'..ToEnumShortString(v))
			info.Combo = pl:GetChild('Combo')
			info.Judgment = pl:GetChild('Judgment')
			info.NoteField = pl:GetChild('NoteField')
			info.NoteData = pl:GetNoteData()
			info.Options = GAMESTATE:GetPlayerState(v):GetPlayerOptions('ModsLevel_Current')
	
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
	StartCommand = function(self)
		if sudo.ready then
			sudo.ready()
		end
		if sudo.draw then
			self:SetDrawFunction(sudo.draw)
		end
	end,
	UpdateCommand = function(self, param)
		std.BEAT = std.POS:GetSongBeat() -- current beat
		std.BPS = std.POS:GetCurBPS() -- current beats per second
		std.BPM = std.BPS * 60 -- beats per minute
		std.SPB = 1 / std.BPS -- seconds per beat
		std.DT = param[1] -- time since last frame in seconds
		if sudo.update then
			sudo.update(std.DT)
		end
	end,
	OffCommand = function(self)
		std.SCREEN:RemoveInputCallback(InputHandler)
	end,
}


function std.aftmult(a)
	return a * 0.9
end

function std.InitAFT(aft, recursive)
	if not recursive then
		aft
			:SetSize(std.SW, std.SH)
			:EnableFloat(false)
			:EnableDepthBuffer(true)
			:EnableAlphaBuffer(true)
			:EnablePreserveTexture(false)
			:Create()
	else
		aft
			:SetSize(std.SW, std.SH)
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

function std.ProxyPlayer(pn)
	return Def.ActorProxy {
		ReadyCommand = function(self)
			local plr = SCREENMAN:GetTopScreen():GetChild('PlayerP'..pn)
			self:SetTarget(plr)
			plr:visible(false)
		end
	}
end

function std.ProxyJudgment(pn)
	return Def.ActorProxy {
		ReadyCommand = function(self)
			local plr = SCREENMAN:GetTopScreen():GetChild('PlayerP'..pn)
			self
				:SetTarget(plr:GetChild('Judgment'))
				:xy(plr:GetX(), std.SCY)
				:zoom(THEME:GetMetric('Common', 'ScreenHeight') / 720)
			plr:GetChild('Judgment')
				:visible(false)
				:sleep(9e9)
		end
	}
end

function std.ProxyCombo(pn)
	return Def.ActorProxy {
		ReadyCommand = function(self)
			local plr = SCREENMAN:GetTopScreen():GetChild('PlayerP'..pn)
			self
				:SetTarget(plr:GetChild('Combo'))
				:xy(plr:GetX(), std.SCY)
				:zoom(THEME:GetMetric('Common', 'ScreenHeight') / 720)
			plr:GetChild('Combo')
				:visible(false)
				:sleep(9e9)
		end
	}
end


std.__index = std

print('Loaded Kitsu Standard Library v'..std.VERSION)
return std

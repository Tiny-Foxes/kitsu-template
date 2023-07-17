-- konko-mods.lua --

---------------------------
--	Mods:Insert(start, len, ease, modpairs, [offset], [plr]) - Writes mods to branch
--      start - Starting time
--      len - Length to full percentage
--      ease - Ease function
--      modpairs - {{end_p, mod, [begin_p]}, ...}
--          end_p - Ending percent
--          mod - Mod to activate (PascalCase uses player option functions)
--          begin_p - Beginning percent (optional)
--      offset - Offset between each mod in modpairs (optional)
--      plr - Player to apply mods (optional)
--	Mods:Define(name, func, return) - Defines a new mod from a function
--	Mods:FromFile(path) - Reads mods from a separate file
--	Mods:Mirin({start, len, ease, perc, mod, ...}, [offset], [plr]) - Writes mods to branch Mirin style
--	Mods:Exsch(start, len, begin_p, end_p, mod, timing, ease, [offset], [plr]) - Write mods to branch Exschwasion style
--	Mods:Default(modpairs) - Writes default mods to branch
---------------------------
depend ('konko-mods', std, 'stdlib')

Mods = {}
setmetatable(Mods, {})

-- Version and author
local VERSION = '1.5'
local AUTHOR = 'Sudospective'


local POptions = {}
local POToLower = {}
local plrcount = 0
for i, v in ipairs( GAMESTATE:GetEnabledPlayers() ) do
    POptions[i] = GAMESTATE:GetPlayerState(v):GetPlayerOptions('ModsLevel_Song')
end
for k, v in pairs(PlayerOptions) do
	POToLower[k:lower()] = v
end

local instant_tween = function(t) return 1 end

-- From the Mirin template. It just works? Fuck me... ~Sudo
local function insertion_sort(t, l, h, c)
	for i = l + 1, h do
		local k = l
		local v = t[i]
		for j = i, l + 1, -1 do
			if c(v, t[j - 1]) then
				t[j] = t[j - 1]
			else
				k = j
				break
			end
		end
		t[k] = v
	end
end
local function merge(t, b, l, m, h, c)
	if c(t[m], t[m + 1]) then
		return
	end
	local i, j, k
	i = 1
	for j = l, m do
		b[i] = t[j]
		i = i + 1
	end
	i, j, k = 1, m + 1, l
	while k < j and j <= h do
		if c(t[j], b[i]) then
			t[k] = t[j]
			j = j + 1
		else
			t[k] = b[i]
			i = i + 1
		end
		k = k + 1
	end
	for k = k, j - 1 do
		t[k] = b[i]
		i = i + 1
	end
end
local magic_number = 12
local function merge_sort(t, b, l, h, c)
	if h - l < magic_number then
		insertion_sort(t, l, h, c)
	else
		local m = math.floor((l + h) / 2)
		merge_sort(t, b, l, m, c)
		merge_sort(t, b, m + 1, h, c)
		merge(t, b, l, m, h, c)
	end
end
local function default_comparator(a, b) return a < b end
local function flip_comparator(c) return function(a, b) return c(b, a) end end
local function stable_sort(t, c)
	if not t[2] then return t end
	c = c or default_comparator
	local n = t.n
	local b = {}
	b[math.floor((n + 1) / 2)] = t[1]
	merge_sort(t, b, 1, n, c)
	return t
end

local modlist = {}
local notelist = {}
local mod_percents = {}
local note_percents = {}
local custom_mods = {}
local default_mods = {}
local active = {}
local active_mods = {}

local function PlayerCount(num)
	if not num then return plrcount end
	plrcount = num
	for pn = 1, plrcount do
		mod_percents[pn] = {}
		mod_percents[pn].start_index = 0
		note_percents[pn] = {}
		custom_mods[pn] = {}
		default_mods[pn] = {}
		active[pn] = {}
	end
	return Mods
end

PlayerCount(2)

--[[
local function ApplyMods(mod, percent, pn)
	if custom_mods[pn][mod] ~= nil then
		local new_perc = custom_mods[pn][mod].Function(percent, pn)
		local new_mod = custom_mods[pn][mod].Return
		percent = new_perc -- haha :TacMeme2:
		mod = new_mod
	end
    if mod then
		-- TODO: Fix mod ease calculations so percentage doesn't end up backwards
		local modstring = '*-1 '..(percent)..' '..mod:lower()
		if mod:sub(2):lower() == 'mod' then
			modstring = '*-1 '..percent..mod:sub(1, 1):lower()
		end
		if pn then
			POptions[pn]:FromString(modstring)
		else
			for p = 1, plrcount do
				POptions[p]:FromString(modstring)
			end
		end
	end
end
--]]
-- TODO: Make sure this doesn't run on unnecessary frames. ~Sudo
-- NOTE: Due to the nature of ModsLevel_Current, EVERY frame is a necessary frame. ~Sudo
local function resolve_customs(mods, pn)
	for mod, percent in pairs(mods) do
		if custom_mods[pn][mod] ~= nil then
			local new_percs = {custom_mods[pn][mod].Function(percent, pn)}
			local new_mods = custom_mods[pn][mod].Return
			local t = {}
			for i = 1, #new_mods do
				t[new_mods[i]] = new_percs[i]
			end
			resolve_customs(t, pn)
		else
			mod_percents[pn][mod] = percent
		end
	end
end
local function ApplyMods()
	for pn = 1, plrcount do
		local modstring = ''
		resolve_customs(mod_percents[pn], pn)
		for mod, percent in pairs(mod_percents[pn]) do
			if mod_percents[pn][mod] and not custom_mods[pn][mod] then
				if POptions[pn][mod] then
					if mod:sub(2, -1):lower() == 'mod' then
						POptions[pn][mod](POptions[pn], percent, 9e9)
					else
						POptions[pn][mod](POptions[pn], percent * 0.01, 9e9)
					end
				elseif POToLower[mod:lower()] and not mod:find('mod') then
					POToLower[mod](POptions[pn], percent * 0.01, 9e9)
				elseif mod:lower() == 'xmod' then
					modstring = modstring..'*-1 '..percent..mod:sub(1, 1):lower()..','
				elseif mod:sub(2):lower() == 'mod' then
					modstring = modstring..'*-1 '..mod:sub(1, 1):lower()..percent..','
				else
					modstring = modstring..'*-1 '..percent..' '..mod:lower()..','
				end
			end
		end
		if modstring ~= '' then POptions[pn]:FromString(modstring) end
	end
end
local function ApplyNoteMod(beat, col, mod, percent, pn)
	-- Code to turn on notemods once will go here once function is implemented engine side
	print(percent)
	mod = mod:lower()
	if pn then
		std.PL[pn].NoteField:AddNoteMod(beat, col, mod, percent * 0.01)
	else
		for p = 1, plrcount do
			std.PL[p].NoteField:AddNoteMod(beat, col, mod, percent * 0.01)
		end
	end
end
local function ApplyNotes()
	for pn = 1, plrcount do
		for notemod, percent in pairs(note_percents[pn]) do
			local t = split('|', notemod)
			ApplyNoteMod(t[2], t[3], t[1], percent, pn)
		end
	end
end

local function UpdateMods()
    for i, m in ipairs(active_mods) do
		for j, v in ipairs(m.Modifiers) do
			-- If the player where we're trying to access is not available, then don't even update.
			if m.Player and not POptions[m.Player] then break end
			local BEAT = std.BEAT
			local pn = m.Player
			if BEAT >= m.Start and BEAT < (m.Start + m.Length) then
				if m.Type == 'Blend' then
					-- Ease blending is a work in progress. Try to make sure two eases don't use the same mod.
					v[3] = v[3] or mod_percents[pn][v[2]] or 0
					active[pn][v[2]] = active[pn][v[2]] or {}
					v[4] = v[4] or (#active[pn][v[2]] + 1)
					active[pn][v[2]][v[4]] = m
					local perc = 0
					for n = 1, v[4] do
						if n <= v[4] then
							local offset = (n < v[4]) and 1 or 0
							local cur_m = active[pn][v[2]][n]
							local cur_v1 = cur_m.Modifiers[j][1]
							local cur_v3 = cur_m.Modifiers[j][3]
							local cur_off = offset
							local cur_ease = cur_m.Ease((BEAT - cur_m.Start) * OFMath.oneoverx(cur_m.Length)) - cur_off
							if m.Length == 0 then cur_ease = cur_m.Ease(1) - cur_off end
							local cur_perc = cur_ease * (cur_v1 - cur_v3) + cur_v3
							perc = perc + cur_perc
						end
					end
					mod_percents[pn][v[2]] = perc
				elseif m.Type == 'Player' then
					v[3] = v[3] or mod_percents[pn][v[2]] or default_mods[pn][v[2]] or 0
					local ease = m.Ease((BEAT - m.Start) * OFMath.oneoverx(m.Length))
					if m.Length == 0 then ease = m.Ease(1) end
					local perc = ease * (v[1] - v[3]) + v[3]
					mod_percents[pn][v[2]] = perc
				-- again, broken, fuck me man i dont know how xero does it this sucks
				elseif m.Type == 'NoteBlend' then
					local notemod = v[4]..'|'..v[1]..'|'..v[2]
					v[5] = v[5] or note_percents[pn][notemod] or default_mods[pn][notemod] or 0
					active[pn][notemod] = active[pn][notemod] or {}
					v[6] = v[6] or (#active[pn][notemod] + 1)
					active[pn][notemod][v[6]] = m
					local perc = 0
					for n = 1, v[6] do
						local offset = (n > v[6]) and 1 or 0
						local cur_m = active[pn][notemod][n]
						local cur_v3 = cur_m.Modifiers[j][3]
						local cur_v5 = cur_m.Modifiers[j][5]
						local cur_ease = cur_m.Ease((BEAT - cur_m.Start) * OFMath.oneoverx(cur_m.Length)) - offset
						if m.Length == 0 then cur_ease = 1 end
						local cur_perc = cur_ease * (cur_v3 - cur_v5)
						if #active[pn][notemod] == n then
							perc = perc + (cur_v5 + cur_perc)
						end
					end
					note_percents[pn][notemod] = perc
				elseif m.Type == 'Note' then
					local notemod = v[4]..'|'..v[1]..'|'..v[2]
					v[5] = v[5] or note_percents[pn][notemod] or default_mods[pn][notemod] or 0
					local ease = m.Ease((BEAT - m.Start) * OFMath.oneoverx(m.Length))
					if m.Length == 0 then ease = m.Ease(1) end
					local perc = ease * (v[3] - v[5]) + v[5]
					note_percents[pn][notemod] = perc
				end
			elseif BEAT >= (m.Start + m.Length) then
				if m.Type == 'Player' then
					v[3] = v[3] or mod_percents[pn][v[2]] or 0
					mod_percents[pn][v[2]] = m.Ease(1) * (v[1] - v[3]) + v[3]
					if v[4] and active[pn][v[2]][v[4]] then
						table.remove(active[pn][v[2]], v[4])
						v[4] = v[4] - 1
					end
				elseif m.Type == 'Note' then
					local notemod = v[4]..'|'..v[1]..'|'..v[2]
					v[5] = v[5] or note_percents[pn][notemod] or 0
					note_percents[pn][notemod] = m.Ease(1) * (v[3] - v[5]) + v[5]
					if v[6] and active[pn][notemod] then
						table.remove(active[pn][notemod], v[6])
						v[6] = v[6] - 1
					end
				end
			end
		end
    end
end

local function RegisterField(notefield, pn)
	POptions[pn] = notefield:GetPlayerOptions('ModsLevel_Current')
end

-- Load a mod file.
local function FromFile(self, scriptpath)
	--printerr('Mods:FromFile')
	run('lua/'..scriptpath)
	return self
end
-- Write default mods.
local function Default(self, modtable)
	--printerr('Mods:Default')
	for pn = 1, plrcount do
		for i = 1, #modtable do
			default_mods[pn][modtable[i][2]] = modtable[i][1]
			mod_percents[pn][modtable[i][2]] = modtable[i][1]
		end
	end
	--local res = self:Insert(std.START, 0, instant_tween, modtable)
	--return res
	return self
end
-- Define a new mod.
local function Define(self, name, func, ret)
	--printerr('Mods:Define')
	local t = {}
	if type(ret) ~= 'table' then ret = {ret} end
	t = {
		Function = func,
		Return = ret
	}
	for pn = 1, plrcount do
		custom_mods[pn][name] = t
	end
	return self
end
-- Insert a mod.
local function Insert(self, start, len, ease, modtable, offset, pn)
    --printerr('Mods:Insert')
	local t1, t = {}, {}
	for p = 2, plrcount do
		t[p] = {}
	end
    if not offset or offset == 0 then
		t1 = {
			Start = start,
			Length = len,
			Ease = ease,
			Modifiers = modtable,
			Type = 'Player',
			Player = pn or 1
		}
		table.insert(modlist, t1)
		if not pn then
			for p = 2, plrcount do
				t[p] = {
					Start = start,
					Length = len,
					Ease = ease,
					Modifiers = modtable,
					Type = 'Player',
					Player = p
				}
				table.insert(modlist, t[p])
			end
		end
    else
        for i, v in ipairs(modtable) do
            t1[i] = {
                Start = start + (offset * (i - 1)),
                Length = len,
                Ease = ease,
                Modifiers = {v},
				Type = 'Player',
                Player = pn or 1
            }
            table.insert(modlist, t1[i])
			if not pn then
				for p = 2, plrcount do
					t[p][i] = {
						Start = start + (offset * (i - 1)),
						Length = len,
						Ease = ease,
						Modifiers = {v},
						Type = 'Player',
						Player = p
					}
					table.insert(modlist, t[p][i])
				end
			end
        end
    end
    return self
end
-- We can't actually add notemods until they stop corrupting the stack.
local function Note(self, start, len, ease, notemodtable, offset, pn)
	--printerr(Mods:Note)
	local t1, t = {}, {}
	for p = 2, plrcount do
		t[p] = {}
	end
	if not offset or offset == 0 then
		t1 = {
			Start = start,
			Length = len,
			Ease = ease,
			Modifiers = notemodtable,
			Type = 'Note',
			Player = pn or 1
		}
		table.insert(modlist, t1)
		if not pn then
			for p = 2, plrcount do
				t[p] = {
					Start = start,
					Length = len,
					Ease = ease,
					Modifiers = notemodtable,
					Type = 'Note',
					Player = p
				}
				table.insert(modlist, t[p])
			end
		end
	else
		for i, v in ipairs(notemodtable) do
			t1[i] = {
				Start = start + (offset * (i - 1)),
				Length = len,
				Ease = ease,
				Modifiers = {v},
				Type = 'Note',
				Player = pn or 1
			}
			table.insert(modlist, t1[i])
			if not pn then
				for p = 2, plrcount do
					t[p][i] = {
						Start = start + (offset * (i - 1)),
						Length = len,
						Ease = ease,
						Modifiers = {v},
						Type = 'Note',
						Player = p
					}
					table.insert(modlist, t[p][i])
				end
			end
		end
	end
	return self
end
-- Insert a mod but you like extra wasabi
local function Exsch(self, start, len, str1, str2, mod, timing, ease, pn)
    --printerr('Mods:Exsch')
    if timing == 'end' then
        len = len - start
    end
    local res = self:Insert(start, len, ease, {{str2, mod, str1}}, 0, pn)
    return res
end
-- so-called "free thinkers" when mirin template
local function Mirin(self, t, offset, pn)
    --printerr('Mods:Mirin')
    local tmods = {}
    for i = 4, #t, 2 do
        if t[i] and t[i + 1] then
            tmods[#tmods + 1] = {t[i], t[i + 1]}
        end
    end
    local res = self:Insert(t[1], t[2], t[3], tmods, offset, pn)
    return res
end

local function GetPercents()
	return mod_percents
end

FG[#FG + 1] = Def.Actor {
	ReadyCommand = function(self)
		for pn = 1, plrcount do
			if POptions[pn] then POptions[pn]:FromString('*-1 clearall') end
			for mod, percent in pairs(default_mods[pn]) do
				mod_percents[pn][mod] = percent
			end
		end
		self:sleep(self:GetEffectDelta()):queuecommand('Sort')
	end,
	SortCommand = function(self)
		local function compare(a, b)
			return a.Start < b.Start
		end
		modlist.n = #modlist
		stable_sort(modlist, compare)
	end,
	UpdateCommand = function(self)
		active_mods = {}
		for i = 1, #modlist do
			local mod = modlist[i]
			if std.BEAT >= mod.Start then
				table.insert(active_mods, mod)
			end
		end
		UpdateMods()
		ApplyMods()
		ApplyNotes()
		for i = #modlist, 1, -1 do
			local mod = modlist[i]
			if std.BEAT > mod.Start + mod.Length then
				table.remove(modlist, i)
			end
		end
	end
}

Mods = {
	VERSION = VERSION,
	AUTHOR = AUTHOR,
	PlayerCount = PlayerCount,
	RegisterField = RegisterField,
	FromFile = FromFile,
	Define = Define,
	Insert = Insert,
	Note = Note,
	Mirin = Mirin,
	Exsch = Exsch,
	Default = Default,
	GetPercents = GetPercents,
}
Mods.__index = Mods


print('Loaded Konko Mods v'..Mods.VERSION)

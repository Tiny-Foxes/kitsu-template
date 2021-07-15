Mods = {}

-- Keep the player options from the enabled players that are available.
local POptions = {}
for i, v in ipairs( GAMESTATE:GetEnabledPlayers() ) do
    POptions[i] = GAMESTATE:GetPlayerState(v):GetPlayerOptions('ModsLevel_Song')
end

local branches = {}
local mod_percents = {}
local note_percents = {}
local custom_mods = {}
local default_mods = {}
local active = {}

for pn = 1, #POptions do
	mod_percents[pn] = {}
	note_percents[pn] = {}
	custom_mods[pn] = {}
	default_mods[pn] = {}
	active[pn] = {}
end

local function ApplyMods(mod, percent, pn)
	if custom_mods[pn][mod] ~= nil then
		local new_perc = custom_mods[pn][mod].Function(percent, pn)
		local new_mod = custom_mods[pn][mod].Return
		percent = new_perc
		mod = new_mod
	end
    if mod then
		local modstring = '*-1 '..percent..' '..mod:lower()
		if mod:sub(2):lower() == 'mod' then
			modstring = '*-1 '..percent..mod:sub(1, 1):lower()
		end
		if pn then
			POptions[pn]:FromString(modstring)
		else
			for p = 1, #POptions do
				POptions[p]:FromString(modstring)
			end
		end
	end
end
local function ApplyNotes(beat, col, mod, percent, pn)
	if pn then
		PL[pn].Player:AddNoteMod(beat, col, mod, percent * 0.01)
	else
		for p = 1, #POptions do
			PL[p].Player:AddNoteMod(beat, col, mod, percent * 0.01)
		end
	end
end

local function UpdateMods()
    for _, b in ipairs(branches) do
        for i, m in ipairs(b) do
            for j, v in ipairs(m.Modifiers) do
                -- If the player where we're trying to access is not available, then don't even update.
                if m.Player and not POptions[m.Player] then break end
				local pn = m.Player
                if BEAT >= m.Start and BEAT < (m.Start + m.Length) then
					if m.Type == 'Player' then
						v[3] = v[3] or mod_percents[pn][v[2]] or 0
						active[pn][v[2]] = active[pn][v[2]] or {}
						v[4] = v[4] or (#active[pn][v[2]] + 1)
						active[pn][v[2]][v[4]] = m
						local perc = 0
						for n = 1, v[4] do
							local offset = (n < v[4]) and 1 or 0
							local cur_m = active[pn][v[2]][n]
							local cur_v1 = cur_m.Modifiers[j][1]
							local cur_v3 = cur_m.Modifiers[j][3]
							local cur_ease = cur_m.Ease((BEAT - cur_m.Start) / cur_m.Length) - offset
							local cur_perc = cur_ease * (cur_v1 - cur_v3 * n)
							perc = perc + cur_perc
						end
						mod_percents[pn][v[2]] = perc
						ApplyMods(v[2], mod_percents[pn][v[2]], pn)
					elseif m.Type == 'Note' then
						local notemod = v[4]..'|'..v[1]..'|'..v[2]
						v[5] = v[5] or note_percents[pn][notemod] or 0
						--[[
						local ease = m.Ease((BEAT - m.Start) / m.Length)
						local perc = ease * (v[3] - v[5])
						note_percents[pn][notemod] = v[5] + perc
						--]]
						active[pn][notemod] = active[pn][notemod] or {}
						v[6] = v[6] or (#active[pn][notemod] + 1)
						active[pn][notemod][v[6]] = m
						local perc = 0
						for n = 1, v[6] do
							local offset = (n < v[6]) and 1 or 0
							local cur_m = active[pn][notemod][n]
							local cur_v3 = cur_m.Modifiers[j][3]
							local cur_v5 = cur_m.Modifiers[j][5]
							local cur_ease = cur_m.Ease((BEAT - cur_m.Start) / cur_m.Length) - offset
							local cur_perc = cur_ease * (cur_v3 - cur_v5)
							perc = perc + (cur_v5 + cur_perc)
						end
						note_percents[pn][notemod] = perc
						ApplyNotes(v[1], v[2], v[4], note_percents[pn][notemod], pn)
					end
                elseif BEAT >= (m.Start + m.Length) then
					if m.Type == 'Player' then
						mod_percents[pn][v[2]] = v[1]
						if v[4] and active[pn][v[2]] then
							active[pn][v[2]][v[4]] = nil
						end
					elseif m.Type == 'Note' then
						local notemod = v[4]..'|'..v[1]..'|'..v[2]
						note_percents[pn][notemod] = v[3]
						if v[6] and active[pn][notemod] then
							active[pn][notemod][v[6]] = nil
						end
					end
					--table.remove(m.Modifiers, j)
                end
            end
            if #b < 1 then table.remove(branches, i) end
        end
    end
end

local ModTree = Def.ActorFrame {
    Branches = {},
	ReadyCommand = function(self)
		sudo(assert(loadfile(SongDir .. 'lua/mods.lua')))()
	end,
    UpdateMessageCommand = function(self)
        UpdateMods()
    end
}

--[[
    This is a special type of modbuilder.
    The idea behind this is that you can
    separate in to branches, so that rather
    than making messy tables that are set
    in stone, you can add and remove to a
    mod branch that can be changed or even
    deleted under any desired circumstance.

	It can also update on a constant tick rate.
]]

-- TODO: Create a GetPercent function to get the current mod percent

-- Create a new mod branch.
local function new()
    --printerr('Mods.new')
    local t = {}
    setmetatable(t, Mods)
    return t
end
-- Load a mod file.
local function LoadFromFile(scriptpath)
	--printerr('Mods.LoadFromFile')
	sudo(assert(loadfile(SongDir..'lua/'..scriptpath..'.lua')))()
end
-- Write default mods.
local function Default(self, modtable)
	--printerr('Mods:Default')
	for pn = 1, #POptions do
		default_mods[pn] = modtable
	end
	local res = self:InsertMod(MOD_START, 0.25, Tweens.instant, modtable)
	return res
end
-- Define a new mod.
local function DefineMod(self, name, func, ret)
	--printerr('Mods:DefineMod')
	local t = {}
	t = {
		Function = func,
		Return = ret
	}
	for pn = 1, #POptions do
		custom_mods[pn][name] = t
	end
	return self
end
-- Write to a mod branch.
local function InsertMod(self, start, len, ease, modtable, offset, pn)
    --printerr('Mods:InsertMod')
    local t1, t2 = {}, {}
    if not offset or offset == 0 then
		t1 = {
			Start = start,
			Length = len,
			Ease = ease,
			Modifiers = modtable,
			Type = 'Player',
			Player = pn or 1
		}
		table.insert(self, t1)
		if not pn then
			t2 = {
				Start = start,
				Length = len,
				Ease = ease,
				Modifiers = modtable,
				Type = 'Player',
				Player = 2
			}
			table.insert(self, t2)
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
            table.insert(self, t1[i])
			if not pn then
				t2[i] = {
					Start = start + (offset * (i - 1)),
					Length = len,
					Ease = ease,
					Modifiers = {v},
					Type = 'Player',
					Player = 2
				}
				table.insert(self, t2[i])
			end
        end
    end
    return self
end
local function InsertNoteMod(self, start, len, ease, notetable, offset, pn)
	--printerr(Mods:InsertNoteMod)
	local t1, t2 = {}, {}
	if not offset or offset == 0 then
		t1 = {
			Start = start,
			Length = len,
			Ease = ease,
			Modifiers = notetable,
			Type = 'Note',
			Player = pn or 1
		}
		table.insert(self, t1)
		if not pn then
			t2 = {
				Start = start,
				Length = len,
				Ease = ease,
				Modifiers = notetable,
				Type = 'Note',
				Player = 2
			}
			table.insert(self, t2)
		end
	else
		for i, v in ipairs(notetable) do
			t1[i] = {
				Start = start + (offset * (i - 1)),
				Length = len,
				Ease = ease,
				Modifiers = {v},
				Type = 'Note',
				Player = pn or 1
			}
			table.insert(self, t1[i])
			if not pn then
				t2[i] = {
					Start = start + (offset * (i - 1)),
					Length = len,
					Ease = ease,
					Modifiers = {v},
					Type = 'Note',
					Player = 2
				}
				table.insert(self, t2[i])
			end
		end
	end
	return self
end
-- Write to a mod branch now Mirin approved!
local function MirinMod(self, t, offset, pn)
    --printerr('Mods:MirinMod')
    local tmods = {}
    for i = 4, #t, 2 do
        if t[i] and t[i + 1] then
            tmods[#tmods + 1] = {t[i], t[i + 1]}
        end
    end
    local res = self:InsertMod(t[1], t[2], t[3], tmods, offset, pn)
    return res
end
-- Write to a mod branch but you like extra wasabi~
local function ExschMod(self, start, len, str1, str2, mod, timing, ease, pn)
    --printerr('Mods:ExschMod')
    if timing == 'end' then
        len = len - start
    end
    local res = self:InsertMod(start, len, ease, {{str2, mod, str1}}, 0, pn)
    return res
end
-- Add branch to the mod tree.
local function AddToModTree(self)
    --printerr('Mods:AddToModTree')
    table.insert(branches, self)
end
-- Remove branch from the mod tree.
local function RemoveFromModTree(self)
    --printerr('Mods:RemoveFromModTree')
    for i, v in ipairs(branches) do
        if v == self then table.remove(branches, i) end
    end
end
-- Get the mod tree.
local function GetModTree()
    --printerr('Mods:GetModTree')
    return ModTree
end

return Def.ActorFrame {
	InitCommand = sudo(function(self)
		Mods = {
			new = new,
			LoadFromFile = LoadFromFile,
			DefineMod = DefineMod,
			InsertMod = InsertMod,
			InsertNoteMod = InsertNoteMod,
			MirinMod = MirinMod,
			ExschMod = ExschMod,
			Default = Default,
			AddToModTree = AddToModTree,
			RemoveFromModTree = RemoveFromModTree,
			GetModTree = GetModTree
		}
		Mods.__index = Mods
	end),
	ModTree
}

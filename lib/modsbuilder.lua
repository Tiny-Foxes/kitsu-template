local Mods

-- Keep the player options from the enabled players that are available.
local POptions = {}
for i, v in ipairs( GAMESTATE:GetEnabledPlayers() ) do
    POptions[i] = GAMESTATE:GetPlayerState(v):GetPlayerOptions('ModsLevel_Song')
end

local function ApplyMods(mod, percent, pn)
    local modstring = '*-1 '..percent..' '..mod:lower()
    if mod:sub(2):lower() == 'mod' then
        modstring = '*-1 '..percent..mod:sub(1, 1):lower()
    end
    if pn then
        POptions[pn]:FromString(modstring)
    else
        for p = 1, #PL do
            POptions[p]:FromString(modstring)
        end
    end
end

-- TODO: Make this less painful to deal with before you die at age 80.
local branches = {}
local mod_percents = {}
local function UpdateMods()
    for _, b in ipairs(branches) do
        for i, m in ipairs(b) do
            for j, v in ipairs(m.Modifiers) do
                -- If the player where we're trying to access is not available, then don't even update.
                if m.Player and not POptions[ m.Player ] then break end
                if BEAT >= m.Start and BEAT < (m.Start + m.Length) then
                    -- Get start percent
                    local pl = m.Player or 1
                    v[3] = v[3] or mod_percents[v[2]] or 0
                    local ease = m.Ease((BEAT - m.Start) / m.Length)
                    local perc = ease * (v[1] - v[3]) + v[3]
                    ApplyMods(v[2], perc, m.Player)
                    mod_percents[v[2]] = perc
                elseif BEAT >= (m.Start + m.Length) then
                    ApplyMods(v[2], v[1], m.Player)
                    mod_percents[v[2]] = v[1]
                    table.remove(m.Modifiers, j)
                end
            end
            if #b < 1 then table.remove(branches, i) end
        end
    end
end

local ModTree = Def.ActorFrame {
    Branches = {},
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
]]

Tweens.instant = function(x) return 1 end -- fite me

-- Create a new mod branch.
local function new()
    --printerr('Mods.new')
    local t = {}
    setmetatable(t, Mods)
    return t
end
-- Write to a mod branch.
local function InsertMod(self, start, len, ease, modpairs, offset, pn)
    --printerr('Mods:InsertMod')
    local t = {}
    if not offset or offset == 0 then
        t = {
            Start = start,
            Length = len,
            Ease = ease,
            Modifiers = modpairs,
            Player = pn or nil
        }
        table.insert(self, t)
    else
        for i, v in ipairs(modpairs) do
            t[i] = {
                Start = start + (offset * (i - 1)),
                Length = len,
                Ease = ease,
                Modifiers = {v},
                Player = pn or nil
            }
            table.insert(self, t[i])
        end
    end
    return t
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
-- Alias for writing default mods
local function Default(self, modpairs)
    --printerr('Mods:Default')
    self:InsertMod(0, 9e9, function(x) return 1 end, modpairs)
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

Mods = {
    new = new,
    InsertMod = InsertMod,
    MirinMod = MirinMod,
    ExschMod = ExschMod,
    Default = Default,
    AddToModTree = AddToModTree,
    RemoveFromModTree = RemoveFromModTree,
    GetModTree = GetModTree
}
Mods.__index = Mods
return Mods

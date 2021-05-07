sudo()

local Mods

-- Keep the player options from the enabled players that are available.
local POptions = {}
for k,v in ipairs( GAMESTATE:GetEnabledPlayers() ) do
    POptions[k] = GAMESTATE:GetPlayerState(v):GetPlayerOptions('ModsLevel_Song')
end

local function ApplyModifiers(mod, percent, pn)
    local amount = percent * 0.01
    if mod:sub(2) == 'Mod' then amount = percent end
    if pn then
        if POptions[pn] then
            POptions[pn][mod](POptions[pn], amount, 9e9)
        end
    else
        for p in ipairs(POptions) do
            POptions[p][mod](POptions[p], amount, 9e9)
        end
    end
end

-- TODO: Make this less painful to deal with before you die at age 80.
local branches = {}
--local masternum = tonumber(string.sub(GAMESTATE:GetMasterPlayerNumber(),-1))
local function UpdateMods()
    for _, b in ipairs(branches) do
        for i, m in ipairs(b) do
            -- If the player where we're trying to access is not available, then don't even update.
            if m.Player and not POptions[ m.Player ] then break; end
            --[[
            if type(m.Modifiers[1][1]) == 'number' then
                local t = m.Modifiers
                m.Modifiers = {}
                m.Modifiers[1] = t
            end
            ]]
            for j, v in ipairs(m.Modifiers) do
                if BEAT >= m.Start and BEAT < (m.Start + m.Length) then
                    -- Get start percent
                    local pl = m.Player or 1
                    --lua.ReportScriptError( type(pl) )
                    v[3] = v[3] or (POptions[pl][v[2]](POptions[pl]) or 1) * 100
                    if v[2]:sub(2) == 'Mod' then
                        v[3] = (v[3] * 0.01) + 1 -- what even
                    end
                    local ease = m.Ease((BEAT - m.Start) / m.Length)
                    local perc = ease * (v[1] - v[3]) + v[3]
                    ApplyModifiers(v[2], perc, m.Player)
                elseif BEAT >= (m.Start + m.Length) then
                    ApplyModifiers(v[2], v[1], m.Player)
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

-- Create a new mod branch.
local function new()
    --Trace('Mods:New')
    local t = {}
    setmetatable(t, Mods)
    return t
end
-- Write to a mod branch.
local function InsertMod(self, start, len, ease, modpairs, pn)
    --Trace('Mods:Write')
    local t = {
        Start = start,
        Length = len,
        Ease = ease,
        Modifiers = modpairs,
        Player = pn or nil
    }
    table.insert(self, t)
    return t
end
-- Writes a sequence of mods in an offset value.
local function StackMod( self, start, len, ease, offset, modpairs, pn )
    --Trace('Mods:StackMod')

    -- In this case, the mod pairs set will be delayed by an ammount given from it.
    for k,v in pairs(modpairs) do
        local t = {
            Start = start+(offset*k),
            Length = len,
            Ease = ease,
            Modifiers = {v},
            Player = pn or nil
        }
        table.insert( self, t )
    end

    return t
end
-- Alias for writing default mods
local function Default(self, modpairs, pn)
    self:InsertMod(0, 9e9, function(x) return 1 end, modpairs, pn)
end
-- Add branch to the mod tree.
local function AddToModTree(self)
    --Trace('Mods:AddToModTree')
    table.insert(branches, self)
end
-- Remove branch from the mod tree.
local function RemoveFromModTree(self)
    --Trace('Mods:RemoveFromModTree')
    for i, v in ipairs(branches) do
        if v == self then table.remove(branches, i) end
    end
end
-- Get the mod tree.
local function GetModTree()
    --Trace('Mods:GetModTree')
    return ModTree
end

Mods = {
    new = new,
    InsertMod = InsertMod,
    StackMod = StackMod,
    Default = Default,
    AddToModTree = AddToModTree,
    RemoveFromModTree = RemoveFromModTree,
    GetModTree = GetModTree
}
Mods.__index = Mods
return Mods

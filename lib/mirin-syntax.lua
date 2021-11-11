-- mirin-syntax.lua --

--[[
	Available commands:
	- set {start, percent, mod, ...}
	- ease {start, length, ease, percent, mod, ...}
	- definemod {name, funtion, return}
	- setdefault {percent, mod, ...}
	
	Mirin documentation available at https://xerool.github.io/notitg-mirin
--]]

local Mods = import 'konko-mods'

local mirin = {}

local function set(t)
	table.insert(t, 2, 0)
	table.insert(t, 3, Tweens.instant)
	local pn = (type(t.plr) ~= 'table' and t.plr) or nil
	t.plr = nil
	Mods:Mirin(t, 0, pn)
	return set
end

local function ease(t)
	local pn = (type(t.plr) ~= 'table' and t.plr) or nil
	t.plr = nil
	Mods:Mirin(t, 0, pn)
	return ease
end

-- WIP: Not a one-to-one implementation, define mods one at a time
local function definemod(t)
	local ret = {}
	for i = 3, #t do
		ret[#ret + 1] = t[i]
	end
	Mods:Define(t[1], t[2], ret)
	return definemod
end

local function setdefault(t)
	local t2 = {}
	for i = 1, #t, 2 do
		table.insert(t2, {t[i], t[i + 1]})
	end
	Mods:Default(t2)
	return setdefault
end

mirin = {
	VERSION = '1.1',
	ease = ease,
	set = set,
	definemod = definemod,
	setdefault = setdefault
}
mirin.__index = mirin

print('Loaded Mirin Syntax v'..mirin.VERSION)

return mirin

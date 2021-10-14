local Mods = import 'konko-mods'

local mirin = {}

local function ease(t)
	local pn = (type(t.plr) ~= 'table' and t.plr) or nil
	t.plr = nil
	Mods:Mirin(t, 0, pn)
	return ease
end

local function set(t)
	table.insert(t, 2, 0)
	table.insert(t, 3, Tweens.instant)
	local pn = (type(t.plr) ~= 'table' and t.plr) or nil
	t.plr = nil
	Mods:Mirin(t, 0, pn)
	return set
end

-- Not a one-to-one fix, define mods one at a time
local function definemod(t)
	Mods:Define(table.unpack(t))
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
	ease = ease,
	set = set,
	definemod = definemod,
	setdefault = setdefault
}
mirin.__index = mirin

print('Loaded Mirin Syntax for Konko Mods')

return mirin

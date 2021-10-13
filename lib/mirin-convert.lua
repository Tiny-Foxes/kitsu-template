local function ease(t)
	Mods:Mirin(t)
	return ease
end

local function set(t)
	table.insert(t, 2, 0)
	table.insert(t, 3, Tweens.instant)
	Mods:Mirin(t)
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

local ret = {
	ease,
	set,
	definemod,
	setdefault,
}

return table.unpack(ret)

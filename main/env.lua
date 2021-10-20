-- env.lua --

-- This is where we build our environment. This environment is vital to the template's
-- Function, and if removed, will render it inoperable.

-- Big thanks to XeroOl for this code, it came from his Mirin template.


-- First, let's define a global variable for our environment. We feel powerful, in our own
-- castle of logical wizardry. Elevated and even privileged. Let's call it 'sudo'.
-- For no particular reason at all.
_G.sudo = {}

-- Let's do a really weird thing that's scary to think about. Don't do this in real life.
local sudo = setmetatable(sudo, sudo)

-- We want our environment to have all of the stuff that _G has, which is everything, including
-- our environment, which will contain _G, the very one that contains our environment. This is
-- the recursion you should never think about and just accept as a natural law.
sudo.__index = _G

-- We want to be lazy and have sudo() as a shorthand for setting our environment, but we also
-- want to be thorough and have a shorthand for setting an environment for a specific function.
-- This is the function for exactly that. It will do everything for us. You ready?
-- nop
local function nop() end

-- nah just kidding here it is
function sudo:__call(f, name)
	if type(f) == 'string' then
		-- If we call sudo with a string, we need to load it as code.
		local err
		-- Try compiling the code.
		f, err = loadstring( 'return function(self)' .. f .. '\nend', name)
		-- If we error, tell us what we got and return nop.
		if err then SCREENMAN:SystemMessage(err) return nop end
		-- If we compile, grab the function.
		f, err = pcall(f)
		-- Again, give an error and return nop if we error.
		if err then SCREENMAN:SystemMessage(err) return nop end
	end
	-- Set our environment and return our function.
	setfenv(f or 2, self)
	return f
end

-- It's dangerous to go alone; take this!
local dir = GAMESTATE:GetCurrentSong():GetSongDir()

-- Debug and Error prints
function sudo.print(s) lua.Trace('KITSU: '..(s or 'nil')) end
function sudo.printerr(s) lua.ReportScriptError('KITSU: '..(s or 'nil')) end

-- Library importer
function sudo.import(lib)
	-- Catch in case we add .lua to our path.
	if lib:find('%.lua') then lib = lib:sub(1, lib:find('%.lua') - 1) end
	-- Make sure the file is there
	local file = dir..'lib/'..lib..'.lua'
	if not assert(loadfile(file)) then
		sudo.printerr('Unable to import library "'..lib..'": No file found.')
		return
	end
	-- Return our file in our environment
	return sudo(loadfile(file))()
end

-- Lua runner
function sudo.run(path)
	-- Catch in case we add .lua to our path.
	if path:find('%.lua') then path = path:sub(1, path:find('%.lua') - 1) end
	-- Make sure the file is there
	local file = dir..path..'.lua'
	if not assert(loadfile(file)) then
		sudo.printerr('Unable to run file "'..path..'": No file found.')
		return
	end
	-- Return our file in our environment
	return sudo(loadfile(file))()
end

sudo.FG = Def.ActorFrame {
    InitCommand = function(self)
		sudo.FG = self
        self:sleep(9e9)
    end,
	StartCommand = function(self)
		self:luaeffect('Update')
	end
}

local sqrt = math.sqrt
local sin = math.sin
local asin = math.asin
local cos = math.cos
local pow = math.pow
local exp = math.exp
local pi = math.pi
local abs = math.abs

flip = setmetatable({}, {
	__call = function(self, fn)
		--self[fn] = self[fn] or function(x) return 1 - fn(x) end
		return self[fn] or function(x) return 1 - fn(x) end
	end
})

function with1param(fn, defaultparam1)
	local function params(param1)
		return function(x)
			return fn(x, param1)
		end
	end
	local default = params(defaultparam1)
	return setmetatable({
		params = params,
		param = params,
	}, {
		__call = function(self, x)
			return default(x)
		end
	})
end

function with2params(fn, defaultparam1, defaultparam2)
	local function params(param1, param2)
		return function(x)
			return fn(x, param1, param2)
		end
	end
	local default = params(defaultparam1, defaultparam2)
	return setmetatable({
		params = params,
		param = params,
	}, {
		__call = function(self, x)
			return default(x)
		end
	})
end

function bounce(t) return 4 * t * (1 - t) end
function tri(t) return 1 - abs(2 * t - 1) end
function bell(t) return inOutQuint(tri(t)) end
function pop(t) return 3.5 * (1 - t) * (1 - t) * sqrt(t) end
function tap(t) return 3.5 * t * t * sqrt(1 - t) end
function pulse(t) return t < .5 and tap(t * 2) or -pop(t * 2 - 1) end

function spike(t) return exp(-10 * abs(2 * t - 1)) end
function inverse(t) return t * t * (1 - t) * (1 - t) / (0.5 - t) end

local function popElasticInternal(t, damp, count)
	return (1000 ^ -(t ^ damp) - 0.001) * sin(count * pi * t)
end

local function tapElasticInternal(t, damp, count)
	return (1000 ^ -((1 - t) ^ damp) - 0.001) * sin(count * pi * (1 - t))
end

local function pulseElasticInternal(t, damp, count)
	if t < .5 then
		return tapElasticInternal(t * 2, damp, count)
	else
		return -popElasticInternal(t * 2 - 1, damp, count)
	end
end

popElastic = with2params(popElasticInternal, 1.4, 6)
tapElastic = with2params(tapElasticInternal, 1.4, 6)
pulseElastic = with2params(pulseElasticInternal, 1.4, 6)

impulse = with1param(function(t, damp)
	t = t ^ damp
	return t * (1000 ^ -t - 0.001) * 18.6
end, 0.9)

local t = Tweens

function instant(x) return t.instant(x) or 1 end
function linear(x) return t.linear(x) end
function inSine(x) return t.insine(x) end
function outSine(x) return t.outsine(x) end
function inOutSine(x) return t.inoutsine(x) end
function inQuad(x) return t.inquad(x) end
function outQuad(x) return t.outquad(x) end
function inOutQuad(x) return t.inoutquad(x) end
function inCubic(x) return t.incubic(x) end
function outCubic(x) return t.outcubic(x) end
function inOutCubic(x) return t.inoutcubic(x) end
function inQuart(x) return t.inquart(x) end
function outQuart(x) return t.outquart(x) end
function inOutQuart(x) return t.inoutquart(x) end
function inQuint(x) return t.inquint(x) end
function outQuint(x) return t.outquint(x) end
function inOutQuint(x) return t.inoutquint(x) end
function inExpo(x) return t.inexpo(x) end
function outExpo(x) return t.outexpo(x) end
function inOutExpo(x) return t.inoutexpo(x) end
function inCirc(x) return t.incircle(x) end
function outCirc(x) return t.inoutcircle(x) end
function inOutCirc(x) t.inoutcircle(x) end
function inBounce(x) return t.inbounce(x) end
function outBounce(x) return t.outbounce(x) end
function inOutBounce(x) return t.inoutbounce(x) end
function inElastic(x) return t.inelastic(x) end
function outElastic(x) return t.outelastic(x) end
function inOutElastic(x) return t.inoutelastic(x) end
function inBack(x) return t.inback(x) end
function outBack(x) return t.outback(x) end
function inOutBack(x) return t.inoutback(x) end

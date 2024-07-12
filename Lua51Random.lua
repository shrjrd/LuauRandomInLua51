local seed = 1
local randomseed = function(s)
	seed = math.floor(s)
end
local random = function(x, y)
	seed = (seed*214013 + 2531011)%4294967296
	local r = (((math.floor(seed/65536)%32768)%32767)/32767) -- rand()
	if x and y then
		return math.floor(r*(y - x + 1)) + x
	elseif x and not y then
		return math.floor(r*x) + 1
	end
	return r
end

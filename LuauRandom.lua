local BigInt = require(script.BigInteger) -- https://github.com/soupstream/lua-5.1-bigint
local PCG32_INCREMENT	= BigInt(105)
local PCG32_MULTIPLIER	= BigInt("6364136223846793005")
local _uint64 = BigInt("18446744073709551615")
local function uint64(n) return n:Band(_uint64) end
local function uint32(n) return n:Band(4294967295) end
local _Random = {}
_Random.new = function(seed, state)
	local PCG32_STATE
	local function pcg32_random()
		local old = PCG32_STATE
		PCG32_STATE = uint64(PCG32_STATE * PCG32_MULTIPLIER + (PCG32_INCREMENT:Bor(BigInt.One)))
		local shift = uint32(((old:Shr(18)):Bxor(old)):Shr(27))
		local rot = uint32(old:Shr(59))
		return uint32(shift:Shr(rot):Bor(shift:Shl((rot:Bnot()+1):Band(31))))
	end
	local function pcg32_seed(s)
		PCG32_STATE = BigInt.Zero
		pcg32_random()
		PCG32_STATE = uint64(PCG32_STATE + BigInt(tostring(s)))
		pcg32_random()
	end
	if seed then
		pcg32_seed(math.floor(seed))
	elseif not seed and not state then
		pcg32_seed(math.floor(tick()))
	elseif not seed and state then
		PCG32_STATE = state
	end
	return {
		NextInteger = function(self, min, max)
			if not min or not max then return end
			if min == max then return min end
			if max < min then min, max = max, min end
			local l, u = BigInt(min), BigInt(max)
			return (l + ((uint64((uint32(uint32(u) - uint32(l))) + 1)*pcg32_random()):Shr(32))):ToNumber()
		end,
		NextNumber = function(self, min, max)
			if not min and not max then 
				local m = pcg32_random():Bor(uint64(pcg32_random()):Shl(32))
				local n = BigInt(-64)
				local v = m:Mul(BigInt(2):Pow(n)) -- m*2^n -- math.ldexp(m,n)
				return v:ToNumber()
			elseif min and max then
				if min == max then return min end
				if max < min then min, max = max, min end
				local m = pcg32_random():Bor(uint64(pcg32_random()):Shl(32))
				local n = BigInt(-64)
				local v = m:Mul(BigInt(2):Pow(n)) -- m*2^n -- math.ldexp(m,n)
				min, max = BigInt(min), BigInt(max)
				return (v:Mul(max:Sub(min))):Add(min):ToNumber()
			end
		end,
		Shuffle = function(self, t)
			for i = #t, 2, -1 do
				local j = self:NextInteger(1, i)
				t[j], t[i] = t[i], t[j]
			end
		end,
		NextUnitVector = function()
			local a = 2 * math.pi * (pcg32_random():ToNumber() / 4294967296)
			local x = 2 * (pcg32_random():ToNumber() / 4294967296) - 1
			local r = math.sqrt(1 - x * x)
			return Vector3.new(r * math.cos(a), r * math.sin(a), x)
		end,
		Clone = function()
			return _Random.new(nil, PCG32_STATE)
		end}
end
return _Random

-- extended PEG module
require "lpeg"

local function makerange(first, second)
	local patts = {}
	local patt  = {}
	if (second) then
		if (string.len(first) == string.len(second)) then
			for i = 1, string.len(first) do
				patts[i] = lpeg.R(string.sub(first,i,i)..string.sub(second,i,i))
			end
			patt = patts[1]
			for i = 2, string.len(first) do
				patt = patt + patts[i]
			end
			return patt
		else
			error("Ranges must be of equal byte width")
			return {}
		end
	else 
		return lpeg.R(first)
	end
end


local function num_bytes(str)
--returns the number of bytes in the next character in str
	local c = str:byte(1)
	if c >= 0x00 and c <= 0x7F then
		return 1
	elseif c >= 0xC2 and c <= 0xDF then
		return 2
	elseif c >= 0xE0 and c <= 0xEF then
		return 3
	elseif c >= 0xF0 and c <= 0xF4 then
		return 4
	end
end

local function Su (str)
--[[
	--convert a 'set' pattern to uniquely match the characters 
	--in the range.
	local catch = {}
	local i = 0
	for i = 1, #str do
		catch[i]
	end
	--]]
end


local function spanner(first, last)
	local vals = {}
	vals.span = true
	vals[1] = first
	vals[2] = last-1
	return vals
end

local function Csp (patt)
	return lpeg.Cp() * patt * lpeg.Cp() / spanner
end

local Ru = makerange


return { R = Ru,
		Csp = Csp, }
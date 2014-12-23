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
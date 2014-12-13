-- UTF-8 aware range generator

-- The problem: Ranges as defined in Lpeg are between single bytes. This falls down badly in Unicode.
--
-- The solution: provide two strings. Construct a bytewise comparator that matches the range of the 
-- first bytes, followed by the range of the second, and so on. 
--
-- For ordinary Latin, this gives expected behavior. ("ab","cz") would match any two bytes, provided the
-- first is in a-c and the latter is in b-z. For UTF-8, this should in fact decompose into exactly 
-- what we want. Back-adaptation to old regexes was keenly on the mind of the designers. 
-- 
-- Currently, we barf on a range like `("ab","c")`. This precludes matching against Unicode characters of 
-- different widths, and is far faster than solving the general case.
-- 
-- This should come up quite seldom, as the various code classes don't cross width boundaries
-- for just this reason. in the event you need a range spanning N'Ko and Indic, or Forms and 
-- Ancient Symbols, you're on your own.

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

Ru = makerange

--[[ tests
greek = Ru("Α","Ω")
latin = Ru("a", "z")
print ("Greek ",lpeg.match(greek,"Β"))
print ("Latin ",lpeg.match(latin,"b"))
--]]
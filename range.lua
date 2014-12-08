-- UTF-8 aware range generator

-- The problem: Ranges as defined in Lpeg are between single bytes. This falls down badly in Unicode.
--
-- The solution: provide two strings. Construct a bytewise comparator that matches the range of the 
-- first bytes, followed by the range of the second, and so on. 
--
-- For ordinary Latin, this gives expected behavior. ["ab"-"cz"] would match any two bytes, provided the
-- first is in a-c and the latter is in b-z. For UTF-8, this should in fact decompose into exactly 
-- what we want. Back-adaptation to old regexes was keenly on the mind of the designers. 
-- 
-- Currently, we barf on a range like `["ab"-"c"]`. This precludes matching against Unicode characters of 
-- different widths. PEGs are very flexible, and there should be a way to resolve this, at least in some
-- useful cases. This should come up quite seldom, as the various code classes don't cross width boundaries
-- for just this reason.


require "lpeg"

--local
match = lpeg.match -- match a pattern against a string
P = lpeg.P -- match a string literally
S = lpeg.S  -- match anything in a set
R = lpeg.R  -- match anything in a range
C = lpeg.C  -- captures a match
Ct = lpeg.Ct -- a table with all captures from the pattern
Cg = lpeg.Cg -- a group capture
V = lpeg.V -- create a variable within a grammar

--local
-- note: syntax should be `ab-cz`, not ["ab"-"cz"]. 
-- \" and \\ need to be handled in the usual way. 
inquotes = P"\"" * C((R"\35\255" + R"\0\33")^0) * P"\""


--local 
range_g = P"[" * inquotes * P"-" * inquotes * P"]"

--local

local function makerange(first, second)
	local patts = {}
	local patt  = {}
	if (string.len(first) == string.len(second)) then
		for i = 1, string.len(first) do
			patts[i] = R(string.sub(first,i,i)..string.sub(second,i,i))
			print ("From: "..string.sub(first,i,i).." To: "..string.sub(second,i,i))
		end
		patt = patts[1]
		for i = 2, string.len(first) do
		--	print "multi-byte"
			patt = patt + patts[i]
		end
		return patt
	else
		error("Ranges must be of equal byte width")
		return {}
	end
end

--tests
teststr = "\"χἏ☒➤\"" --any old weird stuff, in quotes
ascii = "\"readable\""
range_s = "[\"ab\"-\"cz\"]"

greek_s = "[\"Α\"-\"Ω\"]"
beta = "Β"
greek = makerange(match(range_g,greek_s))
print ("Greek ",match(greek,beta))
print(range_s) 
print(match(inquotes,teststr))
print(match(inquotes,ascii))
print(match(range_g,range_s))
makerange(match(range_g,range_s))
in_range = "aq"
print(match(makerange(match(range_g,range_s)),in_range))

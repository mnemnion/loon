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
inquotes = P"\"" * C((R"\35\255" + R"\0\33")^0) * P"\""

--local 
range_g = P"[" * inquotes * P"-" * inquotes * P"]"

function makerange(first, second)
	local from = {}
	local to   = {}
	if (string.len(first) == string.len(second)) then
		for i = 1, string.len(first) do
			from[i] = string.byte(first, i)
			to[i] = string.byte(second, i) 
		end
		-- make into digit strings
		for i = 1, string.len(first) do
			print("From: ", from[i], " To: ", to[i])
		end
	else
		error("Ranges must be of equal byte width")
		return {}
	end
end
--tests
teststr = "\"χἏ☒➤\"" --any old weird stuff, in quotes
ascii = "\"readable\""
range_s = "[\"ab\"-\"cz\"]"
print(range_s) 
print(match(inquotes,teststr))
print(match(inquotes,ascii))
print(match(range_g,range_s))
makerange(match(range_g,range_s))
-- PEGylator

-- A parser generator for LPEG.

require "lpeg"
--epnf = require "lua-luaepnf/src/epnf"
dofile "../tools/util.lua"
dofile "range.lua"
local epnf = dofile "../tools/epnf.lua"
--dofile "./backwalk.lua"

match = lpeg.match -- match a pattern against a string
P = lpeg.P -- match a string literally
S = lpeg.S  -- match anything in a set
R = Ru  -- match anything in a range
C = lpeg.C  -- captures a match
Ct = lpeg.Ct -- a table with all captures from the pattern
V = lpeg.V -- create a variable within a grammar

	valid_sym = R"AZ" + R"az" + P"-" 
	digit = R"09"
	sym = valid_sym + digit
	symbol = valid_sym^-1 * sym^0

peg = epnf.define(function(_ENV)
	START "rules"
	local WS = P' '^0 + P'\n'^0 + P',' + P'\09'
	--local Ru = Ru 
	--valid_sym = C(R"AZ"^1) + C(R"az"^1) + C(P"-"^1) 
	--digit = C(R"09"^1)
	--sym = V"valid_sym" + digit
	--symbol = V"valid_sym"^-1 * sym^0
	lhs   = symbol
	rhs   = symbol --expand
	rule  = V"lhs" * P':' * V"rhs"
	rules = V"rule"
end)

grammar_s = [[ A : B / C
			  C : "D" 
			  D : E F G
]]

print (match(peg,grammar_s))

symbol_s = "rgsr09gaoijfsdfkrtjhaADSFASDFAr--"

--print (match(symbol, symbol_s))
assert(#symbol_s +1 == (match(symbol, symbol_s)))
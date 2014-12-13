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



valid_sym = P((Ru"AZ") + (Ru"az") + "-" )

digit = R"09"

sym = valid_sym + digit

symbol = valid_sym^-1 * sym^0

symbol_s = "rgsr09gaoijfsdfkrtjhaADSFASDFAr--"

print (match(symbol, symbol_s))
assert(#symbol_s +1 == (match(symbol, symbol_s)))
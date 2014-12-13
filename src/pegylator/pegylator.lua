-- PEGylator

-- A parser generator for LPEG.

require "lpeg"
--epnf = require "lua-luaepnf/src/epnf"
dofile "../tools/util.lua"
local epnf = dofile "../tools/epnf.lua"
--dofile "./backwalk.lua"

match = lpeg.match -- match a pattern against a string
P = lpeg.P -- match a string literally
S = lpeg.S  -- match anything in a set
R = lpeg.R  -- match anything in a range
C = lpeg.C  -- captures a match
Ct = lpeg.Ct -- a table with all captures from the pattern
V = lpeg.V -- create a variable within a grammar

print "hi"
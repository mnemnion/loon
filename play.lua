dofile "./tools/util.lua"
require "lpeg"
epnf = require "lua-luaepnf/src/epnf"


function rl()
	dofile "play.lua"
end


match = lpeg.match -- match a pattern against a string
P = lpeg.P -- match a string literally
S = lpeg.S  -- match anything in a set
R = lpeg.R  -- match anything in a range
C = lpeg.C  -- captures a match
Ct = lpeg.Ct -- a table with all captures from the pattern
V = lpeg.V -- create a variable within a grammar


clua = epnf.define ( function (_ENV)
	START "form"
	suppress ("element")
    local WS_     = P' '^0 + P'\n'^0 + P',' + P'\07'
    symbol = C(R'az'^1)-- incorrect start
    number = C(R'09'^1) -- likewise 
	atom   = WS_ * V"symbol" * WS_ + WS_ * V"number" * WS_
	list    =   P'(' * V"element"^0 * P')' * WS_ 
	element = V"atom" + V"form" 
	form    = V"list"
end)


 ast = epnf.parsestring(clua, "(foo bar)")
epnf.dumpast(ast)

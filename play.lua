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
	SUPPRESS ("element", "form", "atom", "pair")
    local WS = P' '^0 + P'\n'^0 + P',' + P'\07'
    symbol = C(R'az'^1)-- incorrect start
    number = C(R'09'^1) -- likewise 
	atom   = WS * V"symbol" * WS + WS * V"number" * WS
	list    =   WS * P'(' * V"element"^0 * P')'
	vector  =   WS * P'[' * V"element"^0 * P']' 
	pair    = V"element" * WS * V"element" * WS
	hash    = WS * P'{' * V"pair" * P'}'
	element = V"atom" + V"form" * WS 
	form    = V"list" + V"vector" + V"hash"
end)


function read (str)
	ast = epnf.parsestring(clua,str)
	epnf.dumpast(ast)
	return ast
end

 ast = epnf.parsestring(clua, "(foo bar [baz bux 23] )")
epnf.dumpast(ast)
read("{qux flux}")

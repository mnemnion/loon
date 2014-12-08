epnf = require "lua-luaepnf/src/epnf"

lisp = epnf.define ( function (_ENV)
	START "form"
	--SUPPRESS ("element", "form", "atom")
    local WS = P' '^0 + P'\n'^0 + P',' + P'\07'
    symbol = C(R'az'^1)
    number = C(R'09'^1) / tonumber 
	atom   = WS * V"symbol" * WS + WS * V"number" * WS
	list    =   WS * P'(' * V"element"^0 * P')'
	element = V"atom" + V"form" * WS 
	form    = V"list" 
end)

list = epnf.parsestring(lisp,"(foo bar)")
epnf.dumpast(list)
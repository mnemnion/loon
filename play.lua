
require "lpeg"
epnf = require "lua-luaepnf/src/epnf"
dofile "./tools/util.lua"
dofile "./backwalk.lua"

match = lpeg.match -- match a pattern against a string
P = lpeg.P -- match a string literally
S = lpeg.S  -- match anything in a set
R = lpeg.R  -- match anything in a range
C = lpeg.C  -- captures a match
Ct = lpeg.Ct -- a table with all captures from the pattern
V = lpeg.V -- create a variable within a grammar

-- greek = R"Α"

clua = epnf.define ( function (_ENV)
	START "form"
	SUPPRESS ("element", "form", "atom", "pair")
    local WS = P' '^0 + P'\n'^0 + P',' + P'\09'
    symbol = C(R'az'^1)-- incorrect start
    number = C(R'09'^1) / tonumber -- likewise 
	atom   = WS * V"symbol" * WS + WS * V"number" * WS
	list    =   WS * P'(' * V"element"^0 * P')'
	vector  =   WS * P'[' * V"element"^0 * P']' 
	pair    = V"element" * WS * V"element" * WS
	hash    = WS * P'{' * V"pair"^0 * P'}'
	set     = P'#' * P'{' * V"element"^0 * P'}'
	element = V"atom" + V"form" * WS 
	form    = V"list" + V"vector" + V"hash" + V"set"
end)


function read (str)
	local ast = epnf.parsestring(clua,str)
	local index = {}
	walkast(ast)
	dump_ast(ast, "", false)
	return ast, index
end

ast_ts, index = read "(foo bar [baz bux (qux flux (pavilion)) 23] )"
dump_ast(index, "", false)
read("{qux flux}")
read("#{quux fluux}")

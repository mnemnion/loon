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
	WS = P' ' + P'\n' + P',' + P'\09'
	symbol = (valid_sym^1 * sym^0)

peg = epnf.define(function(_ENV)
	START "rules"
	SUPPRESS ("WS", "cat_space", "cat", 
		      "element" ,"more_elements", "pattern",
		      "simple", "compound", "prefixed", "suffixed" )
	local cat_space = WS^1
	local WS = WS^0
	local symbol =  C(symbol)
	rules   = V"rule"^1
	rule    = V"lhs"  * V"rhs"
	lhs     = WS * symbol * WS * P":"
	rhs     = V"element" * V"more_elements"^0 
	more_elements  = (V"choice"  
			       + V"cat")
	choice = WS * P"/" * V"element" * V"more_elements"^0
	cat = cat_space * V"element" * V"more_elements"^0
	element  =  V"pattern" + V"factor"
	factor   =  ( WS * P"(" * WS * V"rhs" * WS * P")") 
	pattern  =  -V"lhs" * WS 
	         *  ( V"compound"
			 +    V"simple")
	compound =  V"factor"
	simple   =  V"literal"
			 +  V"prefixed"
			 +  V"suffixed"
			 +  V"atom" 
	literal  =  P'"' * symbol * P'"' -- make into real string
	suffixed =  V"optional"
			 +  V"more_than_one"
			 +  V"maybe"
	optional      =  symbol * P"*"
	more_than_one =  symbol * P"+"
	maybe         =  symbol * P"?"
	prefixed =  V"if_not_this"
			 +  V"not_this"
			 +  V"if_and_this"
	if_not_this = P"!" * symbol
	not_this    = P"-" * symbol
	if_and_this = P"&" * symbol
		   atom =  symbol
end)

grammar_s = [[ A : B C ( E / F ) / F G H
			  I : "J" 
			  K : L* M+ N?
			  O : !P &Q -R
]]

rule_s  = [[A:B C(D E)/(F G H)
			  C : "D" 
			  D : E F G
]]

peg_s = [[
	rules : rule +
	rule : lhs rhs
	lhs : _symbol_ ":"
	rhs : element more_elements*
	<more_elements> : choice / cat
	cat : <cat_space> element more_elements*
	<element> : pattern / factor
	factor : _"("_ rhs _")"
	<pattern> : _ !lhs (     
           ; /  lazy 
           /  at-least 
           /  single 
           /  exactly 
           /  no-more-than 
           /  between 
           /  not-this
           /  not-this-period
           /  if-also-this
           /  range
           /  set
           /  literal )  


]]
dump_ast (match(peg,grammar_s))
--dump_ast (match(peg,rule_s))
--dump_ast (match(peg,"A     :B C D E "))
symbol_s = "rgsr09gaoijfsdfkrtjhaADSFASDFAr--"

--print (match(symbol, symbol_s))
assert(#symbol_s +1 == (match(symbol, symbol_s)))
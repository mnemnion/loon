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
	white = P"_"
	symbol = (valid_sym^1 * sym^0) + white
	string_match = -P"\"" * -P"\\" * P(1)
	string = (string_match + P"\\\"" + P"\\")^1
	range_match =  -P"-" * -P"\\" * -P"]" * P(1)
	range_capture = (range_match + P"\\-" + P"\\]" + P"\\")
	range_c  = range_capture^1 * P"-" * range_capture^1
	set_match = -P"}" * -P"\\" * P(1)
	set_c    = (set_match + P"\\}" + P"\\")^1
peg = epnf.define(function(_ENV)
	START "rules"
	SUPPRESS ("WS", "cat_space", "cat", "match",
		      "element" ,"more_elements", "pattern",
		      "simple", "compound", "prefixed", "suffixed" )
	local cat_space = WS^1
	local WS = WS^0
	local symbol =  C(symbol)
	local string =  C(string)
	local range_c = C(range_c)
	local set_c  =  C(set_c)
	rules   =  V"rule"^1
	rule    =  V"lhs"  * V"rhs"
	lhs     =  WS * V"pattern" * WS * P":"
    rhs     =  V"element" * V"more_elements"
	pattern =  symbol 
			+  V"hidden_pattern"
	hidden_pattern =  P"<" * symbol * P">"
	element  =  V"match" + V"factor"
	more_elements  =  V"choice"  
			       +  V"cat"
			       +  P""
	choice =  WS * P"/" * V"element" * V"more_elements"
	cat =  cat_space * V"element" * V"more_elements"
	match    =  -V"lhs" * WS 
	         *  ( V"compound"
			 +    V"simple") 
	compound =  V"factor"
			 +  V"hidden_match" 
	factor   =  WS * P"(" 
			 *  WS * V"rhs" * WS 
			 *  P")" 
	hidden_match =  WS * P"<"
				 *  WS * V"rhs" * WS
				 *  P">"
	simple   =  V"prefixed"
			 +  V"suffixed"
			 +  V"enclosed"
			 +  V"atom" 
	prefixed =  V"if_not_this"
			 +  V"not_this"
			 +  V"if_and_this"
	if_not_this = P"!" * symbol
	not_this    = P"-" * symbol
	if_and_this = P"&" * symbol
	suffixed =  V"optional"
			 +  V"more_than_one"
			 +  V"maybe"
	enclosed =  V"literal"
		     +  V"set"
		     +  V"range"
    literal =  P'"' * (string + P"") * P'"'   -- make into real string
    set     =  P"{" * set_c^1 * P"}"    -- should match all char and escaped "}"
    range   =  P"[" * range_c * P"]"   -- make into real range
	optional      =  symbol * P"*"
	more_than_one =  symbol * P"+"
	maybe         =  symbol * P"?"
    atom =  symbol
end)

range_s = [[ \]\--CD ]]

set_s   = [[ abc\def\}g䷀䷁ ]]
string_s = [[ asldfr\"adf  asdf\asdf]]


grammar_s = [[ A : B C ( E / F ) / F G H
			  I : "J" 
			  K : L* M+ N?
			  O : !P &Q -R
			  <S> : <T (U V)>
			  W : {XY} [a-z] ]]

rule_s  = [[A:B C(D E)/(F G H)
			  C : "D" 
			  D : E F G
]]

peg_s = [[
	rules : rule +
	rule : lhs rhs
	lhs : _symbol_ ":"
	rhs : element more_elements*
	<more_elements> : choice / cat / ""
	cat : <cat_space> element more_elements*
	<element> : pattern / factor
	factor : _"("_ rhs _")"
	<pattern> : _ !lhs (     
           /  at-least 
           /  exactly 
           /  no-more-than 
           /  between 
           /  range
           /  set
           /  literal )  ]]

dump_ast (match(peg,grammar_s))
--dump_ast (match(peg,rule_s))
--dump_ast (match(peg,"A     :B C D E "))
symbol_s = "rgsr09gaoijfsdfkrtjhaADSFASDFAr--"

--print (match(symbol, symbol_s))
assert(#symbol_s+1 == (match(symbol, symbol_s)))
assert(#range_s+1 == (match(range_c,range_s)))
assert(#set_s+1 == (match(set_c,set_s)))
assert(#string_s+1 == (match(string,string_s)))
-- PEGylator

-- A parser generator for LPEG.

require "lpeg"
--epnf = require "lua-luaepnf/src/epnf"
require "tools/ansi"
local util = require "tools/util"
local dump_ast = util.dump_ast
dofile "range.lua"
local epnf = dofile "tools/epnf.lua"
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
	symbol = valid_sym * sym^0  + white -- incorrect: allows -symbol-name- 
	string_match = -P"\"" * -P"\\" * P(1)
	string = (string_match + P"\\\"" + P"\\")^1
	range_match =  -P"-" * -P"\\" * -P"]" * P(1)
	range_capture = (range_match + P"\\-" + P"\\]" + P"\\")
	range_c  = range_capture^1 * P"-" * range_capture^1
	set_match = -P"}" * -P"\\" * P(1)
	set_c    = (set_match + P"\\}" + P"\\")^1

peg = epnf.define(function(_ENV)
	START "rules"
	SUPPRESS ("WS", "cat_space", "cat",
		      "element" ,"more_elements", "pattern",
		      "allowed_prefixed", "allowed_suffixed",
		      "simple", "compound", "prefixed", "suffixed" )
	local cat_space = WS^1
	local WS = WS^0
	local symbol =  C(symbol)
	local string =  C(string)
	local range_c = C(range_c)
	local set_c  =  C(set_c)
	rules   =  V"rule"^1
	rule    =  V"lhs"  * V"rhs"
	lhs     =  WS * V"pattern" * WS * ( P":" + P"=")
    rhs     =  V"element" * V"more_elements"
	pattern =  symbol 
			+  V"hidden_pattern"
	hidden_pattern =  P"<" * symbol * P">"
	element  =  -V"lhs" * WS 
	         *  ( V"compound"
			 +    V"simple")  
	more_elements  =  V"choice"  
			       +  V"cat"
			       +  P""
	choice =  WS * P"/" * V"element" * V"more_elements"
	cat =  WS * V"element" * V"more_elements"
	 -V"lhs" * WS 
	         *  ( V"compound"
			 +    V"simple") 
	compound =  V"factor"
			 +  V"enclosed"
			 +  V"hidden_match" 
	factor   =  WS * P"(" 
			 *  WS * V"rhs" * WS 
			 *  P")" 
	hidden_match =  WS * P"<"
				 *  WS * V"rhs" * WS
				 *  P">"
	simple   =  V"prefixed"
			 +  V"suffixed"
			 +  V"atom" 
	prefixed =  V"if_not_this"
			 +  V"not_this"
			 +  V"if_and_this"
	if_not_this = P"!" * V"allowed_prefixed" 
	not_this    = P"-" * V"allowed_prefixed"
	if_and_this = P"&" * V"allowed_prefixed"
	allowed_prefixed = (V"compound" + V"suffixed" + V"atom")
	suffixed =  V"optional"
			 +  V"more_than_one"
			 +  V"maybe"
	enclosed =  V"literal"
		     +  V"set"
		     +  V"range"
    literal =  P'"' * (string + P"") * P'"'  
    set     =  P"{" * set_c^1 * P"}"   
    range   =  P"[" * range_c * P"]"  
    allowed_suffixed = (V"compound" + V"prefixed" + V"atom") 
	optional      =  V"allowed_suffixed" * WS * P"*"
	more_than_one =  V"allowed_suffixed" * WS * P"+"
	maybe         =  V"allowed_suffixed" * WS * P"?"
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
	lhs       =  _pattern_ ":"
    rhs       =  element more-elements
	<pattern> =  symbol / hidden-pattern
	hidden-pattern =  "<" symbol ">"
	<element>  =  match / factor
	more-elements  =  choice  /  cat / ""
	choice =  _"/" element more_elements
	cat =  WS element more_elements
	match    =  -lhs_ (compound / simple) 
	compound =  factor / hidden-match 
	factor   =  _"("_ rhs_ ")" 
	hidden_match =  _"<"_ rhs_ ">"
	simple   =  prefixed / suffixed / enclosed / atom 
	prefixed =  if-not-this / not-this / if-and-this
	if-not-this =  "!" symbol
	not-this    =  "-" symbol
	if-and-this =  "&" symbol
	suffixed =  optional / more-than-one / maybe
	enclosed =  literal / set / range
	literal =  "\"" (string / "") "\""  
    set     =  "{" set_c+ "}"   
    range   =  "[" range_c "]"   
	optional      =  symbol "*"
	more_than_one =  symbol "+"
	maybe         =  symbol "?"
    atom =  symbol


]]
dump_ast (match(peg,grammar_s))
dump_ast (match(peg,peg_s))
symbol_s = "rgsr09gao--ijf-sdfkrtjhaADSFASDFAr"

--print (match(symbol, symbol_s))
assert(#symbol_s+1 == (match(symbol, symbol_s)))
assert(#range_s+1 == (match(range_c,range_s)))
assert(#set_s+1 == (match(set_c,set_s)))
assert(#string_s+1 == (match(string,string_s)))
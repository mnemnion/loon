-- PEGylator

-- A parser generator for LPEG.

local lpeg = require "lpeg"
local ansi = require "ansi"
local util = require "util"
local epeg = require "epeg"
local dump_ast = util.dump_ast
local clear = ansi.clear()
local epnf = require "epnf"
ast = dofile "transform.lua"

local match = lpeg.match -- match a pattern against a string
local P = lpeg.P -- match a string literally
local S = lpeg.S  -- match anything in a set
local R = epeg.R  -- match anything in a range
local C = lpeg.C  -- captures a match
local Ct = lpeg.Ct -- a table with all captures from the pattern
local V = lpeg.V -- create a variable within a grammar

	local comment_m  = -P"\n" * P(1)
	local comment_c = P";" * comment_m^0 + P"\n"
	local valid_sym = R"AZ" + R"az" + P"-"  
	local digit = R"09"
	local sym = valid_sym + digit
	local WS = P' ' + P'\n' + P',' + P'\09'
	local white = P"_"
	local symbol = valid_sym * sym^0  + white -- incorrect: allows -symbol-name- 
	local string_match = -P"\"" * -P"\\" * P(1)
	local string = (string_match + P"\\\"" + P"\\")^1
	local range_match =  -P"-" * -P"\\" * -P"]" * P(1)
	local range_capture = (range_match + P"\\-" + P"\\]" + P"\\")
	local range_c  = range_capture^1 * P"-" * range_capture^1
	local set_match = -P"}" * -P"\\" * P(1)
	local set_c    = (set_match + P"\\}" + P"\\")^1
	local some_num_c =   digit^1 * P".." * digit^1
					 +   (P"+" + P"-")^0 * digit^1
local peg = epnf.define(function(_ENV)
	START "rules"
	SUPPRESS ("WS", "cat", "enclosed",
		      "element" ,"elements", "pattern",
		      "allowed_prefixed", "allowed_suffixed",
		      "simple", "compound", "prefixed", "suffixed" )
	local WS         =  WS^0
	local symbol     =  C(symbol)
	local string     =  C(string)
	local range_c    =  C(range_c)
	local set_c      =  C(set_c)
	local some_num_c =  C(some_num_c)
	local cmnt    =  C(comment_c)
	rules   =  V"rule"^1
	rule    =  Cp() * V"lhs"  * V"rhs"
	lhs     =  WS * V"pattern" * WS * ( P":" + P"=")
    rhs     =  V"element" * V"elements"
	pattern =  symbol 
			+  V"hidden_pattern"
	hidden_pattern =  P"<" * symbol * P">"
	element  =  -V"lhs" * WS 
	         *  ( V"compound"
			 +    V"simple") 
			 +  V"comment" 
	comment = cmnt
	elements  =  V"choice"  
			       +  V"cat"
			       +  P""
	choice =  WS * P"/" * V"element" * V"elements"
	cat =  WS * V"element" * V"elements"
	 -V"lhs" * WS 
	         *  ( V"compound"
			 +    V"simple") 
	compound =  V"factor"
			 +  V"enclosed"
			 +  V"hidden_match" 
	factor   =  WS * P"(" 
			 *  WS * V"elements" * WS 
			 *  P")" 
	hidden_match =  WS * P"<"
				 *  WS * V"elements" * WS
				 *  P">"
	simple   =  V"suffixed"
			 +  V"prefixed"
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
			 +  V"with_suffix"
			 +  V"some_number"
	enclosed =  V"literal"
		     +  V"set"
		     +  V"range"
    literal =  P'"' * (string + P"") * P'"'  --watch for "" later
    set     =  P"{" * set_c^1 * P"}"   
    range   =  P"[" * range_c * P"]"  
    allowed_suffixed = (V"compound" + V"prefixed" + V"atom") 
	optional      =  V"allowed_suffixed" * WS * P"*"
	more_than_one =  V"allowed_suffixed" * WS * P"+"
	maybe         =  V"allowed_suffixed" * WS * P"?"
	some_number   =  V"allowed_suffixed" * WS * P"$" * some_num_c
	with_suffix   =  V"some_number" * ( C"*" + C"+" + C"?")
    atom =  symbol
end)

local range_s = [[ \]\--CD ]]

local set_s   = [[ abc\def\}g䷀䷁ ]]
local string_s = [[ asldfr\"adf  asdf\asdf]]
local grammar_s = [[ A : B C ( E / F ) / F G H
			  I : "J" 
			  K : L* M+ N?
			  O : !P &Q -R
			  <S> : <T (U V)>
			  W : {XY} [a-z] 
			  A : B$2 C$-3 D$4..5 E$+4]]

local deco_s  = [[ A: <-(B C/ D)$2..5*> ]]
local rule_s  = [[A:B C(D E)/(F G H)
			  C : "D" 
			  D : E F G
]]

local peg_s = [[
	rules : rule +
	rule : lhs rhs
	lhs       =  _pattern_ ":"
    rhs       =  element more-elements
	<pattern> =  symbol / hidden-pattern
	hidden-pattern =  "<" symbol ">"
	<element>  =  match / factor
	more-elements  =  choice  /  cat / ""
	choice =  _"/" element more-elements
	cat =  WS element more-elements
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
	more-than-one =  symbol "+"
	maybe         =  symbol "?"
    atom =  symbol
]]

local clu_s = [[

     clu :  form* / EOF

      form :  unary* (_atom_ / _compound_) / _<comment>

     unary :  ","
              /  "~"
           /  "`"
           /  reader-macro

      atom :  symbol 
           /  number 
           /  keyword
           /  string

  compound :  list
           /  hash
           /  vector
           /  type 
           /  syntax

   symbol  :  latin !(forbidden) ANYTHING
   keyword :  ":" symbol

    list   :  "(" form* ")"
    hash   :  "{" form$2* "}"
    vector :  "[" form* "]"
    type   :  "<" form* ">" !type form
    syntax :  "|" dispatch* "|"

  dispatch :  "--|" moonscript "|--" 
           /  "--!" dispatch-string 
           /  lun
       lun :  !"|" ANYTHING    ;-) looks like lua!  
moonscript :  !"|" ANYTHING    ;-) looks like moonscript!

     latin :  ([A-Z] / [a-z])
 <comment> :  ";" !"\n" ANYTHING "\n"

]]


--dump_ast (match(peg,grammar_s))
--dump_ast(match(peg,clu_s))
--dump_ast (match(peg,peg_s))
--dump_ast(match(peg,deco_s))
symbol_s = "rgsr09gao--ijf-sdfkrtjhaADSFASDFAr"

tree = match(peg,deco_s)
ast.pr(tree)
--print (match(symbol, symbol_s))
assert(#symbol_s+1 == (match(symbol, symbol_s)))
assert(#range_s+1 == (match(range_c,range_s)))
assert(#set_s+1 == (match(set_c,set_s)))
assert(#string_s+1 == (match(string,string_s)))

return { peg = peg }
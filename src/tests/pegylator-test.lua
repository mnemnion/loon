-- Tests for Pegylator
local lpeg = require "lpeg"
package.path = package.path .. ";../mods/?.lua"
local peg  = require "pegylator"

local peg = peg.peg
local match = lpeg.match

local range_s = [[ \]\--CD ]]

local set_s   = [[ abc\def\}g䷀䷁ ]]
local string_s = [[ asldfr\"adf  asdf\asdf]]
local grammar_s = [[ A : B C ( E / F ) / F G H
			  I : "J" 
			  K : L* M+ N?
			  O : !P &Q -R
			  <S> : <T (U V)>
			  W : {XY} [a-z] ]]

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
dump_ast (lpeg.match(peg,grammar_s))
dump_ast (lpeg.match(peg,peg_s))
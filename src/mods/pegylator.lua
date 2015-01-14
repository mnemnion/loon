-- PEGylator

-- A parser generator for LPEG.
require 'pl.strict'

local lpeg = require "lpeg"
local ansi = require "ansi"
local util = require "util"
local epeg = require "peg/epeg"
local dump_ast = util.dump_ast
local clear = ansi.clear()
local epnf = require "peg/epnf"
ast = require "peg/ast"
local grammar = require "peg/grammars"
local s = require "peg/rule-sort"
t = require "peg/transform"

local match = lpeg.match -- match a pattern against a string
local P = lpeg.P -- match a string literally
local S = lpeg.S  -- match anything in a set
local R = epeg.R  -- match anything in a range
local B = lpeg.B
local C = lpeg.C  -- captures a match
local Csp = epeg.Csp -- captures start and end position of match
local Ct = lpeg.Ct -- a table with all captures from the pattern
local V = lpeg.V -- create a variable within a grammar

	local comment_m  = -P"\n" * P(1)
	local comment_c =  comment_m^0 * #P"\n"
	local letter = R"AZ" + R"az" 
	local valid_sym = letter + P"-"  
	local digit = R"09"
	local sym = valid_sym + digit
	local WS = P' ' + P'\n' + P',' + P'\09'
	local symbol = letter * ( -(P"-" * WS) * sym )^0  
	local d_string_match = -P'"' * -P"\\" * P(1)
	local s_string_match = -P"'" * -P"\\" * P(1)
	local h_string_match = -P"`" * -P"\\" * P(1)
	local h_string    = (h_string_match + P"\\`" + P"\\\\" + (P"\\" * P(1)))^1
	local d_string = (d_string_match + P"\\\"" + P"\\\\" + (P"\\" * P(1)))^1
	local s_string = (s_string_match + P"\\'" + P"\\\\" + (P"\\" * P(1)))^1 
	local range_match =  -P"-" * -P"\\" * -P"]" * P(1)
	local range_capture = (range_match + P"\\-" + P"\\]" + P"\\")
	local range_c  = range_capture^1 * P"-" * range_capture^1
	local set_match = -P"}" * -P"\\" * P(1)
	local set_c    = (set_match + P"\\}" + P"\\")^1
	local some_num_c =   digit^1 * P".." * digit^1
					 +   (P"+" + P"-")^0 * digit^1
 peg = epnf.define(function(_ENV)
	START "rules"
	SUPPRESS ("WS",  "enclosed", "ws", "form",
		      "element" ,"elements", "pattern",
		      "allowed_prefixed", "allowed_suffixed",
		      "simple", "compound", "prefixed", "suffixed" )
	local WS         =  WS^0
	local symbol     =  Csp(symbol)
	local d_string     =  Csp(d_string) 
	local s_string   =  Csp(s_string)
	local hidden_string = Csp(h_string)
	local range_c    =  Csp(range_c)  
	local set_c      =  Csp(set_c)
	local some_num_c =  Csp(some_num_c)
	local cmnt       =  P";" * Csp(comment_c) 


	rules   =  V"rule"^1
	rule    =  V"lhs" * V"rhs"
	lhs     =  WS * V"pattern" * WS * ( P":" + P"=" + ":=")
    rhs     =  V"form"
    form   =  V"element" * V"elements"
	pattern =  symbol
			+  V"hidden_pattern"
	hidden_pattern =  P"`" * symbol * P"`"
	element  =  -V"lhs" * WS 
	         *  ( V"simple"
			 + 	  V"compound"
			 +    V"comment")

	elements  =  V"choice"  
			       +  V"cat"
			       +  P""
	choice =  WS * P"/" * V"form"
	cat =  WS * V"form"
	compound =  V"group"
			 +  V"capture_group"
			 +  V"enclosed"
			 +  V"hidden_match"
	capture_group = P"~" * V"group" 
	group   =  WS * V"PEL" 
			 *  WS * V"form" * WS 
			 *  V"PER"
	PEL        = Csp "("
    PER        = Csp ")"
    enclosed =  V"literal"
    		 +  V"hidden_literal"
             +  V"set"
       	     +  V"range"
	hidden_match =  WS * P"``"
				 *  WS * V"form" * WS
				 *  P"``"
	simple   =  V"suffixed"
			 +  V"prefixed"
			 +  V"atom" 
		comment = cmnt
	prefixed =  V"if_not_this"
			 +  V"not_this"
			 +  V"if_and_this"
    suffixed =  V"optional"
	         +  V"more_than_one"
	         +  V"maybe"
	         +  V"with_suffix"
	    	 +  V"some_number"
		   if_not_this = P"!" * WS * V"allowed_prefixed"
	   	   not_this    = P"-" * WS * V"allowed_prefixed"
		   if_and_this = P"&" * WS * V"allowed_prefixed"
               literal =  P'"' * d_string^0 * P'"'
                       +  P"'" * s_string^0 * P"'"
        hidden_literal = P"`" * hidden_string * P"`"
               set     =  P"{" * set_c^1 * P"}"  
-- Change range to not use '-' separator instead require even # of bytes.
-- Ru catches edge cases involving multi-byte chars. 
               range   =  P"[" * range_c * P"]" 
	     optional      =  V"allowed_suffixed" * WS * P"*"
	     more_than_one =  V"allowed_suffixed" * WS * P"+"
	     maybe         =  V"allowed_suffixed" * WS * P"?"
   	     some_number   =  V"allowed_suffixed" * WS * P"$" * some_num_c
	     with_suffix   =  V"some_number" * ( Csp"*" + Csp"+" + Csp"?")
	     some_number   =  V"allowed_suffixed" * WS * P"$" * some_num_c
	  allowed_prefixed =  V"compound" + V"suffixed" + V"atom"
	  allowed_suffixed =  V"compound" + V"prefixed" + V"atom"	 
    atom =  V"ws" + symbol 
    ws = Csp(P"_")
end)



--dump_ast (match(grammar.peg,grammar_s))
--dump_ast(match(grammar.peg,clu_s))
--dump_ast (match(grammar.peg,peg_s))
--dump_ast(match(grammar.peg,deco_s))

tree = ast.parse(peg,grammar.peg_s)

g = ast.parse(peg,grammar.grammar_s)
a = dofile "peg/a.peg"
a = ast.parse(peg,a)

--s.sort(a)
--s.sort(tree)
--ast.pr(tree)

t.transform(a)
--t.transform(tree)
t.transform(g)

assert(tree == tree.index(5):root())

--print (match(grammar.symbol, symbol_s))
assert(#grammar.symbol_s+1 == (match(symbol, grammar.symbol_s)))
assert(#grammar.range_s+1 == (match(range_c,grammar.range_s)))
assert(#grammar.set_s+1 == (match(set_c,grammar.set_s)))
assert(#grammar.string_s+1 == (match(d_string,grammar.string_s)))

io.write(clear)
print(...)

return { peg = peg }
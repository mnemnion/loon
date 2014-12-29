-- PEGylator

-- A parser generator for LPEG.

local lpeg = require "lpeg"
ansi = require "ansi"
local util = require "util"
local epeg = require "peg/epeg"
local dump_ast = util.dump_ast
local clear = ansi.clear()
local epnf = require "peg/epnf"
local ast = require "peg/ast"
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
	local comment_c = P";" * comment_m^0 * #P"\n"
	local letter = R"AZ" + R"az" 
	local valid_sym = letter + P"-"  
	local digit = R"09"
	local sym = valid_sym + digit
	local WS = P' ' + P'\n' + P',' + P'\09'
	local symbol = letter * ( -(P"-" * WS) * sym )^0  -- incorrect: allows -symbol-name- 
	local string_match = -P"\"" * -P"\\" * P(1)
	local string = (string_match + P"\\\"" + P"\\")^1 
	local range_match =  -P"-" * -P"\\" * -P"]" * P(1)
	local range_capture = (range_match + P"\\-" + P"\\]" + P"\\")
	local range_c  = range_capture^1 * P"-" * range_capture^1
	local set_match = -P"}" * -P"\\" * P(1)
	local set_c    = (set_match + P"\\}" + P"\\")^1
	local some_num_c =   digit^1 * P".." * digit^1
					 +   (P"+" + P"-")^0 * digit^1
 peg = epnf.define(function(_ENV)
	START "rules"
	SUPPRESS ("WS", "cat", "enclosed", "ws",
		      "element" ,"elements", "pattern",
		      "allowed_prefixed", "allowed_suffixed",
		      "simple", "compound", "prefixed", "suffixed" )
	local WS         =  WS^0
	local symbol     =  Csp(symbol)
	local string     =  Csp(string) 
	local range_c    =  Csp(range_c)  
	local set_c      =  Csp(set_c)
	local some_num_c =  Csp(some_num_c)
	local cmnt       =  Csp(comment_c) 


	rules   =  V"rule"^1
	rule    =  V"lhs" * V"rhs"
	lhs     =  WS * V"pattern" * WS * ( P":" + P"=" + ":=")
    rhs     =  V"element" * V"elements"
	pattern =  symbol
			+  V"hidden_pattern"
	hidden_pattern =  P"`" * symbol * P"`"
	element  =  -V"lhs" * WS 
	         *  ( V"compound"
			 +    V"simple"
			 +    V"comment")

	elements  =  V"choice"  
			       +  V"cat"
			       +  P""
	choice =  WS * P"/" * V"element" * V"elements"
	cat =  WS * V"element" * V"elements" 
	compound =  V"group" 
			 +  V"enclosed"
			 +  V"hidden_match" 
	group   =  WS * P"(" 
			 *  WS * V"elements" * WS 
			 *  P")"
    enclosed =  V"literal"
             +  V"set"
       	     +  V"range"
	hidden_match =  WS * P"``"
				 *  WS * V"elements" * WS
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
               literal =  P'"' * (string + P"") * P'"'
               set     =  P"{" * set_c^1 * P"}"  
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

a = dofile "peg/a.peg"
a = ast.parse(peg,a)

s.sort(a)
s.sort(tree)
ast.pr(tree)

assert(tree == tree.index(5):root())

--print (match(grammar.symbol, symbol_s))
assert(#grammar.symbol_s+1 == (match(symbol, grammar.symbol_s)))
assert(#grammar.range_s+1 == (match(range_c,grammar.range_s)))
assert(#grammar.set_s+1 == (match(set_c,grammar.set_s)))
assert(#grammar.string_s+1 == (match(string,grammar.string_s)))

io.write(clear)

return { peg = peg }
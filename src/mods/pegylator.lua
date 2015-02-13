-- PEGylator

-- A parser generator for LPEG.
require 'pl.strict'
local util = require "util"
local lpeg = require "lpeg"
local ansi = require "ansi"
local epeg = require "peg/epeg"
local core = require "peg/core-rules"
local dump_ast = util.dump_ast
local clear = ansi.clear()
local epnf = require "peg/epnf"
local ast = require "peg/ast"
local grammar = require "peg/pegs/grammars"
highlight = require "peg/highlight"
transform = require "peg/transform"
codegen = require "peg/codegen"

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
	local h_string    = (-P"`" * core.escape)^0
	local d_string = (-P'"' * core.escape)^0
	local s_string = (-P"'" * core.escape)^0
	local range_match =  -P"-" * -P"\\" * -P"]" * P(1)
	local range_capture = (range_match + P"\\-" + P"\\]" + P"\\")
	local range_c  = range_capture^1 * P"-" * range_capture^1
	local set_match = -P"}" * -P"\\" * P(1)
	local set_c    = (set_match + P"\\}" + P"\\")^1
	local some_num_c =   digit^1 * P".." * digit^1
					 +   (P"+" + P"-")^0 * digit^1

local peg_fn = function(_ENV)
	START "rules"
	---[[
	SUPPRESS ("WS",  "enclosed", "form", 
		      "element" ,"elements", "pattern",
		      "allowed_prefixed", "allowed_suffixed",
		      "simple", "compound", "prefixed", "suffixed"  )
	--]]
	local WS         =  WS^0
	local symbol     =  Csp(symbol)
	local d_string     =  Csp(d_string) 
	local s_string   =  Csp(s_string)
	local hidden_string = Csp(h_string)
	local range_c    =  Csp(range_c)  
	local set_c      =  Csp(set_c)
	local cmnt       =  P";" * Csp(comment_c)
	local some_num_c = some_num_c 


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
               literal =  Csp(C'"' * d_string * C'"')
                       +  Csp(C"'" * s_string * C"'")
        hidden_literal = -P"``" * P"`" * hidden_string * -P"``" * P"`"
               set     =  P"{" * set_c^1 * P"}"  
-- Change range to not use '-' separator instead require even # of bytes.
-- Ru catches edge cases involving multi-byte chars. 
               range   =  P"[" * range_c * P"]" 
	     optional      =  V"allowed_suffixed" * WS * P"*"
	     more_than_one =  V"allowed_suffixed" * WS * P"+"
	     maybe         =  V"allowed_suffixed" * WS * P"?"
	     with_suffix   =  V"some_number" * ( Csp"*" + Csp"+" + Csp"?")
	     some_number   =  V"allowed_suffixed" * WS * P"$" * V"repeats"
	     repeats    =  Csp(some_num_c)
	  allowed_prefixed =  V"compound" + V"suffixed" + V"atom"
	  allowed_suffixed =  V"compound" + V"prefixed" + V"atom"	 
    atom =  V"ws" + symbol 
    ws = Csp(P"_")
end

peg = epnf.define(peg_fn, nil, false) -- nil is _G, false = suppress output
peg_hl = epnf.define(peg_fn, nil, true)
-- Rig

local pretty = require "pl.pretty"
local diff = require "diff"

function tshow(table)
	io.write(pretty.write(table))
end
tree = ast.parse(peg,grammar.peg_s)
tree_hl = ast.parse(peg_hl,grammar.peg_s)
g = ast.parse(peg,grammar.grammar_s)
a = dofile "peg/pegs/a.peg"
a = ast.parse(peg,a)
w = ast.parse(peg,grammar.wtf)
l = ast.parse(peg,grammar.lisp_s)

hl = highlight.light
t  = transform.transform
--[[
t.transform(a)
t.transform(tree)
t.transform(g)
codegen.build(tree)
--]]

assert(tree == tree.index(5):root())
--assert(tree.str == hl(tree))
--print (match(grammar.symbol, symbol_s))
assert(#grammar.symbol_s+1 == (match(symbol, grammar.symbol_s)))
assert(#grammar.range_s+1 == (match(range_c,grammar.range_s)))
assert(#grammar.set_s+1 == (match(set_c,grammar.set_s)))
assert(#grammar.string_s+1 == (match(d_string,grammar.string_s)))

local clear = tostring(ansi.clear)
io.write(clear)
--print(tree)

return { peg = peg }
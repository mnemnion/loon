 
require 'pl.strict'

local lpeg = require "lpeg"
local ansi = require "ansi"
local util = require "util"
local epeg = require "peg/epeg"
local core = require "peg/core-rules"
local dump_ast = util.dump_ast
local clear = ansi.clear()
local epnf = require "peg/epnf"
local ast = require "peg/ast"
local grammar = require "peg/grammars"
local t = require "peg/transform"

local match = lpeg.match -- match a pattern against a string
local P = lpeg.P -- match a string literally
local S = lpeg.S  -- match anything in a set
local R = epeg.R  -- match anything in a range
local B = lpeg.B
local C = lpeg.C  -- captures a match
local Csp = epeg.Csp -- captures start and end position of match
local Ct = lpeg.Ct -- a table with all captures from the pattern
local V = lpeg.V -- create a variable within a grammar

local WS = P' ' + P'\n' + P',' + P'\09'

local lhs =  WS * pattern * WS * (":" + "=" + ":=")
local pattern =  symbol + hidden_pattern
local hidden_pattern =  "`" * symbol * "`"
local enclosed =  literal + set + range * hidden * WS
local comment =  P";" * comment_c  --  make real
local atom =  symbol + ws
local ws =  "_"
local literal =  P"\"" * C(string^0) * P"\""
local set =  P"{" * set_c^1 * P"}"
local range =  P"[" * range_c * P"]"
local comment_m =  "\n" * ANY
local comment_c =  P";" * C(comment_m^0) * P"\n"
local string =  (string_match^1 + '\\"' + "\\")
local string_match =  P"\"" * P"\\" * ANY
local letter =  R"AZ" * R"az"
local valid_sym =  letter^1 * "-"
local digit =  R"09"


peg = epnf.define(function(_ENV)
rules =  V"rule"^1
rule =  lhs * V"rhs"
rhs =  V"element" * V"elements"^0
element =  -lhs * WS * (V"compound" + V"simple" + comment)  --  with a comment
elements =  V"choice" + V"cat"
compound =  V"group" + enclosed + hidden_match
simple =  V"prefixed" + V"suffixed" + atom
choice =  WS * "/" * V"element" * V"elements"^0
cat =  WS * V"element" * V"elements"^0
group =  WS * "(" * WS * V"rhs" * WS * ")"
match =  WS * "``" * WS * V"rhs" * WS * "``"
prefixed =  V"if_not_this" + V"if_and_this"
if_not_this =  P"!" * WS * V"allowed_prefixed"
if_and_this =  P"&" * WS * V"allowed_prefixed"
suffixed =  V"optional" + V"more_than_one" + V"maybe" + V"with_suffix" + V"some_number"
optional =  V"allowed_suffixed" * WS * P"*"
more_than_one =  V"allowed_suffixed" * WS * P"+"
maybe =  V"allowed_suffixed" * WS * P"?"
some_number =  V"allowed_suffixed" * WS * "$" * some_num_c
with_suffix =  V"some_number" * (P"*" + P"+" + P"?")
allowed_prefixed =  V"compound" + V"suffixed" + atom
allowed_suffixed =  V"compound" + V"prefixed" + atom
end)

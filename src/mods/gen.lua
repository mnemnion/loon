 
require 'pl.strict'

local lpeg = require "lpeg"
local clu = require "clu/prelude"
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


peg = epnf.define(function(_ENV)
  START "rules"
rules =  V"comment"^0 * V"rule"^1
rule =  V"lhs" * V"rhs"
lhs =  V"WS" * V"pattern" * V"WS" * (Csp":" + Csp"=" + Csp":=")
rhs =  V"element" * V"elements"^0
pattern =  V"symbol" + V"hidden_pattern"
hidden_pattern =  Csp"`" * V"symbol" * Csp"`"
element =  -V"lhs" * V"WS" * (V"compound" + V"simple" + V"comment")  -- ; with a comment
elements =  V"choice" + V"cat"
compound =  V"group" + V"enclosed" + V"hidden_match"
simple =  V"prefixed" + V"suffixed" + V"atom"
choice =  V"WS" * Csp"/" * V"element" * V"elements"^0
cat =  V"WS" * V"element" * V"elements"^0
group =  V"WS" * Csp"(" * V"WS" * V"rhs" * V"WS" * Csp")"
enclosed =  V"literal" + V"set" + V"range"
hidden_match =  V"WS" * Csp"``" * V"WS" * V"rhs" * V"WS" * Csp"``"
comment =  P";" * V"comment_c"  -- ; make real
prefixed =  V"if_not_this" + V"if_and_this"
if_not_this =  P"!" * V"WS" * V"allowed_prefixed"
if_and_this =  P"&" * V"WS" * V"allowed_prefixed"
suffixed =  V"optional" + V"more_than_one" + V"maybe" + V"with_suffix" + V"some_number"
optional =  V"allowed_suffixed" * V"WS" * P"*"
more_than_one =  V"allowed_suffixed" * V"WS" * P"+"
maybe =  V"allowed_suffixed" * V"WS" * P"?"
some_number =  V"allowed_suffixed" * V"WS" * Csp"$" * V"some_num_c"
with_suffix =  V"some_number" * (P"*" + P"+" + P"?")
allowed_prefixed =  V"compound" + V"suffixed" + V"atom"
allowed_suffixed =  V"compound" + V"prefixed" + V"atom"
atom =  V"symbol" + V"ws"
ws =  Csp"_"
literal =  P"\"" * (V"string"^0) * P"\""
set =  P"{" * V"set_c"^1 * P"}"
range =  P"[" * V"range_c" * P"]"
comment_m =  Csp"\n" * V"ANY"
comment_c =  P";" * (V"comment_m"^0) * P"\n"
string =  (V"string_match"^1 + Csp'\\"' + Csp"\\")
string_match =  P"\"" * P"\\" * V"ANY"
letter =  R"AZ" + R"az"
valid_sym =  V"letter"^1 * Csp"-"
digit =  R"09"
end)

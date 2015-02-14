require 'pl.strict'

local lpeg = require "lpeg"
local ansi = require "ansi"
local util = require "util"
local epeg = require "peg/epeg"
local core = require "peg/core-rules"
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

local WS = (P' ' + P'\n' + P',' + P'\09')^0

--[[
lisp : _form_+

form : atom / list

list : "(" form* ")"

atom : symbol / number

symbol: ({AZ} / {az})+

number : {09}+
--]]

local _lisp_fn = function(_ENV)
	START"lisp"
	lisp = V"_WS" * V"form"^1 * V"_WS"
	form = V"atom" + V"list"
	list = C"(" form* C")"
	atom = V"symbol" + V"number"
	symbol = (R"AZ" + R"az")^1
	number =  R"09"^1
	_WS = WS
end

return { lisp = epnf.define(_lisp_fn)}



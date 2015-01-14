-- Core Syntax Rules

-- A collection of useful regular patterns

 lpeg = require "lpeg"
local epeg = require "peg/epeg"

 match = lpeg.match -- match a pattern against a string
local P = lpeg.P -- match a string literally
local S = lpeg.S  -- match anything in a set
local R = epeg.R  -- match anything in a range
local B = lpeg.B
local C = lpeg.C  -- captures a match
local Csp = epeg.Csp -- captures start and end position of match
local Ct = lpeg.Ct -- a table with all captures from the pattern
local V = lpeg.V -- create a variable within a grammar
local Cmt = lpeg.Cmt

local core = {}

local digit = R"09"

local int   = digit^1

local float = digit^1 
			* P"." * digit^1 
		    * ((P"e" + P"E") * digit^1)^0

 escape =  -P"\\" * P(1) + P"\\" * P(1)

local string_single = P"'" * (-P"'" * escape)^0 * P"'"
local string_double = P'"' * (-P'"' * escape)^0 * P'"'
local string_back   = P"`" * (-P"`" * escape)^0 * P"`"

local strings = string_single + string_double + string_back

local strtest = require "peg/strings"

function assertions(strs)
	for k, v in pairs(strs) do 
		print ("testing", k)
		assert(#v+1 == (match(strings,v)))
		print ("\n",v, " is good")
	end
end

assertions(strtest)



-- Core Syntax Rules

-- A collection of useful regular patterns

local lpeg = require "lpeg"
local epeg = require "peg/epeg"

local match = lpeg.match -- match a pattern against a string
local P = lpeg.P -- match a string literally
local S = lpeg.S  -- match anything in a set
local R = epeg.R  -- match anything in a range
local B = lpeg.B
local C = lpeg.C  -- captures a match
local Csp = epeg.Csp -- captures start and end position of match
local Ct = lpeg.Ct -- a table with all captures from the pattern
local V = lpeg.V -- create a variable within a grammar

local core = {}

local digit = R"09"

local int   = digit^1

local float = digit^1 
			* P"." * digit^1 
		    * ((P"e" + P"E") * digit^1)^0
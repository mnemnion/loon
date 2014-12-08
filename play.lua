require "lpeg"

function rl()
	dofile "play.lua"
end

match = lpeg.match -- match a pattern against a string
P = lpeg.P -- match a string literally
S = lpeg.S  -- match anything in a set
R = lpeg.R  -- match anything in a range
C = lpeg.C  -- captures a match
Ct = lpeg.Ct -- a table with all captures from the pattern
V = lpeg.V -- create a variable within a grammar

symbol = R'az'^1-- incorrect start
number = R'09'^1 -- likewise
WS     = P' '^0 + P'\n'^0 -- correct modulo tabs

atom = symbol + number 

seq = WS * atom * WS * atom^0 * WS


form = P{
	"S";
  S =  seq + WS * '(' * V"S" * P')' * WS   
}

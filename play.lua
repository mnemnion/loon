require "lpeg"

function rl()
	dofile "play.lua"
end

-- Some tests

list_string = "(foo 23 bar)"
map  = "{ foo bar, baz 42}"

match = lpeg.match -- match a pattern against a string
P = lpeg.P -- match a string literally
S = lpeg.S  -- match anything in a set
R = lpeg.R  -- match anything in a range
C = lpeg.C  -- captures a match
Ct = lpeg.Ct -- a table with all captures from the pattern
V = lpeg.V -- create a variable within a grammar

symbol = R'az'^1-- incorrect start
number = R'09'^1 -- likewise
WS     = P' '^0 + P'\n'^0 + P',' + P'\07'

atom = WS * symbol * WS + WS * number * WS

seq = P"foo"

form = P{
  "form" ;
  list =  seq + WS * '(' * V"element"^0 * P')' * WS  ;
  element = atom + V"form" ;
  form = V"list" ;
}

print(match(form,list_string))
print(match(form,"()"))
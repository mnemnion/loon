require "lpeg"

match = lpeg.match -- match a pattern against a string
P = lpeg.P -- match a string literally
S = lpeg.S  -- match anything in a set
R = lpeg.R  -- match anything in a range
C = lpeg.C  -- captures a match
Ct = lpeg.Ct -- a table with all captures from the pattern


symbol = R'az'^0 -- incorrect start
number = R'09'^0 -- likewise

atom = symbol + number 

parens = P'(' * atom * P')'


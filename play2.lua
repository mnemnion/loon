dofile  "./tools/util.lua"
require "lpeg"


match = lpeg.match -- match a pattern against a string
P = lpeg.P -- match a string literally
S = lpeg.S  -- match anything in a set
R = lpeg.R  -- match anything in a range
C = lpeg.C  -- captures a match
Ct = lpeg.Ct -- a table with all captures from the pattern
V = lpeg.V -- create a variable within a grammar


WS     = P' '^0 + P'\n'^0 + P',' + P'\07'


form = P{
  "form" ;
  symbol = C(R'az'^1) ;
  number = C(R'09'^1) ;
  atom = WS * V"symbol" * WS + WS * V"number" * WS ;
  list =   P'(' * V"element"^0 * P')' * WS  ;
  element = V"atom" + V"form" ;
  form = V"list" ;
}
--]]


print(match(form,"(foo)"))
print(match(form,"()"))
complex = (match(form,"(foo bar(baz bux))"))
print(complex)
table_print({})
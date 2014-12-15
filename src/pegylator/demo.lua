require "lpeg"

match, P, V, R, S = lpeg.match, lpeg.P, lpeg.V, lpeg.R, lpeg.S

space = P" "
digit = R"09"
operand = S"+-*/"
token = space + P"(" + digit^1 + P")" + operand

tokenizer = token^1

group = P {
	"groups";
	groups = #token * V"group" + token ;
	group = P"(" * V"groups"^0 * P")";
}
---[[
expr = P {
	"expr";
	expr = token + ( V"group" + V"factor" + V"term") ; --+ token ;
	group = P"(" * V"expr"^0 * P")";
	factor = #token * V"expr" * (P"*" + P"/") * V"expr";
	term = token; -- we do not reach this point. 
}
--]] -- The following asserts are valid if expr is commented:

test_s = "(1 + 2 / 3) + 4 * 5 + (6)"
group_s = "(1 (2))"
invalid_token =  "(1 + 2 / ; 3) + 4 * 5 + (6)"
assert(match(tokenizer,test_s) == #test_s+1)
assert(match(tokenizer,invalid_token) ~= #invalid_token+1)
assert(match(group,group_s))
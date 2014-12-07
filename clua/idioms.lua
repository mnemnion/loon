-- Some idioms for the incremental compiler

-- This takes strings, and interns them as values in the global environment.
-- Both strings are interpreted as symbols
function globalSetSyms (lval, rval)
	_G[lval] = _G[rval]
end
--[[
> foo = 23
> bar = "fortytwo"
> globalSet("foo","bar")
> print(foo)
fortytwo
--]] 

-- This takes a string and a value, interning the value
function globalSetVal(lval, rval)
	_G[lval] = rval
end
--[[
> foo = 23
> bar = "fortytwo"
> globalSetVal("foo","bar")
> print(foo)
bar
--]] 
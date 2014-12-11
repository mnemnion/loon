-- Some idioms for the incremental compiler

-- This takes strings, and interns them as values in the global environment.
-- Both strings are interpreted as symbols
function _GSetSyms (lval, rval)
	_G[lval] = _G[rval]
end
--[[ > foo = 23
	 > bar = "fortytwo"
	 > _GSetSyms("foo","bar")
	 > print(foo)
	 fortytwo --]] 

-- This takes a string and a value, interning the value
function _GSetVal(lval, rval)
	_G[lval] = rval
end
--[[ > foo = 23
	 > bar = "fortytwo"
	 > _GSetSyms("foo","bar")
	 > print(foo)	
	 bar --]] 

-- This creates an anonymous function and returns it.
function makeFn (fnArg, fnBody)
	f = loadstring("return function("..fnArg..") "..fnBody.." end")
	return f()
end

--[[ > f = makeFn("bar, baz", "return bar..baz")
	 > _GSetVal("foo",f)
	 > print(foo("hello"," function"))
	 hello function --]]

-- Next problem: this doesn't understand, or have access to, the local environment.
-- in context, the local environment is whatever we've said it is, but loadstring only
-- knows the global context. 
-- Therefore, we'll need to cache the desired context in a global, attach it as the local environment, generate
-- our function, and return it. Cleanly.
-- This requires careful study. 
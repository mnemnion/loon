-- Some idioms for the incremental compiler

-- This takes strings, and interns them as values in the global environment.
-- Both strings are interpreted as symbols
function _GSetSyms (lval, rval)
	_G[lval] = _G[rval]
end
--[[ > foo = 23
	 > bar = "fortytwo"
	 > globalSet("foo","bar")
	 > print(foo)
	 fortytwo --]] 

-- This takes a string and a value, interning the value
function _GSetVal(lval, rval)
	_G[lval] = rval
end
--[[ > foo = 23
	 > bar = "fortytwo"
	 > globalSetVal("foo","bar")
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
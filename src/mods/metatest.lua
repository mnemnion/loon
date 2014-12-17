local function M() 
	local meta = {} -- make a metatable
	meta["foo"] =  function () 
		print "metafoo!"
	end
	meta["__call"] = function ()
		print "callfoo!"
	end
	meta["__index"] = meta
	local bar = {}
	setmetatable(bar,meta)
	return bar
end

bar = M()


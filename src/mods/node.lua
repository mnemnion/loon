-- The Node metatable type

-- Note that this should be a singleton: called exactly once by a given program. 

local ast = require "ast"


local function N () 
  -- <Node> metatable
  local meta = {}
  meta["__call"] = function ()
    print "Cannot call Node without evaluator"
  end
  meta["isnode"] = true
  meta["__index"] = meta 
  meta["index"] = index
  meta["root"] = ast.groot
  return meta
end

local N = N()

local function F ()
	-- <Forest> metatable
	local meta = {}
	meta["isnode"] = false 
	meta["__index"] = meta
	setmetatable(meta,N)
	return meta
end

return N
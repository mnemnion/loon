-- The Node metatable type

-- Note that this should be a singleton: called exactly once by a given program. 

local ast = require "ast"


local function N () 
  -- <Node> metatable
  local meta = {}
  meta["__call"] = function ()
    io.write "Cannot call Node without evaluator"
  end
  meta["__index"] = meta
  meta["__tostring"] = ast.tostring
  meta["isnode"] = true
  meta["index"] = index
  meta["root"] = ast.root
  meta["range"] = ast.range
  meta["clone"] = ast.copy
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
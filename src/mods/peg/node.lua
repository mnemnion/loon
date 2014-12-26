-- The Node metatable type

-- Note that this should be a singleton: called exactly once by a given program. 

local ast = require "peg/ast-node"



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
  meta["lift"]  = ast.lift
  meta["select"] = ast.__select_node
  meta["with"] = ast.__select_with_node
  return meta
end

--this feels dirty
--ast.__select_with_node = nil

local N = N()

return N
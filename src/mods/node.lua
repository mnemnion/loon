-- The Node metatable type

-- Note that this should be a singleton: called exactly once by a given program. 


local function N () 
  local meta = {}
  meta["__call"] = function ()
    print "Cannot call Node without evaluator"
  end
  meta["isnode"] = true
  meta["__index"] = meta 
  return meta
end

return N()
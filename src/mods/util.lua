 local ansi = require "ansi"
local cyan = tostring(ansi.cyan)
local magenta = tostring(ansi.magenta)
local clear = tostring(ansi.clear)
local green = tostring(ansi.green)


local F = function ()
  -- A method for functionalizing tables.
  -- This lets us define both fn() and fn.subfn()
  -- over a proper closure. 
  -- All lookups on the "function" will return nil. 
  local meta = {}
  meta["__index"] = function() 
    error "table is behaving as a function and may not be indexed"
  end
  meta["__newindex"] = function() return nil end
  return meta
end

local function dive(tree)
  -- quick and dirty recurser. blows up the stack if 
  -- there are any cyclic references. 
  -- internal sanity check.
  for k,v in pairs(tree) do 
    if type(v) == "table" then
      dive(v)
    end
  end
  return nil, "contains no cyclic references"
end
---[[ Unused
local function index_print(index)
  for i,v in pairs(index) do
    print("i: ",i," v: ", v)
  end
end

local function byte_string(str) 
  -- Converts a string to an array of bytes.
  local bytes = {}
  for i = 1, string.len(str) do
    bytes[i] = string.byte(str,i)
  end
  return bytes
end
--]]

return {F = F,
        dive = dive}
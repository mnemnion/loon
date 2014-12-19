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
  meta["__index"] = function() return nil end
  meta["__newindex"] = function() return nil end
  return meta
end

 closed = function ()
  local private = "private dancer"
  local subprivate = "privy secretary"
  local ndx = {}
  local meta = F()
  meta["__call"] = function() print(private) end
  ndx.subcall = function() print(subprivate) end
  setmetatable (ndx,meta)
  return ndx
end

closed = closed()
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

return {F = F}
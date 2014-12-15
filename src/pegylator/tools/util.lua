local util = {}

local ansi = require "ansi"
local cyan = tostring(ansi.cyan)
local magenta = tostring(ansi.magenta)
local clear = tostring(ansi.clear)
local green = tostring(ansi.green)

local function write(...) return io.write(...) end

local function d_ast( node, prefix, nums)
  -- I need a non crappy one of these badly.
  if type( node ) == "table" then
    write(prefix )
    --write("{")
    if next( node ) ~= nil then
      if node.parent then write("p: ",node.parent, "  ") end
      if type( node.id ) == "string" and
         type( node.pos ) == "number" then
        write(magenta, node.id, clear, 
               "  ", cyan, tostring( node.pos ), clear)
      end
      for k,v in pairs( node ) do
        if k ~= "id" and k ~= "pos" and k ~= "parent" and k ~= "index" then
          write("\n", prefix)
          if nums then write("  ", tostring( k ), " = " ) end
          d_ast( v, prefix.." ", nums )
        end
      end
    end
    --write( " }" )
  else if (type(node) == "number") then -- todo: cover all type cases
      write(prefix,"*", tostring(node), "*")
    else
      write(prefix, "\"", green,  tostring( node ), clear, "\"")
    end
  end
end

function index_print(index)
  for i,v in pairs(index) do
    print("i: ",i," v: ", v)
  end
end

function byte_string(str) 
  -- Converts a string to an array of bytes.
  local bytes = {}
  for i = 1, string.len(str) do
    bytes[i] = string.byte(str,i)
  end
  return bytes
end

function util.dump_ast(node, prefix, nums)
  d_ast(node," ", nums)
  write("\n")
end

return util
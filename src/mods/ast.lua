--AST tools
local ansi = require "ansi"
local cyan = tostring(ansi.cyan)
local magenta = tostring(ansi.magenta)
local clear = tostring(ansi.clear)
local green = tostring(ansi.green)

local function select_rule (id, ast) 
-- select_rule (<String>, <Node>) -> <Index <Node>>
	local vec = {}
	local meta = {}
	if ast.isnode then
		meta = getmetatable(ast)
	else
		error "second argument must be of type <Node>" 
	end
	local function selector(id,ast)
		if ast.isnode then
			if ast.id == id then
				vec[#vec+1] = ast  
			end
		end
		for _, v in pairs(ast) do
			if type(v) == "table" and v.isnode then
				selector(id,v)
			end
		end
	end
	selector(id,ast)
	setmetatable(vec,meta)
	return vec
end

local function write(...) return io.write(...) end

local function d_ast( node, prefix, nums)
  -- I need a non crappy one of these badly.
  if type( node ) == "table" then
    write(prefix )
    --write("{")
    if next( node ) ~= nil then
      if node.parent then write("p: ",node.parent, "  ") end
      if node.isnode then
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
      write(prefix, green, "\"", clear , tostring( node ), green, "\"", clear)
    end
  end
end

function dump_ast(node, prefix, nums)
  d_ast(node," ", nums)
  write("\n")
end


return {
	select_rule = select_rule ,
	pr = dump_ast
}
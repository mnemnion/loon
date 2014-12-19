--AST tools
local lpeg = require "lpeg"
local ansi = require "ansi"
local walker = require "backwalk"
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
      
      if node.isnode then
      	write('\n',prefix)
      	if node.parent then 
      		write("p: ",node.parent().id, "  ") end
        write(magenta, node.id, clear, 
               "  ", cyan, tostring( node.pos ), clear)
      end
      for k,v in pairs( node ) do
        if k ~= "id" and k ~= "pos" and k ~= "parent" and k ~= "index" then
          write()
          if nums then write("  ", tostring( k ), " = " ) end
          d_ast( v, prefix.."  ", nums )
        end
      end
    end
    --write( " }" )
  else if (type(node) == "number") then -- todo: cover all type cases
     -- write(prefix,"*", tostring(node), "*")
    else
      write("\n",prefix, green, "\"", clear , tostring( node ), green, "\"", clear)
    end
  end
end

local function dump_ast(node, prefix, nums)
  d_ast(node,"", nums)
  write("\n")
end

local function parse(grammar, string)
	local ast = lpeg.match(grammar,string)
	return walker.walk_ast(ast)
end

local function dive(ast)
	-- quick and dirty recurser. blows up the stack if 
	-- there are any cyclic references. 
	-- internal sanity check.
	for k,v in pairs(ast) do 
		if type(v) == "table" then
			dive(v)
		end
	end
	return nil, "contains no cyclic references"
end

return {
	select_rule = select_rule ,
	pr = dump_ast,
	copy = clone_ast,
	walk = walker.walk_ast,
	parse = parse,
	dive = dive
}
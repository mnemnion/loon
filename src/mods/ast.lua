--AST tools
local lpeg = require "lpeg"
local ansi = require "ansi"
local walker = require "backwalk"
local cyan = tostring(ansi.cyan)
local blue = tostring(ansi.blue)
local magenta = tostring(ansi.magenta)
local clear = tostring(ansi.clear)
local green = tostring(ansi.green)
local red = tostring(ansi.red)

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

local function node_pr(node,_,depth)
	local prefix = ("  "):rep(depth-1)
	io.write(prefix,blue,node.parent().id," ",
			 magenta,node.id," ",
			 cyan,node.pos,clear,"\n")
	for i,v in ipairs(node) do
		if type(v) == "string" then
			io.write (prefix,green,'"',clear,v,green,'"',clear,"\n")
		end
	end
end

local function root(node)
	if node.parent() == node then
		return node
	else 
		return root(node.parent()) 
	end
end

local function ast_range(node)
	local root = node:root()
	local first, last, _ =  root.index(node)
	return root.index, first, last
end

local function ast_pr(ast)
	-- now we can print an AST.
	local ndx = ast.index
	for i= 1,ndx.len() do 
		node_pr(ndx(i))
	end
end

local function parse(grammar, string)
	local ast = lpeg.match(grammar,string)
	return walker.walk_ast(ast)
end

return {
	select_rule = select_rule ,
	pr = ast_pr,
	root = root,
	range= ast_range,
	copy = clone_ast,
	walk = walker.walk_ast,
	parse = parse
}
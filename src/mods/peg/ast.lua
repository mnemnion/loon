--AST tools
local lpeg = require "lpeg"
local ansi = require "ansi"
local walker = require "peg/backwalk"
local cyan = tostring(ansi.cyan)
local blue = tostring(ansi.blue)
local magenta = tostring(ansi.magenta)
local clear = tostring(ansi.clear)
local green = tostring(ansi.green)
local red = tostring(ansi.red)

local copy_contents = { id = true,
					   pos = true, -- remove
					   span = true
					   }

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

local function node_pr(node,_,depth)
	local prefix = ("  "):rep(depth-1)
	local phrase = prefix..
		     --blue,node.parent().id," ",
			 magenta..node.id.." "..
			 cyan..node.pos..clear.."\n"
	for i,v in ipairs(node) do
		if type(v) == "string" then
			phrase = phrase..prefix..green..'"'..clear..v..green..'"'..clear.."\n"
		end
	end
	return phrase
end

local function ast_tostring(ast)
	-- now we can print an AST.
	local ndx, first, last = ast:range()
	local str = ""
	for i= first,last do 
		str = str..node_pr(ndx(i))
	end
	return str
end

local function ast_pr(ast)
	io.write(ast_tostring(ast))
end

local function deepcopy(orig) -- from luafun
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' and orig.isnode then
        copy = setmetatable({},getmetatable(orig))
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
    elseif orig_type ~= "function" then
            copy = orig
    end
    return copy
end

local function ast_copy(ast)
	local clone = deepcopy(ast)
	return walker.walk_ast(clone)
end

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


local function parse(grammar, string)
	local ast = lpeg.match(grammar,string)
	return walker.walk_ast(ast)
end

return {
	select_rule = select_rule ,
	tostring = ast_tostring,
	pr = ast_pr,
	root = root,
	range= ast_range,
	copy = ast_copy,
	walk = walker.walk_ast,
	parse = parse
}
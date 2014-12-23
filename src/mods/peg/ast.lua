--AST tools
local lpeg = require "lpeg"
local ansi = require "ansi"
local walker = require "peg/backwalk"
local Forest = require "peg/forest"
local cyan = tostring(ansi.cyan)
local blue = tostring(ansi.blue)
local magenta = tostring(ansi.magenta)
local clear = tostring(ansi.clear)
local green = tostring(ansi.green)
local red = tostring(ansi.red)
local grey = tostring(ansi.dim)..tostring(ansi.white)

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

local c = { id = magenta,
			num = grey,
			str = red,
			span = clear,}

local function node_pr(node, depth, str)
	if node.isnode then
		local prefix = ("  "):rep(depth-1)
		local phrase = prefix..
			     --blue,node.parent().id," ",
				 c.id..node.id.." "..
				 c.num..node.first..
				 "-"..c.num..node.last..clear.."\n"

		for i,v in ipairs(node) do
			if type(v) == "string" then
				phrase = phrase..prefix.."  "..'"'..c.str..v..clear..'"'.."\n"
			elseif type(v) == "table" and v.span then
				phrase = phrase..prefix..c.span..str:sub(v[1],v[2])..clear.."\n"
			end
		end
		return phrase
	end
end

local function ast_tostring(ast)
	-- now we can print an AST.
	local ndx, first, last = ast:range()
	local og = ndx(1).str
	local str = ""
	for i= first,last do 
		local node,_,depth = ndx(i)
		str = str..node_pr(node,depth,og)
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

local function select_rule(ast,id)
	local catch = setmetatable({},Forest)
	if type(ast) == "table" and ast.isnode then
		local ndx, first, last = ast:range()
		--print("Node: ", ast.id, "first ", first, "last ",last)
		for i = first, last do
	--		print (ndx[i].id)
			if ndx[i].id == id then
				catch[#catch+1] = ndx[i]
			end
		end
	elseif type(ast) == "table" and ast.isforest then
		for i = 1, #ast do
			--print "forest"
			local nursery = select_rule(ast[i],id)
			for j = 1, #nursery do
			--	print ("nursery: ", nursery[1].id)
				catch[#catch+1] = nursery[1]
			end
		end
	end
	return catch
end

local function select_with(ast,id)
	local catch = setmetatable({},Forest)
	if type(ast) == "table" and ast.isnode then
		local ndx, first, last = ast:range()
		for i = first, last do
			if ndx[i].id == id then
				catch[#catch+1] = ndx[first]
				break
			end
		end
	elseif type(ast) == "table" and ast.isforest then
			for i = 1, #ast do
			local nursery = select_with(ast[i],id)
			for j = 1, #nursery do
				catch[#catch+1] = nursery[1]
			end
		end
	end
	return catch
end

Forest["select"] = select_rule
Forest["with"]   = select_with

local function parse(grammar, str)
	local ast = lpeg.match(grammar,str)
	ast.str = str
	return walker.walk_ast(ast)
end

return {
	select = select_rule ,
	with = select_with ,
	tostring = ast_tostring,
	pr = ast_pr,
	root = root,
	range= ast_range,
	copy = ast_copy,
	walk = walker.walk_ast,
	parse = parse
}
--AST tools
local lpeg = require "lpeg"
local clu = require "clu/prelude"
local ansi = clu.ansi
local walker = require "peg/walker"
local Forest = require "peg/forest"
local cyan = tostring(ansi.cyan)
local blue = tostring(ansi.blue)
local magenta = tostring(ansi.magenta)
local clear = tostring(ansi.clear)
local green = tostring(ansi.green)
local red = tostring(ansi.red)
local grey = tostring(ansi.dim)..tostring(ansi.white)

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
			range = grey,
			str = red,
			num = blue,
			span = clear,
			val = green,}

local function node_pr(node, depth, str)
	if node.isnode then
		local phrase = ""
		local prefix = ("  "):rep(depth-1)
		if node.isrecursive then 
			phrase = red.."*"..prefix:sub(1,-2)..clear

		else 
			phrase = prefix
		end
		if node.last then 
			phrase = phrase..
			-- blue,node.parent().id," ",
			c.id..node.id.." "..
			c.range..node.first..
			"-"..c.range..node.last..clear.."\n"
		end
		if node.val then
			 phrase = phrase..prefix..'"'..c.val..node.val..clear..'"'.."\n"
		end 
		if node.tok then
			phrase = phrase..prefix..tostring(node.tok)
		end
		for i,v in ipairs(node) do
	--[[ fixing this is off the critical path.
			if type(v) == "string" then
				phrase = phrase..prefix..c.num..i..clear.." "..'"'..c.str..v..clear..'"'.."\n"
			end
				--]]
			if type(v) == "table" and v.span and not node.val then
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
	local phrase = ""
	for i= first,last do 
		local node,_,depth = ndx(i)
		phrase = phrase..node_pr(node,depth,og)
	end
	return phrase
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

local forest = {}

local function select_node (ast,pred)
	local catch = setmetatable({},Forest)
	local ndx, first, last = ast:range()
	if type(pred) == "string" then
		for i = first, last do
			if ndx[i].id == pred then
				catch[#catch+1] = ndx[i]
			end
		end
	elseif type(pred) == "function" then
		for i = first, last do
			if pred(ndx[i]) then
				catch[#catch+1] = ndx[i]
			end
		end
	end
	return catch
end

function forest.select(ast,id)
	local catch = setmetatable({},Forest)
	for i = 1, #ast do
		local nursery = select_node(ast[i],id)
		for j = 1, #nursery do
			catch[#catch+1] = nursery[1]
		end
	end
	return catch 
end

local function select_rule(ast,id)
	local catch = {}
	if type(ast) == "table" and ast.isnode then
		catch = select_node(ast,id)
	elseif type(ast) == "table" and ast.isforest then
		catch = forest.select(ast,id)
	else error "select: First argument must be of type Node or Forest" end
	return catch
end

local function select_with_node(ast,pred)
	local catch = setmetatable({},Forest)
	local ndx, first, last = ast:range()
	if type(pred) == "string" then
		for i = first, last do
			if ndx[i].id == pred then
				catch[#catch+1] = ndx[first]
			end
		end
	elseif type(pred) == "function" then
		for i = first, last do
			if pred(ndx[i]) then
				catch[#catch+1] = ndx[first]
			end
		end
	end
	return catch
end

function forest.select_with (ast,id)
	local catch = setmetatable({},Forest)
	for i = 1, #ast do
		local nursery = select_with_node(ast[i],id)
		for j = 1, #nursery do
			catch[#catch+1] = nursery[1]
		end
	end
	return catch
end 

local function select_with(ast,id)
	local catch = {}
	if type(ast) == "table" and ast.isnode then
		catch = select_with_node(ast,id)
	elseif type(ast) == "table" and ast.isforest then
		catch = forest.select_with(ast,id)
	else
		error "with: First argument must be of type Node or Forest" 
	end
	return catch
end

-- add: select_without

local function pick_tostring(table)
	local phrase = ""
	for i,v in ipairs(table) do 
		phrase = phrase..tostring(v)
	end
	return phrase 
end

local function toks_tostring(table)
	local phrase = "["
	for i,v in ipairs(table) do
		phrase = phrase..
	             grey.."'"..clear..
	             tostring(v):gsub("\n",blue.."\\n"..clear)..
	             grey.."'"..red..","..clear
	end
	return phrase.."]".."\n"
end

local function tokenize(ast)
	if ast.tok then return ast.tok end
	local ndx, first, last = ast:range()
	local tokens = setmetatable({},{__tostring = toks_tostring})
	for i = first, last do 	-- reap leaves
		if ndx[i].val then
			tokens[#tokens+1] = ndx[i].val
			ndx[i].val = nil
		elseif ndx[i].tok then
			for j = 1, #ndx[i].tok do
				tokens[#tokens+1] = ndx[i].tok[j]
			end
			ndx[i].tok = nil
		end
	end
	for i,v in ipairs(ast) do -- destroy children
		ast[i] = nil 
	end
	ast.tok = tokens
	walker.walk_ast(ast:root()) -- this should be triggered by 
								-- next index operation
	return tokens
end

local function flatten(ast)
	local phrase = ""
	ast:tokens()
	if ast.tok then
		for i = 1, #ast.tok do
			phrase = phrase..ast.tok[i]
		end
	else error "auto-tokenizing has failed"
	end
	ast.flat = phrase
	return phrase
end

function forest.pick(ast,id)
-- similar to select, :pick returns a bare vector of Forests,
-- rather than a flattened Forest. 
	local catch = setmetatable({},{["__tostring"] = pick_tostring})
	for i = 1, #ast do
		catch[#catch+1] = select_node(ast[i],id)
	end
	return catch 
end

Forest["select"] = select_rule
Forest["with"]   = forest.select_with
Forest["pick"]   = forest.pick

local function parse(grammar, str)
	if grammar == nil then
		error "grammar failed to generate"
	end
	local ast = lpeg.match(grammar,str)
	if type(ast) == "table" then
		ast.str = str
		ast.grammar = grammar
		return walker.walk_ast(ast)
	else
		error "lpeg did not match grammar"
	end
end

return {
	select = select_rule ,
	__select_with_node = select_with_node,
	__select_node = select_node, 
	with = select_with ,
	tostring = ast_tostring,
	pr = ast_pr,
	lift = walker.lift,
	root = root,
	tokenize = tokenize,
	flatten = flatten,
	range= ast_range,
	copy = ast_copy,
	walk = walker.walk_ast,
	parse = parse
}
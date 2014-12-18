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

local function rule_print (val, rule)
	if type(rule) == "table" then
		io.write(rule[1],val,rule[2],clear)
		--print(rule[1],val,rule[2],clear)
	elseif type(rule) == "function" then
		print"functioncall"
		print(rule(val), clear)
		--io.write(rule(val),clear)
	else error "rule must be a table or function"
	end
end


local function table_pr(table, t_rules)
	--print (table["isnode"])
	--print (t_rules)
	local predicated = false
	for predicate, fn in pairs(t_rules) do
	--print ("pred: ", predicate, green, table[predicate],clear)
		if type (table[predicate]) == "boolean" then
			if table[predicate] then 
				predicated = true
				rule_print(table,fn)
			end
		elseif type (predicate) == "function" then
			if predicate(table) then
				rule_print(table, fn)
			end
		end
		--]]
		if not predicated then
			tostring(table)
		end
	end
end

local function resolve_print (k,v,rules) 
	if type(v) == "number" then
		rule_print(v, rules["number"])
	elseif type(v) == "string" then
		rule_print(v,rules["string"])
	elseif type(v) == "table" then
		table_pr(v,rules["table"])
	end
	io.write("\n")
end

local function ast_pr (ast, prefix, rules)
	for k,v in pairs(ast) do
		resolve_print(k,v, rules)
		if type(v) == "table" then
			if v.isnode then
				ast_pr(v, prefix, rules)
			end
		end
	end
end

local function node_pr(ast)
	return "id: "..ast.id.." pos: "..ast.pos.." "
end

local default_rules = {
	number = {cyan, ""},
	string = { '"'..green, clear..'"'},
	table  = {
		isnode  = node_pr
	},
}

local function pr(node, prefix, rules)
  if rules == nil then
	 rules = default_rules
  end
  ast_pr(node," ", rules)
  io.write("\n")
end


return {
	select_rule = select_rule ,
	pr = pr
}
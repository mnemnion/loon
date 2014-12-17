--AST tools

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

local function resolve_print (k,v) 
	print (k,v)
end

local function ast_pr (ast, prefix, rules)
	for k,v in pairs(ast) do
		resolve_print(k,v)
		if type(v) == "table" then
			if v.isnode then
				ast_pr(v)
			end
		end
	end
end

local default_rules = {}

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
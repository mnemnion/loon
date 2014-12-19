-- A rule-based table printer
-- to write when I have more time. 


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
				predicated = true
				rule_print(table, fn)
			end
		end
		--]]
		if not predicated then
			tostring(table)
		end
	end
end

local function ast_pr (ast, prefix, rules)
	table_pr(ast,rules["table"])
	for k,v in pairs(ast) do
		if type(v) == "table" then
			if v.isnode then
				ast_pr(v, prefix.."  ", rules)
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
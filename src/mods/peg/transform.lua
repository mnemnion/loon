--- Transform Module
-- @module transform

local t = {}

---Transforms rules into LPEG form. 
-- @param ast root Node of a PEGylated grammar. 
-- @return a collection containing the transfomrmed strings.
function t.transform(ast)
	local function isrecursive(node)
		if node.isrecursive then
			return true
		else
			return false
		end
	end
	local function notrecursive(node)
		if node.id == "rule" and not node.isrecursive then
			return true
		else
			return false
		end
	end
	local cursive, regular = ast:select(isrecursive), ast:select(notrecursive)
	transform_cursives(cursive)
	transform_regulars(regular)
	return ast
end

function t.transform_atoms(ast)
	local function symbolize(str)
		return str:gsub("-","_")
	end
	local function lhs_pred(ast)
		if ast.id == "lhs" and ast[1].id ~= "hidden_pattern" then
			return true
		elseif ast.id == "hidden_pattern" then
			return true
		else
			return false
		end 
	end
	local rhs = ast:select"atom"
	local lhs = ast:select(lhs_pred)
	for i = 1, #rhs do
		rhs[i].val = symbolize(rhs[i].val)
	end
	for i = 1, #lhs do
		lhs[i].val = symbolize(lhs[i].val)
	end
end
return t

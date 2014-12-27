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
	print (cursive)
	print (regular)
	return ast
end

return t
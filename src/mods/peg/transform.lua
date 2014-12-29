--- Transform Module
-- @module transform

local t = {}


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

local function transform_cursives(forest)
	local cursors = forest[1]:root().cursors
	print (cursors)
	local atoms = forest:select"atom"
	for i = 1, #atoms do
		if cursors[atoms[i].val] then 
			print ("Transforming: ", atoms[i].val)
			atoms[i].val = 'V"'..atoms[i].val..'"'
		end
	end
end

local function transform_regulars(forest)
end

---Transforms rules into LPEG form. 
-- @param ast root Node of a PEGylated grammar. 
-- @return a collection containing the transformed strings.
function t.transform(ast)
	local cursive, regular = ast:select(isrecursive), ast:select(notrecursive)
	transform_cursives(ast)
	transform_regulars(regular)
	return ast
end

return t

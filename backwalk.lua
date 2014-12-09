-- This walks an AST, making back references to the parent node.
-- 
-- This shouldn't be a separate step, but that's premature optimization.

-- This is conceptually simple:

-- Take the tree, add a parent reference  that points to itself.

-- Take all child members, if they're nodes, call the function recursively with the parent and nodes as argument.

-- This is the usual recursive function wrapped in pre and post matter. 

local function isnode(maybetable)
	if type(maybetable) == "table" then
		return true
	else 
		return false
	end
end

local function walk_ast (ast, parent)
	ast["parent"] = parent 
	for _, v in pairs(ast) do
		if isnode(maybetable) then
			walk_ast(v,ast)
		end
	end
end

function walkast(ast) walk_ast(ast, ast) end -- I am my own grandpa
-- This walks an AST, making back references to the parent node.
-- 
-- This shouldn't be a separate step, but that's premature optimization.

-- This is conceptually simple:

-- Take the tree, add a parent reference  that points to itself.

-- Take all child members, if they're nodes, call the function recursively with the parent and nodes as argument.

-- This is the usual recursive function wrapped in pre and post matter. 

local function isnode(maybetable)
	-- this should be a metatable lookup
	-- the metatable should be attached in the parsing pass
	if (type(maybetable) == "table" ) then
--		print ("yep "..maybetable.id)
		return true
	else 
--		print "nope"
		return false
	end
end

local function walk_ast (ast, parent)
	if isnode(ast) then
		--index[#index+1] = ast
		for _, v in pairs(ast) do
			if isnode(ast) then
				 walk_ast(v,ast)
			end
		end
		ast["parent"] = parent 
    end
end

function walkast(ast) 
	return walk_ast(ast, ast, {})
end 
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

function walk_ast (ast)
	local index = {}
	local function walker (ast, parent)
		if isnode(ast) then
			for _, v in pairs(ast) do
				if isnode(ast) then
					 walker(v,ast)
				end
			end
			ast["parent"] = parent
	    end
		index[#index+1] = ast 
--		print("index length is: ", #index)
	end
	walker(ast,ast)
	ast.index = index
--	print("index length is now: ", #index)
end
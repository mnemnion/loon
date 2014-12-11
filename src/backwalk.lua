-- This walks an AST, making back references to the parent node.
-- 
-- This shouldn't be a separate step, but that's premature optimization.

-- This is conceptually simple:

-- Take the tree, add a parent reference  that points to itself.

-- Take all child members, if they're nodes, call the function recursively with the parent and nodes as argument.

-- This is the usual recursive function wrapped in pre and post matter. 

-- Now that I've added an index, I'm considering a cleaner parent implementation, where the parent is simply a number
-- which must be looked up against the index. To completely eliminate back references, the index might be a closure 
-- which returns the table given the argument, thus `index(i)` rather than `index[i]`. 
--
-- It would be useful for our decorated AST to have no cycles, since we're guaranteed to traverse it in linear time 
-- with no cycle checking. 

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
	local ndx = function(ordinal)
		return index[ordinal]
	end
	local function add_to_index(node)
	end

	local function walker (ast, parent)
		index[#index+1] = ast 
		if isnode(ast) then
			for _, v in pairs(ast) do
				if isnode(ast) then
					 walker(v,ast)
				end
			end
			ast["parent"] = #index
	    end
--		print("index length is: ", #index)
	end
	walker(ast,ast)
	ast.index = ndx
--	print("index length is now: ", #index)
end
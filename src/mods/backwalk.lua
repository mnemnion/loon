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
local backwalk = {}

local function make_backref (ast)
	--returns a function that returns the AST. 
	local ref = ast
	return function() return ref end
end


function backwalk.walk_ast (ast)
	local index = {}
	local ndx = function(ordinal)
		return index[ordinal]
	end

	local function walker (ast, parent)
		if ast.isnode then
			index[#index+1] = ast 
			for _, v in pairs(ast) do
				if type(v) == "table" and v.isnode then
					 walker(v,ast)
				end
			end
			ast["parent_index"] = #index
			ast.parent = make_backref(parent)
	    end
--		print("index length is: ", #index)
	end
	walker(ast,ast)
	ast.index = ndx
--	print("index length is now: ", #index)
end

return backwalk
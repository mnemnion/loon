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

local util = require "util"
local backwalk = {}

local function make_backref (ast)
	return function() return ast end
end


local function index_gen ()
	local index = {}
	local closed = {}
	local depth = {}
	local meta  = util.F()
	local ndx = function(_, ordinal)
		return index[ordinal], depth[ordinal]
	end
	closed.set = function(ordinal, table, deep)
		index[ordinal] = table
		depth[ordinal] = deep
	end
	meta.__call = ndx
	setmetatable(closed,meta)
	return closed
end

ndx = index_gen()

function backwalk.walk_ast (ast)
	local index = {}
	local depth = {}
	local ndx = function(_, ordinal)
		return index[ordinal], depth[ordinal]
	end

	function index.setdepth(ordinal, value)
		table.insert(depth,ordinal,value)
	end 

	setmetatable(index,{__call = ndx})
	local function walker (ast, parent, deep)
		depth[#depth+1] = deep
		deep = deep+1
		if ast.isnode then
			index[#index+1] = ast 
			for _, v in pairs(ast) do
				if type(v) == "table" and v.isnode then
					 walker(v,ast, deep)
				end
			end
			ast.parent = make_backref(parent)
	    end
--		print("index length is: ", #index)
	end
	walker(ast,ast,0)
	ast.index = index
--	print("index length is now: ", #index)
	return ast 
end

return backwalk
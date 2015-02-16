-- Rule Sorting module.
local clu = require "clu/prelude"

Set = require "set" -- todo: remove penlight dependency


local sort = {}

---This step is done first, so that the contents of the cursor
-- set obtain the correct values.
local function transform_atoms(ast)
-- Makes sensible lua symbols  
	local function symbolize(str)
		return str:gsub("-","_")
	end
	local function lhs_pred(ast)
		-- note: this function is brittle. If it breaks again
		-- find a better way.
		if ast.id == "pattern" and not ast[1].val then
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

local function rule_tables(ast)
	local lhs = ast:select"pattern"
	local rhs = ast:select"rhs":pick"atom" 
	local ndx = {}
	for i,v in ipairs(lhs) do
		ndx[i] = {}
		ndx[i].lhs = lhs[i]
		if v.val then
			ndx[i].val = v.val  -- lookup ast, get index.
		elseif v[1].id == "hidden_pattern" then
				ndx[i].val = v[1].val
		end
		ndx[ndx[i].val] = lhs[i] 
		local rights = Set{}
		for j,v in ipairs(rhs[i]) do
			rights  = rights + Set{v.val}
		end
		ndx[i].rhs = rights
	end
	ast:root().rule_table = ndx
	return ndx
end

local function detect_recursion(ndx, i)
	local match = ndx[i].val
	for j = 1,#ndx do
		if ndx[i].rhs[ndx[j].val] then
			if ndx[j].rhs[match] then
				ndx[i].rhs = ndx[i].rhs + ndx[j].rhs
			end
		end
	end
end

function sort.sort (node)
-- Divides rules into Regular and Recursive, decorating accordingly on LHS.
	transform_atoms(node)
	local ndx = rule_tables(node)
	for i,v in ipairs(ndx) do 
		detect_recursion(ndx,i)
	end
	local cursors = Set{}
	for i,v in ipairs(ndx) do
		if ndx[i].rhs[ndx[i].val] then
			ndx[i].lhs.parent().isrecursive = true
			cursors = cursors + Set{ndx[i].val}
		end
	end
	local old_cursors = 0
	while (old_cursors < Set.len(cursors)) do
		old_cursors = Set.len(cursors)
		for i,v in ipairs(ndx) do
			for val, _ in pairs(ndx[i].rhs) do
				if cursors[val] then
					if not (cursors[ndx[i].val]) then
						ndx[i].lhs.parent().isrecursive = true
						cursors = cursors + Set{ndx[i].val}
					end
				end
			end
		end
	end
	node:root().cursors = cursors
	--return ndx
end

return sort
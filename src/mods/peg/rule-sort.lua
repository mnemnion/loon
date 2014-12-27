-- Rule Sorting module.

local ansi = require "ansi"

Set = require "set" -- remove this dependency

local red = tostring(ansi.red)
local white = tostring(ansi.white)
local clear = tostring(ansi.clear)

local sort = {}

local function rule_tables(node)
	local lhs = node:select"lhs"
	local rhs = node:select"rhs":pick"atom" 
	local ndx = {}
	for i,v in ipairs(lhs) do
		ndx[i] = {}
		ndx[i].lhs = lhs[i]
		if v.val then
			ndx[i].val = v.val  -- lookup Node, get index.
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
	
	return ndx
end


local function detect_recursion(ndx, i)
	local match = ndx[i].val
--	print ("for rule ", match)
	for j = 1,#ndx do
		if ndx[i].rhs[ndx[j].val] then
--			print ("in set:", ndx[j].val, " = ", ndx[j].rhs)
		--	print ("looking for", match)
			if ndx[j].rhs[match] then
--				print ("caught ", match," in ", ndx[j].val)
				ndx[i].rhs = ndx[i].rhs + ndx[j].rhs
--				print (ndx[i].rhs)
			end
		end
	end
end


function sort.sort (node)
-- Divides rules into Regular and Recursive, decorating accordingly on LHS.

	local ndx = rule_tables(node)
	for i,v in ipairs(ndx) do 
		detect_recursion(ndx,i)
	end
	local cursors = Set{}
	for i,v in ipairs(ndx) do
	--	print(ndx[i].val, "=", ndx[i].rhs)
		if ndx[i].rhs[ndx[i].val] then
			print (ndx[i].val," is RECURSIVE!")
			ndx[i].lhs.parent().isrecursive = true
			cursors = cursors + Set{ndx[i].val}
		end
	end
	print ("CURSORS: ", cursors)
	local old_cursors = 0
	while (old_cursors < Set.len(cursors)) do
		print "IN WHILE"
		old_cursors = Set.len(cursors)
		for i,v in ipairs(ndx) do
			for val, _ in pairs(ndx[i].rhs) do
		--		print("for ",val)
				if cursors[val] then
					if not (cursors[ndx[i].val]) then
						print(ndx[i].val, "IS ALSO RECURSIVE!")
						ndx[i].lhs.parent().isrecursive = true
						cursors = cursors + Set{ndx[i].val}
					end
				end
			end
		end
	end
	print("final cursors: ", cursors)
	ndx.cursors = cursors
	return ndx
end

return sort
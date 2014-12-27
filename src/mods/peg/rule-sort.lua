-- Rule Sorting module.

local ansi = require "ansi"

Set = require "pl.Set" -- remove this dependency

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
	print ("for rule ", match)
	for j = 1,#ndx do
		if ndx[i].rhs[ndx[j].val] then
			print ("in set:", ndx[j].val, " = ", ndx[j].rhs)
		--	print ("looking for", match)
			if ndx[j].rhs[match] then
				print ("caught ", match," in ", ndx[j].val)
				ndx[i].rhs = ndx[i].rhs + ndx[j].rhs
--				print (ndx[i].rhs)
			end
		end
	end
	print ""
end


function sort.sort (node)
-- Divides rules into Regular and Recursive, decorating accordingly on LHS.
	local ndx = rule_tables(node)
	for i,v in ipairs(ndx) do 
		detect_recursion(ndx,i)
	end
	for i,v in ipairs(ndx) do
		print(ndx[i].val, "=", ndx[i].rhs)
		if ndx[i].rhs[ndx[i].val] then
			print "is RECURSIVE!"
			ndx[i].lhs.isrecursive = true
		end
	end
end

return sort
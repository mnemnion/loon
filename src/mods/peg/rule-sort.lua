-- Rule Sorting module.

local ansi = require "ansi"

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
				print ("Hidden Pattern",v[1].val)
				ndx[i].val = v[1].val
		end
		local rights = {}
		for j,v in ipairs(rhs[i]) do
			rights[j] = v.val
		end
		ndx[i].rhs = rights
	end
	
	return ndx
end


local function detect_recursion(ndx, i)
		
end


function sort.sort (node)
-- Divides rules into Regular and Recursive, decorating accordingly on LHS.
	local ndx = rule_tables(node)
	for i,v in ipairs(ndx) do 
		detect_recursion(ndx,i)
		print("LHS: ", ndx[i].val)
		io.write("RHS: ")
		for j,v in ipairs(ndx[i].rhs) do
			io.write(ndx[i].rhs[j]," ")
		end
		io.write "\n"
	end
end

return sort
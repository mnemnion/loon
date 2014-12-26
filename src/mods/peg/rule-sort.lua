-- Rule Sorting module.

local ansi = require "ansi"

local sort = {}

local function rule_tables(node)
-- returns two Forests with the LHS and RHS symbols indexed
	local lhs = node:select"lhs"
	local rhs = node:select"rhs":pick"atom" 
	return lhs, rhs
end


local function detect_recursion(index, lhs, rhs)
	local match = lhs[index]
	local visit, visited = {},{}
	-- lookup match on rhs
	print(rhs[index])
	for i,v in ipairs(rhs[index]) do
		if v.val == match.val then 
			print ("match detected: ", v.id, " matches", match.val)
			match.isrecursive = true
			return
		else 
			visit[i] = v.val
		end
	end
	for i,v in ipairs(visit) do

	end
	print "no match"
end


function sort.sort (node)
-- Divides rules into Regular and Recursive, decorating accordingly on LHS.
	local lhs, rhs = rule_tables(node)
	for i,v in ipairs(lhs) do 
		detect_recursion(i,lhs,rhs)
		print("LHS:", lhs[i])
		print("RHS:", rhs[i],"\n")
	end
end

return sort
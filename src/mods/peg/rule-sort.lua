-- Rule Sorting module.

local ansi = require "ansi"

local red = tostring(ansi.red)
local white = tostring(ansi.white)
local clear = tostring(ansi.clear)

local sort = {}

local function rule_tables(node)
-- returns two Forests with the LHS and RHS symbols indexed
	local lhs = node:select"lhs"
	for i,v in ipairs(lhs) do
		lhs[v.val] = i -- lookup Node, get index.
	end
	local rhs = node:select"rhs":pick"atom" 
	return lhs, rhs
end


local function detect_recursion(index, lhs, rhs)
	local match = lhs[index]
	local visit, visited = {},{}
	local function find_match(match,visit,lhs, rhs)
		print ("Matching ", white, match.val, clear)
		print ("Visitor: ", red, lhs[lhs[visit]].val, clear)
		for i,v in ipairs(rhs[lhs[visit]]) do
			print ("     visiting: ", red, v.val, clear)
			if match.val == v.val or lhs[lhs[v.val]].isrecursive then
				print (red, "MATCHED", clear)
				match.isrecursive = true
			end
		end
	end
	-- lookup match on rhs
	--print(rhs[index])
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
		local matched = find_match(match, v, lhs, rhs)
		print ("Matched: ", matched)
	end
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
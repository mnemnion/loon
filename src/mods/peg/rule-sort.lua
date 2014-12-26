-- Rule Sorting module.

local ansi = require "ansi"

local sort = {}

local function rule_tables(node)
-- returns two Forests with the LHS and RHS symbols indexed
	local lhs = node:select"lhs"
	for i,v in ipairs(lhs) do
		lhs[v.val] = lhs[i] -- lookup Node, get string of rule.
	end
	local rhs = node:select"rhs":pick"atom" 
	return lhs, rhs
end


local function detect_recursion(index, lhs, rhs)
	local match = lhs[index]
	local visit, visited = {},{}
	local function find_match(match,visit,lhs, rhs)
		print("Matching: ", match, "visiting: ", visit)
		for i = 1, #lhs do
			if lhs[i].val == visit then
				for i,v in ipairs(rhs[i]) do
					if match == v.val or lhs[v.val].isrecursive then
						print("match inside loop:", v.val, "r? ", lhs[v.val].isrecursive )
						return true 
					end
				end
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
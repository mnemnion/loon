-- Rule Sorting module.

local ansi = require "ansi"

Set = require "set" -- todo: remove penlight dependency

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
	ndx.cursors = cursors
	return ndx
end

return sort
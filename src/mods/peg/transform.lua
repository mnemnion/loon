--- Transform Module
-- @module transform

local sort = require "peg/rule-sort"


local t = {}


local function isrecursive(node)
	if node.isrecursive then
		return true
	else
		return false
	end
end

local function notrecursive(node)
	if node.id == "rule" and not node.isrecursive then
		return true
	else
		return false
	end
end

function t.cursives(forest)
	local cursors = forest[1]:root().cursors
	print (cursors)
	local atoms = forest:select"atom"
	if cursors then
		for i = 1, #atoms do
			if cursors[atoms[i].val] then 
				print ("Transforming: ", atoms[i].val)
				atoms[i].val = 'V"'..atoms[i].val..'"'
			end
		end
	end
end

function t.optional(ast)
	local optionals = ast:select"optional":select"atom"
	for i = 1, #optionals do
		--print(optionals[i].val)
		optionals[i].val = optionals[i].val.."^0"
	end
end

function t.more_than_one(ast)
	local mto = ast:select"more_than_one":select"atom"
	for i = 1, #mto do
		mto[i].val = mto[i].val.."^1"
	end
end

function t.maybe(ast)
	local maybe = ast:select"maybe":select"atom"
	for i = 1, #maybe do
		maybe[i].val = maybe[i].val.."^-1"
	end
end

function t.some_number(ast)
	-- moderately complex, write later
end

function t.with_suffix(ast)

end

function t.suffix(ast)
	t.optional(ast)
	t.more_than_one(ast)
	t.maybe(ast)
	t.some_number(ast)
	t.with_suffix(ast)
end

function t.if_not_this(ast)
	local atoms = ast:select"if_not_this":select"atom"
	for i = 1, #atoms do
		atoms[i].val = "-"..atoms[i].val
	end
end

function t.if_and_this(ast)
		local atoms = ast:select"if_and_this":select"atom"
	for i = 1, #atoms do
		atoms[i].val = "#"..atoms[i].val
	end
end 

function t.prefix(ast)
	t.if_not_this(ast)
	t.if_and_this(ast)
end

function t.literal(ast)
	local lits = ast:select"literal"
	if lits then
		for i = 1, #lits do
			if lits[i].val then 
				lits[i].val = '"'..lits[i].val..'"'
			end
		end
	end
end 

function t.range(ast)
	local ranges = ast:select"range"
	for i = 1, #ranges do
		ranges[i].val = 'R"'..ranges[i].val:gsub("-","")..'"'
	end
end

function t.set(ast)
	local sets = ast:select"set"
	for i = 1, #sets do
		sets[i].val = 'S"'..sets[i].val..'"'
	end
end

function t.enclosed(ast)
	t.literal(ast)
	t.range(ast)
	t.set(ast)
end

---Transforms rules into LPEG form. 
-- @param ast root Node of a PEGylated grammar. 
-- @return a collection containing the transformed strings.
function t.transform(ast)
	sort.sort(ast)
	t.cursives(ast)
	t.prefix(ast)
	t.suffix(ast)
	t.enclosed(ast)
	return ast
end

return t

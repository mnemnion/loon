--- Generates a terminal syntax highlighter for a given grammar. 

local ansi = require "ansi"
local lpeg = require "lpeg"
local pl   = require "pl.pretty"
local util = require "util"
local tableand = util.tableand

-- default palette, probably belongs in Clu prelude? 
-- actually in ansi itself. Hmm. 
local p = {Blue = tostring(ansi.blue),
				 Red = tostring(ansi.red),
				 Clear = tostring(ansi.clear),
				 Magenta = tostring(ansi.magenta),
				 White = tostring(ansi.white)}

-- peg rules. Don't belong here, but this is the
-- only parser we have for awhile. 

local testrules = { atom = p.White, 
				   lhs  = p.Blue}


-- wraps a value in a rule, or
-- returns it if the rule is nil.
local function rulewrap(ast,rules)
	 if rules[ast.id] then
	 	return rules[ast.id]..ast.val..p.Clear
	 else
	 	return ast.val
	 end
end

--- highlights a Node.
-- uses spans and the original string.
-- anything not collected by the grammar is 
-- quoted verbatim, so if the context is Red,
-- it will be Red also. 
-- @function light
-- @param ast the parsed string
-- @param rules the rule table
-- @return highlighted string
local function light(ast, rules)
	if not rules then rules = testrules end
	local source = ast:root().str
	local queue = {}
	local phrase = ""
	local cursor = 1
	local gap = ""
	local ndx, first, last = ast:range()
	local new = true
	for i = first, last do
		local node, close, _ = ndx(i)
		if node.id and node.val then -- wrap values in rule
			if new then 
				phrase = phrase..source:sub(1,ndx[1].first-1)
				new = false
			end
			if cursor <= node.first then
				  gap = source:sub(cursor,node.first-1)
			end
			cursor = node.last+1
			phrase = phrase..gap..rulewrap(node,rules)
		else -- start regional rule
			queue[close] = node.id
			
		end
		if queue[i] then -- close regional rule
		--	print("close "..queue[i].." at "..tostring(cursor))
		end
	end
	phrase = phrase..source:sub(cursor,-1)
	--print(pl.write(queue))
	--print(phrase)
	return phrase
end

--- generates a highlighter
-- @function Highlighter
-- @param ast a parsed syntax
-- @param rules a palette
-- @return a function: λ (string|Node) -> string 
local function Highlighter(ast, rules)
	local p = rules
	local function hilight(phrase)
		local node = nil
		if type(phrase) == "string" then
			node = lpeg.match(ast.grammar,phrase)
		elseif tableand(phrase, phrase.isnode) then
			node = phrase
		end
		print(node)
	end
	return hilight
end

return {Highlighter = Highlighter,
		light = light}
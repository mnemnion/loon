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
				 Magenta = tostring(ansi.magenta)}

-- peg rules. Don't belong here, but this is the
-- only parser we have for awhile. 

local pegrules = { atom = p.Red, 
				   lhs  = p.Blue}

local testrules = { lhs = "Red",
					atom = "White"}

local function spot(color)
	return color.."◉"..p.Clear
	--return ""
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
	local source = ast:root().str
	local phrase = ""
	local cursor = 1
	local gap = ""
	local ndx, first, last = ast:range()
	local new = true
	for i = first, last do
		local node = ndx[i]
		if node.id and node.val then
			if new then 
				phrase = phrase..source:sub(1,ndx[1].first-1)
				new = false
			end
			if cursor <= node.first then
				  gap = source:sub(cursor,node.first-1)
			end
			cursor = node.last+1
			phrase = phrase..gap..node.val
		else
			-- handle span classes without values (e.g. parens)
		end
	end
	phrase = phrase..source:sub(cursor,-1)
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
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
local function light(node, rules)
	--this doesn't need a closure
	local source = node:root().str
	local phrase = ""
	local cursor = 1
	local dot = ""
	local function lighter(ast)
		-- I spent a lot of time on that index.
		-- Why not use it?
		local ndx, first, last = ast:range()
		local new = true
		for i = first, last do
			if ndx[i].id and ndx[i].val then
				if new then 
					phrase = phrase..source:sub(1,ndx[1].first-1)
					new = false
				end
				if cursor <= ndx[i].first then
					  dot = 
					  	    source:sub(cursor,ndx[i].first-1)
					  	  
				end
				cursor = ndx[i].last+1
				phrase = phrase..dot..source:sub(ndx[i].first,ndx[i].last)
			else
				-- handle span classes without values (e.g. parens)
			end
		end
		phrase = phrase..source:sub(cursor,-1)
		--print(phrase)
		return phrase
	end
	return lighter(node)
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
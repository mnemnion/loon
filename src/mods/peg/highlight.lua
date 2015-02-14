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
				 Green = tostring(ansi.green),
				 Magenta = tostring(ansi.magenta),
				 Cyan  = tostring(ansi.cyan),
				 Yellow = tostring(ansi.yellow),
				 White = tostring(ansi.white),
				 Grey  = tostring(ansi.dim..ansi.white)}

-- peg rules. Don't belong here, but this is the
-- only parser we have for awhile. 

 testrules = { atom = {p.White,p.Clear},
  			   pattern  = {p.Blue,p.Clear},
  			   optional = {p.Green,p.Clear},
  			   more_than_one = {p.Green,p.Clear},
  			   some_number = {p.Green,p.Clear},
  			   some_suffix = {p.Green,p.Clear},
  			   which_suffix = {p.Green,p.Clear},
  			   maybe = {p.Green,p.Clear},
  			   set    = {p.Yellow,p.Clear},
  			   range   = {p.Yellow,p.Clear},
  			   literal = {p.Yellow,p.Clear},
  			   PEL = {p.Grey,p.Clear},
  			   PER = {p.Grey,p.Clear},
  			   hidden_rule = {p.Cyan,p.Clear},
  			   hidden_pattern = {p.Cyan,p.Clear},
  			   hidden_match = {p.Cyan,p.Clear},
  			   repeats = {p.Red,p.Clear},
  			   comment = {p.Grey,p.Clear}}

--local testrules = { atom = {"",""}, lhs = {"",""}}


-- wraps a value in a rule, or
-- returns it if the rule is nil.
local function rulewrap_value(ast,rules)
	 if rules[ast.id] then
	 	local rule = rules[ast.id]
	 	if type (rule) == "string" then -- pre only
		 	return rule..ast.val..p.Clear
		elseif type (rule) == "table" then -- pre and post
			return rule[1]..ast.val..rule[2]
		elseif type (rule) == "function" then -- function over value
			print "function reached in rulewrap_value"
			return ""
		end
	 else
	 	return ast.val
	 end
end

local function rulewrap_open(ast,rules)
	if rules[ast.id] then
		local rule = rules[ast.id]
		if type(rule) == "string" then -- pre only
			return rule
		elseif type(rule) == "table" then -- use pre
			return rule[1]
		elseif type(rule) == "function" then -- fn over span
			print "function reached in rulewrap_start"
			return ""
		end
	else 
		return "" 
	end
end

local function rulewrap_close(ast,rules)
	if rules[ast.id] then
		local rule = rules[ast.id]
		if type(rule) == "string" then 
			return ""
		elseif type(rule) == "table" then
			return rule[2]
		elseif type(rule) == "function" then
			print "function reached in rulewrap_close"
			return ""
		end
	else
		return ""
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
		if rules[node.id] 
		  and node.val == nil then -- open regional rule
			gap = source:sub(cursor,node.first-1)
			cursor = node.first
			queue[close] = node
			phrase = phrase..gap..rulewrap_open(node,rules)
		elseif node.id and node.val then -- wrap values in rule
			if new then 
				phrase = phrase..source:sub(1,ndx[1].first-1)
				new = false
			end
			if cursor <= node.first then
				  gap = source:sub(cursor,node.first-1)
			end
			cursor = node.last+1
			phrase = phrase..gap..rulewrap_value(node,rules)
		end
		if queue[i] then -- close regional rule
			gap = source:sub(cursor,queue[i].last-1)
			cursor = queue[i].last
			phrase = phrase
			         ..rulewrap_open(queue[i],rules)
			         ..gap
			         ..rulewrap_close(queue[i],rules)
		end
	end
	phrase = phrase..source:sub(cursor,-1)
	return phrase
end

--- generates a highlighter
-- @function Highlighter
-- @param syntax a parsed syntax
-- @param rules a palette
-- @return a function: λ (string|Node) -> string 
local function Highlighter(syntax, rules)

end

return {Highlighter = Highlighter,
		light = light}
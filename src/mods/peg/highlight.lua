--- Generates a terminal syntax highlighter for a given grammar. 

local clu = require "clu/prelude"
local lpeg = require "lpeg"
local pl   = require "pl.pretty"
local util = require "util"
local tableand = util.tableand

-- peg rules. Don't belong here, but this is the
-- only parser we have for awhile.

local p = clu.env.palette

 testrules = { atom           = {"White","Clear"},
  			   pattern        = {"Blue","Clear"},
  			   optional       = {"Green","Clear"},
  			   more_than_one  = {"Green","Clear"},
  			   some_number    = {"Green","Clear"},
  			   some_suffix    = {"Green","Clear"},
  			   which_suffix   = {"Green","Clear"},
  			   maybe          = {"Green","Clear"},
  			   set            = {"Yellow","Clear"},
  			   range          = {"Yellow","Clear"},
  			   literal        = {"Yellow","Clear"},
  			   PEL            = {"Grey","Clear"},
  			   PER            = {"Grey","Clear"},
  			   hidden_rule    = {"Cyan","Clear"},
  			   hidden_pattern = {"Cyan","Clear"},
  			   hidden_match   = {"Cyan","Clear"},
  			   repeats        = {"Red","Clear"},
  			   comment        = {"Grey","Clear"}}


function makerules(rules)
 	local rule_table = {}
 	local p = nil
 		-- this logic belongs in a palette 
		-- object which may be called. 
 	if clu.env.ansi then 
		p = clu.env.palette.default
	else
		p = clu.env.palette.no_color
	end 
	for k,v in pairs(rules) do
		if type(v) == "table" then 
			rule_table[k] = { p[v[1]] , p[v[2]] }
		else -- string or function
			error "error in makerules, non-table values NYI"
		end
	end
	return rule_table
end



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
	if rules then 
		rules = makerules(rules)
	else 
		rules = makerules(testrules) 
	end

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

--- generates a highlighter from a rule table
-- @function Highlighter
-- @param parser a parser
-- @param rules a palette
-- @return a function: λ (string|Node) -> string 
local function Highlighter(parser, rules)
	local function lighter(source)
		if type(source) == "string" then
			source = ast.parse(parser,source)
		end
		return light(source, rules)
	end
	return lighter
end

return {Highlighter = Highlighter,
		light = light}
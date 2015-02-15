local epeg = require "peg/epeg"
local match = epeg.match
local strings = require "spec/strings"
local failstrings = require "spec/failstrings"
local core = require "peg/core-rules"
local say = require "say"
local ansi = require "ansi"
local pretty = require "pl.pretty"
local ast = require "peg/ast"
local clu = require "clu/prelude"
local g = require "peg/pegs/grammars"
local highlight = require "peg/highlight"
local oldass = assert
--local epnf = require "peg/epnf"
local peg = require "peg/quines/peg"
assert = oldass
verbose = nil
if verbose then clu.Meta.isverbose = true end

local function whole_match(state, args)
	local matched, hmm = match(args[2],args[1])
	if matched == nil then 
		matched = 0 
	end
	if type(matched) == "table" and matched.span == true then
		if verbose then print(pretty.write(matched)) end
	end
	if type(matched) == "number" then 
		if (#args[1]+1 == matched) then
			return true
		elseif (#args[1]+1 > matched) then
			args[2] = ansi.red..args[1]:sub(1,matched-1)..ansi.clear
			return false
		else
			args[2] = "something is badly broken"
		end
	end 
end

say:set("assertion.whole_match.positive", "Expected match on whole string:\n%s Got:\n%s")
say:set("assertion.whole_match.negative", "Expected failure of whole match")
assert:register("assertion","whole_match",whole_match,"assertion.whole_match.positive","assertion.whole_match.negative")

describe("tests over PEGylator", function()
	it("String succeeds",function ()
		for _,v in pairs(strings) do
			assert.whole_match(v,core.strings)
		end
	end)
	it("String failures", function()
		for _,v in pairs(failstrings) do
			assert.is_not.whole_match(v,core.strings)
		end
	end)
	it("int asserts", function()
		assert.equal(#("123")+1, (match(core.int,"123")))
		assert.is_not.equal(#("123#")+1,(match(core.int,("123#"))))
	end)
--[[
	it("highlighter asserts", function()
		clu.env.ansi = false
		for _,v in pairs(g) do
			print (v)
			assert.is.equal(g.str,highlight.light(ast.parse(peg.peg,v)))
		end
		clu.env.ansi = true
	end)
--]]
	it("Float asserts", function()
		pending "Add float tests"
	end)
	it("Letter asserts", function()
		pending "Add letter tests"
	end)

end)




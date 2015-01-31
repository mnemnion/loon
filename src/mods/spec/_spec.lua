local epeg = require "peg/epeg"
local match = epeg.match
local clu = require "clu/prelude"
local strings = require "peg/strings"
local failstrings = require "peg/failstrings"
local core = require "peg/core-rules"
local say = require "say"
local ansi = require "ansi"
local Node = require "peg/node"
local pretty = require "pl.pretty"
local roshambo = require "roshambo"

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
	end)
	it("Float asserts", function()
		pending "Add float tests"
	end)
	it("Letter asserts", function()
		pending "Add letter tests"
	end)
end)

describe("tests over roshambo", function()
	local rosh = roshambo { rock = "scissors",
						    scissors = "paper",
						    paper = "rock"}

	it("Roshambo on strings", function()
		if verbose then io.write("\n") end
		assert.is.equal("rock",(rosh("rock","scissors")))
		assert.is.equal("paper",(rosh("rock","paper")))
		assert.is.equal("rock",(rosh("rock","vulcan")))
		assert.is.equal("bingo",(rosh("disco","bingo")))
	end)
	it("Roshambo on tables", function()
		if verbose then io.write "\n" end
		local rock, paper, scissors = {}, {}, {}
		local rosh = roshambo { [rock] = scissors,
							    [scissors] = paper,
							    [paper] = rock }
		assert.is.equal(rock,(rosh(rock,scissors)))
		assert.is_not.equal(paper,rosh(paper,scissors))
	end)
	it("Roshambo dual-able", function()
		pending "Roshambo dual-able"
	end)
	it("Roshambo errors", function()
		assert.has.error(function () roshambo(true) end,"Roshambo must be initialized with a table")
		end)
	end)


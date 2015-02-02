local pretty = require "pl.pretty"
local roshambo = require "roshambo"
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
	it("Roshambo duel-able", function()
		pending "Roshambo duel-able"
	end)
	it("Roshambo errors", function()
		assert.has.error(function () roshambo(true) end,"Roshambo must be initialized with a table")
		end)
	end)
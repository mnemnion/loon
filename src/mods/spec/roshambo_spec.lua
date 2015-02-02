local pretty = require "pl.pretty"
local roshambo = require "roshambo"
if verbose then clu.Meta.isverbose = true end

describe("tests over roshambo", function()
	local rosh = roshambo { rock = "scissors",
						    scissors = "paper",
						    paper = "rock"}

	it("Roshambo on strings", function()
		if verbose then io.write("\n") end
		assert.is.equal("rock",(rosh("rock","scissors")))
		assert.is.equal("paper",(rosh("rock","paper")))
		assert.is.equal("rock",(rosh("rock","vulcan")))
		assert.is.equal("disco",(rosh("disco","bingo")))
		rosh:beats("bingo","disco") -- hard call
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
		local function left(_,l,r)
			return l, r
		end
		local function right(_,l,r)
			return r, l
		end
		rosh:duel_with(left)
		assert.is.equal("left",(rosh("left","right")))
		rosh:duel_with(right)
		assert.is.equal("left",(rosh("left","right"))) -- roshambo is decisive
		assert.is.equal("dexter",(rosh("sinister","dexter")))
	end)
	it("Roshambo sortable", function()
		assert.is_true(rosh:sort("rock","scissors"))
		assert.is_false(rosh:sort("rock","paper"))
		end)
	it("Roshambo errors", function()
		assert.has.error(function () roshambo(true) end,"Roshambo must be initialized with a table")
		end)
	end)
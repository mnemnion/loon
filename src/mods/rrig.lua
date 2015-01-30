pretty = require "pl.pretty"

roshambo = require "roshambo"
rosh = roshambo { rock = "scissors",
				  scissors = "paper",
				  paper = "rock"}
rosh.isverbose = true
--[[
rosh:beats("rock","scissors")
rosh:beats("scissors","paper")
rosh:beats("paper","rock")
--]]
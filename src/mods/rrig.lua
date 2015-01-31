pretty = require "pl.pretty"
util = require "util"
roshambo = require "roshambo"
rosh = roshambo { rock = "scissors",
				  scissors = "paper",
				  paper = "rock"}
rosh.isverbose = true

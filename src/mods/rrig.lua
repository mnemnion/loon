pretty = require "pl.pretty"

roshambo = require "roshambo"
rosh = roshambo()
rosh.isverbose = true
---[[
rosh:beats("rock","scissors")
rosh:beats("scissors","paper")
rosh:beats("paper","rock")

flu = setmetatable({},clu.Meta)
--]]
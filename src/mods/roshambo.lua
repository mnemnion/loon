--     Ro-Sham-Bo
-- A library by Combat
--        being
--   a Mnemnion joint
--    of MIT license
--  copyright 2015 e.v. 
--

-- Use
--
-- At the simplest level, Roshambo decides between any two values.
-- This is done by fiat: roshambo.beats(rock, scissors) means that
-- roshambo(scissors, rock) will return rock, scissors. 
-- 
-- This is done by looking up the value of "rock" against the victor
-- table, which returns a set of all values which rock defeats. This is done
-- with scissors also. Roshambo takes care that all fiat victory 
-- conditions are partially-ordered: rock and scissors cannot be entered as 
-- victors viz a viz one another. 
-- 
-- Should there be no fiat condition, the values are inspected to see if 
-- either contains a 'duel' method. Presuming they both do, duel is called,
-- each against the other: a random number is generated, and the two values
-- are compared. If equal, the leftmost is declared victor, if one is greater,
-- the greater is victorious.
-- 
-- Duels are decisive, with the results memoized. 
-- The user may override the result of a duel by fiat, or force further combat.
-- 
-- If there is no decisive victor, because both options lack
-- the ability to duel, roshambo will declare victory by fiat. If the first 
-- argument (the champion) exists, it wins, otherwise, the challenger wins.
-- This operation is idempotent, duels are fought once per pair. 
-- Roshambo is always decisive. 

local Set = require "set"

 clu = require "clu/prelude"
local util = require "util"
local tableand = util.tableand

--[[
roshambo = {}

roshambo._beats = { rock = Set{"scissors"},
				 paper = Set{"rock"},		
  	   		 scissors = Set{"paper"} }
--]]
local function beats(roshambo, champ, loser)
	--needs check for opposite condition,
	--which is nilled out.
	if roshambo._beats[loser] and
	   roshambo._beats[loser][champ] then
		roshambo:pr "reversal of fortune"
		roshambo._beats[loser] = roshambo._beats[loser] - champ
		roshambo:pr(roshambo._beats[loser])
	end
	champion = roshambo._beats[champ]
	if champion then 
		champion = champion + Set{loser}
	else 
		champion = Set{loser}
	end
	roshambo._beats[champ] = champion
	roshambo:pr(champ.." beats "..tostring(roshambo._beats[champ]))
end

local function duel(roshambo,champ,challenge)
	if tableand(challenge,challenge.duel) then
		roshambo:pr "it's a duel!"
	else 
		roshambo:pr "victory by fiat"
		roshambo:beats(champ,challenge)
		return champ, challenge
	end
end 	

local function fight(roshambo, champ, challenge)
	if roshambo._beats[champ] then
		if roshambo._beats[champ][challenge] then
		    roshambo:pr(tostring(champ).." wins") 
		    return champ, challenge
		elseif roshambo._beats[challenge] then
			if roshambo._beats[challenge][champ] then
				roshambo:pr(tostring(challenge).." wins")
				return challenge, champ
			end
		else --duel here
			roshambo:pr (tostring(challenge).." not found")
			return roshambo:duel(champ,challenge)
		end
	else --duel here as well
		roshambo:pr(tostring(champ).." not found") 
		return roshambo:duel(challenge,champ)
	end 
end



local R = {}
R.fight = fight
R.beats = beats
R.duel  = duel
R["__call"] = fight
R["__index"] = R
setmetatable(R,clu.Meta)

local function Roshambo(init)
	local rosh = {}
	rosh._beats = {}
	if init then
		if type(init) == "table" then
			for i,v in pairs(init) do
				rosh._beats[i] = Set{v} 
			end
		else
			error("Roshambo must be initialized with a table")
		end
	end
	setmetatable(rosh,R)
	rosh.foo = "bar"
	return rosh
end

return Roshambo

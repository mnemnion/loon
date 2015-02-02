--- <center>
-- Ro-Sham-Bo
-- 
-- A library by Combat
--
-- being
--
-- a Mnemnion joint
--
-- of MIT license
--
-- copyright 2015 e.v. 
-- </center>
--
-- Use 
-- ===
-- At the simplest level, Roshambo decides between any two values.
-- This is done by fiat: `roshambo.beats(rock, scissors)` means that
-- `roshambo(scissors, rock)` will return `rock, scissors`. 
-- 
-- This is done by looking up the value of "rock" against the victor
-- table, which returns a set of all values which rock defeats. Roshambo takes 
-- care that all fiat victory conditions are partially-ordered: rock and 
-- scissors cannot be entered as victors viz a viz one another. 
-- 
-- Should there be no victory, Roshambo falls back on its duel method, if the
-- instance provides one. 
-- 
-- Duels are decisive, with the results memoized. 
-- The user may override the result of a duel by fiat, or force further combat.
-- 
-- If there is no decisive victor, because both options lack
-- the ability to duel, roshambo will declare victory by precedence: the
-- first variable is the victor.
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

--- declares a victor by fiat.
-- @function roshambo:beats
-- @within methods
-- @param champ the value which wins
-- @param loser the value which loses
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
		--@todo foo all teh barz
		champion = Set{loser}
	end
	roshambo._beats[champ] = champion
	roshambo:pr(champ.." beats "..tostring(roshambo._beats[champ]))
end


local function duel(roshambo,champ,challenge)
	if roshambo._duel_with then
		roshambo:pr "it's a duel!"
		local winner, loser = roshambo:_duel_with(champ,challenge)
		roshambo:beats(winner,loser)
		return winner, loser
	else 
		roshambo:pr "victory by fiat"
		roshambo:beats(champ,challenge)
		return champ, challenge
	end
end 

local function duel_with(roshambo, fn)
	roshambo._duel_with = fn
end


--- conducts combat between values
-- @function fight
-- @within methods
-- @param champ will win by fiat
-- @param challenge will lose by fiat
-- @return the victor
-- @return the loser
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
			roshambo:pr(tostring(challenge).." not found")
			return duel(roshambo,champ,challenge)
		end
	else --duel here as well
		roshambo:pr(tostring(champ).." not found") 
		return duel(roshambo, champ, challenge)
	end 
end

--- provides a sorting function using Roshambo
-- @use roshambo(rock,scissors) => true
-- @function sort
-- @within methods
-- @param champ true if victor
-- @param challenge false if victor
-- @return boolean
function roshambo_sort(roshambo, champ, challenge)
	local victor = fight(roshambo,champ,challenge)
	return victor == champ and true or false
end

local R = {}
R.fight = fight
R.beats = beats
R.duel_with = duel_with
R.sort  = roshambo_sort
--- an alias for fight
-- @function __call
-- @param champ
-- @param challenge
-- @within metamethods 
R["__call"] = fight
R["__index"] = R
setmetatable(R,clu.Meta)

--- instantiates a roshambo
-- @function Roshambo
-- @param init a optional table of champ/loser key/value pairs.
-- @return an instance of roshambo
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

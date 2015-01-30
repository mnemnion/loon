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
-- the ability to duel, roshambo will return a table of
-- type Roshambo, the values of which may be set with roshambo.judge.
-- It will also set a victor at random, as a last resort. 
-- Roshambo is always decisive. 

local Set = require "set"
local R = {}
roshambo = {}

roshambo.beat_set = { rock = Set{"scissors"},
				 paper = Set{"rock"},
				 scissors = Set{"paper"} }

function roshambo.add(rsh, champ, loser)
	champion = rsh.beat_set[champ]
	champion = champion + Set{loser}
	print(champion)
end

function roshambo.fight(champ, challenge)
	if roshambo.beat_set[champ] then
		if roshambo.beat_set[champ][challenge] then
			print "winner"
		elseif roshambo.beat_set[challenge] then
			if roshambo.beat_set[challenge][champ] then
				print "loser"
			end
		else --duel here
			print "loser by default"
		end
	else --duel here as well
		print "no-shambo" 
	end 
end

function R.__call(self,rock, scissors)
	self.fight(rock,scissors)
end

setmetatable(roshambo,R)

return roshambo 
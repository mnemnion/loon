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
-- conditions are partially-ordered. 
-- 
-- Should there be no fiat condition, the values are inspected to see if 
-- either contains a 'duel' method. Presuming they both do, duel is called,
-- each against the other: a random number is generated, and the two values
-- are compared. If equal, the leftmost is declared victor, if one is greater,
-- the greater is victorious.
-- 
-- Duels are decisive, with the results memoized. The user may override the result
-- of a duel by fiat, or force further combat.
-- 
-- If there is no decisive victor, because both options lack
-- the ability to duel, roshambo will return a table of
-- type Roshambo, the values of which may be set with roshambo.judge.


local roshambo = {}

function roshambo.beats(rock, scissors)

end
local a = require "ansi"

 j = a.jump

local TL = 1
local HR = 2
local TR = 3
local VT = 4
local BR = 5
local BL = 6
local LI = 7
local TI = 8
local RI = 9
local BI = 10
local MI = 11

local box_heavy = {"┏","━","┓","┃","┛","┗","┣","┳","┫","┻","╋"}

local Box = {ch = box_heavy}

---returns a string rendering a box
local function box_str(b,row,col)
	local line = b.ch[TL]..b.ch[HR]:rep(col-2)..b.ch[TR]
	for i = 1, col do
		--linc = j.down()..a.
	end
end

print(box_str(Box,5,20))
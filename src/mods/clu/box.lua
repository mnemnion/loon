local a = require "ansi"
local CSI = string.char(27)..'['
 j = a.jump

local down = j.down()
local up = j.up()
local fwd = j.forward()
local back = j.back()
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

local box_check = {"┏","-","┓","┃","┛","┗","┣","┳","┫","┻","╋"}
local Box = {ch = box_heavy}

---returns a string rendering a box
local function box_str(b,row,col)
	local line = b.ch[TL]..b.ch[HR]:rep(col-1)..b.ch[TR]
	for i = 1, row-2 do
		line = line..down..back..b.ch[VT]
	end
	line = line..down..back..b.ch[BR]
	for i = 1, col-1 do
		line = line..j.back(2)..b.ch[HR]
	end
	line = line..j.back(2)..b.ch[BL]
	for i = 1, row -2 do
		line = line..up..back..b.ch[VT]
	end
	return line
end

print(j(1,1)..CSI.."2J")
print(box_str(Box,5,7))
print(j(6,1))
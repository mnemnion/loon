
local function num_bytes(str)
--returns the number of bytes in the next character in str
	local c = str:byte(1)
	if c >= 0x00 and c <= 0x7F then
		return 1
	elseif c >= 0xC2 and c <= 0xDF then
		return 2
	elseif c >= 0xE0 and c <= 0xEF then
		return 3
	elseif c >= 0xF0 and c <= 0xF4 then
		return 4
	end
end

local function Su (str)
	--convert a 'set' pattern to uniquely match the characters 
	--in the range.
	local catch = {}
	local i = 0
	for i = 1, #str do
		catch[i]
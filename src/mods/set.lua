
local function is_extended(str)
--returns true if the first character of the string is UTF-8

	return string.sub(str,1,1)
end

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

print(num_bytes"👿IMPUnicode: U+1F47F (U+D83D U+DC7F), UTF-8: F0 9F 91 BF䷀foo")




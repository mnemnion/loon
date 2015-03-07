--- Terminal String Module
-- Filters strings in various ways for ANSI output
-- or deANSIfication.

---replaces newlines with local jumps.

local stringx = require "pl.stringx"
a = require "ansi"

local function localize_newlines(str)
	local lines = stringx.splitlines(str)
	local phrase = ""
	for i,v in ipairs(lines) do 
		phrase = phrase..v..a.jump.down()..a.jump.back(#v)
	end
	io.write(phrase)
	return phrase
end

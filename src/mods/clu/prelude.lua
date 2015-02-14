--[[ 
Prelude to the Clu language.

Intended to contain the core technology.

Currently a grab bag.
]]

local ansi = require "ansi"

local Meta = {}

Meta["__call"] = function() return nil, "no function supplied" end

Meta["__index"] = Meta

function Meta.pr(self, ...)
	if self.isverbose then
	  print(unpack(arg))
	end
end

local p = { Blue = ansi.blue(),
		    Red = ansi.red(),
			Clear = ansi.clear(),
			Green = ansi.green(),
			Magenta = ansi.magenta(),
			Cyan  = ansi.cyan(),
			Yellow = ansi.yellow(),
			White = ansi.white(),
			Black = ansi.black(),
			Grey  = ansi.fg(8)}

local no_color = { Blue    = "",
				   Red     = "",
				   Clear   = "",
				   Green   = "",
				   Magenta = "",
				   Cyan    = "",
				   Yellow  = "",
				   White   = "",
				   Black   = "",
  				   Grey    = ""}

local env = { ansi = true,
			  xterm = true,
			  darwin = true,
			  unix = true,
			  palette = p,
			  no_color = no_color}


return { Meta = Meta,
		 env = env }
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

local p = { Blue = tostring(ansi.blue),
		    Red = tostring(ansi.red),
			Clear = tostring(ansi.clear),
			Green = tostring(ansi.green),
			Magenta = tostring(ansi.magenta),
			Cyan  = tostring(ansi.cyan),
			Yellow = tostring(ansi.yellow),
			White = tostring(ansi.white),
			Grey  = tostring(ansi.dim..ansi.white)}

local no_color = { Blue    = "",
				   Red     = "",
				   Clear   = "",
				   Green   = "",
				   Magenta = "",
				   Cyan    = "",
				   Yellow  = "",
				   White   = "",
  				   Grey    = ""}

local env = { ansi = true,
			  xterm = true,
			  darwin = true,
			  unix = true,
			  palette = p,
			  no_color = no_color}


return { Meta = Meta,
		 env = env }
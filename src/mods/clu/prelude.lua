--[[ 
Prelude to the Clu language.

Contains various tools expected to be broadly useful.
]]

local Meta = {}

Meta["__call"] = function() return nil, "no function supplied" end

Meta["__index"] = Meta

function Meta.pr(self, ...)
	if self.isverbose then
	  print(unpack(arg))
	end
end

return { Meta = Meta }
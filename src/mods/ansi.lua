local pairs = pairs
local tostring = tostring
local setmetatable = setmetatable
local error = error
local schar = string.char


module 'ansi'

local colormt = {}

-- todo : add clear switch to module so that multiple calls to 
-- clear or reset produce the empty string. 

-- test = (ansi.green..ansi.clear == ansi.green..ansi.clear..ansi.clear..ansi.reset..ansi.reset)

-- better: intern the previous and current values (fg and bg). Make reset return the previous
-- value, make any other call return the new value and set the current to previous, unless the
-- call wouldn't change anything, in which case, make it return "". 

-- doing that for arbitrary color calls would require arbitrarily deep stacks. Simply tracking the
-- current color in an environment variable would let me do that elsewhere if I need it. 

-- I feel as though print (ansi.red..."this is red"..ansi.green(" this is green").." still red")
-- is the correct approach. 


local current_fg, current_bg, current_attribute = "","",""

local function update(color)
    if color.kind == "fg" then
        current_fg = color
    elseif color.kind == "bg" then
        current_bg = color
    elseif color.kind == "attribute" then
        current_attribute = color
    else 
        error "color.kind set incorrectly in ansi.update" 
    end
end

local function current(color)
    if color.kind == "fg" then 
        return current_fg
    elseif color.kind == "bg" then
        return current_bg
    elseif color.kind == "attribute" then
        return current_attribute
    end
end


function colormt:__tostring()
    update(self)
    return self.value
end

local function direct_tostring(color)
    return color.value
end

function colormt:__concat(other)
    return tostring(self) .. tostring(other)
end

function colormt:__call(s)
    local current_color = current(self).value
    if s then
        return direct_tostring(self) .. s .. current_color
    else
        return tostring(self)
    end
end

colormt.__metatable = {}

local function makecolor(value, kind)
    local color = { 
        value = schar(27)..'['..tostring(value)..'m',
        kind = kind }
    return setmetatable(color, colormt)
end

local function byte_panic(byte_p)
       if not byte_p or not (0 < byte_p and byte_p <= 255) then
        error "xterm value must be 8 bit unsigned"
    end
end 

local function ansi_fg(byte)
    local store = {} -- repeated allocation is a sin.
    local function make (byte)
        byte_panic(byte)
        local color = { value = schar(27).."[38;5;"..byte.."m",
                        kind = "fg" }
        return setmetatable(color, colormt)
    end
    if store[byte] then
        return store[byte]
    else
        local color = make(byte)
        store[byte] = color
        return color
    end
end

local function ansi_bg(byte)
    local store = {}
    local function make (byte)
        byte_panic(byte)
        local color = { value = schar(27).."[48;5;"..byte.."m",
                        kind = "bg" }
        return setmetatable(color, colormt)
    end
    if store[byte] then
        return store[byte]
    else
        local color = make(byte)
        store[byte] = color
        return color
    end
end

_M["fg"], _M["bg"] = ansi_fg, ansi_bg

local colors = {
    -- attributes
    attribute = {
        reset = 0,
        clear = 0,
        bright = 1,
        dim = 2,
        underscore = 4,
        blink = 5,
        reverse = 7,
        hidden = 8},
    -- foreground
    fg = {  
        black = 30,
        red = 31,
        green = 32,
        yellow = 33,
        blue = 34,
        magenta = 35,
        cyan = 36,
        white = 37,
        clear_fg = 39  },
    -- background
    bg = {
        onblack = 40,
        onred = 41,
        ongreen = 42,
        onyellow = 43,
        onblue = 44,
        onmagenta = 45,
        oncyan = 46,
        onwhite = 47,
        clear_bg = 49}
}

for kind, val in pairs(colors) do
    for c, v in pairs(val) do 
        _M[c] = makecolor(v, kind)
    end
end

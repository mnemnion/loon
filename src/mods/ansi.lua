local pairs = pairs
local tostring = tostring
local setmetatable = setmetatable
local schar = string.char

module 'ansi'

local colormt = {}

function colormt:__tostring()
    return self.value
end

function colormt:__concat(other)
    return tostring(self) .. tostring(other)
end

function colormt:__call(s)
    return self .. s .. _M.reset
end

colormt.__metatable = {}

local function makecolor(value)
    return setmetatable({ value = schar(27) .. '[' .. tostring(value) .. 'm' }, colormt)
end

local function byte_panic(byte_p)
       if not (0 < byte_p and byte_p <= 255) then
        error "foreground value must be 8 bit unsigned"
    end
end 

local function ansi_fg(byte)
    byte_panic(byte)
    return schar(27).."[38;5;"..byte.."m"
end

local function ansi_bg(byte)
    byte_panic(byte)
    return schar(27).."[48;5;"..byte.."m"
end

_M["fg"], _M["bg"] = ansi_fg, ansi_bg

local colors = {
    -- attributes
    reset = 0,
    clear = 0,
    bright = 1,
    dim = 2,
    underscore = 4,
    blink = 5,
    reverse = 7,
    hidden = 8,

    -- foreground
    black = 30,
    red = 31,
    green = 32,
    yellow = 33,
    blue = 34,
    magenta = 35,
    cyan = 36,
    white = 37,

    -- background
    onblack = 40,
    onred = 41,
    ongreen = 42,
    onyellow = 43,
    onblue = 44,
    onmagenta = 45,
    oncyan = 46,
    onwhite = 47,
}

for c, v in pairs(colors) do
    _M[c] = makecolor(v)
end
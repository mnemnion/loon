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

-- I feel as though print (ansi.red..."this is red"..ansi.green(" this is green").." still red")
-- is the correct approach. 

local prior_fg, prior_bg = "",""
local current_fg, current_bg = "",""

function colormt:__tostring()
    return self.value
end

function colormt:__concat(other)
    return tostring(self) .. tostring(other)
end

function colormt:__call(s)
    if s then
        return self .. s .. _M.reset
    else
        return self.value
    end
end

colormt.__metatable = {}

local function makecolor(value)
    return setmetatable({ value = schar(27) .. '[' .. tostring(value) .. 'm' }, colormt)
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
        return setmetatable({ value = schar(27).."[38;5;"..byte.."m" }, colormt)
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
        return setmetatable({value = schar(27).."[48;5;"..byte.."m"}, colormt)
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
    reset = 0,
    clear = 0,
    bright = 1,
    dim = 2,
    underscore = 4,
    blink = 5,
    reverse = 7,
    hidden = 8,
    clear_fg = 39,
    clear_bg = 49,

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
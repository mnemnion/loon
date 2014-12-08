-- Copyright 2007-2014 Mitchell mitchell.att.foicica.com. See LICENSE.

local M = {}

--[[ This comment is for LuaDoc.
---
-- Manages key bindings in Textadept.
--
-- ## Overview
--
-- Define key bindings in the global `keys` table in key-value pairs. Each pair
-- consists of either a string key sequence and its associated command, a string
-- lexer language (from the *lexers/* directory) with a table of key sequences
-- and commands, a string key mode with a table of key sequences and commands,
-- or a key sequence with a table of more sequences and commands. The latter is
-- part of what is called a "key chain", to be discussed below. When searching
-- for a command to run based on a key sequence, Textadept considers key
-- bindings in the current key mode to have priority. If no key mode is active,
-- language-specific key bindings have priority, followed by the ones in the
-- global table. This means if there are two commands with the same key
-- sequence, Textadept runs the language-specific one. However, if the command
-- returns the boolean value `false`, Textadept also runs the lower-priority
-- command. (This is useful for language modules to override commands like
-- autocompletion, but fall back to word autocompletion if the first command
-- fails.)
--
-- ## Key Sequences
--
-- Key sequences are strings built from an ordered combination of modifier keys
-- and the key's inserted character. Modifier keys are "Control", "Shift", and
-- "Alt" on Windows, Linux, BSD, and in curses. On Mac OSX they are "Control"
-- (`^`), "Alt/Option" (`⌥`), "Command" (`⌘`), and "Shift" (`⇧`). These
-- modifiers have the following string representations:
--
-- Modifier | Linux / Win32 | Mac OSX | curses   |
-- ---------|---------------|---------|----------|
-- Control  | `'c'`         | `'c'`   | `'c'`    |
-- Alt      | `'a'`         | `'a'`   | `'m'`    |
-- Command  | N/A           | `'m'`   | N/A      |
-- Shift    | `'s'`         | `'s'`   | `'s'`    |
--
-- The string representation of key values less than 255 is the character that
-- Textadept would normally insert if the "Control", "Alt", and "Command"
-- modifiers were not held down. Therefore, a combination of `Ctrl+Alt+Shift+A`
-- has the key sequence `caA` on Windows and Linux, but a combination of
-- `Ctrl+Shift+Tab` has the key sequence `cs\t`. On a United States English
-- keyboard, since the combination of `Ctrl+Shift+,` has the key sequence `c<`
-- (`Shift+,` inserts a `<`), Textadept recognizes the key binding as `Ctrl+<`.
-- This allows key bindings to be language and layout agnostic. For key values
-- greater than 255, Textadept uses the [`keys.KEYSYMS`]() lookup table.
-- Therefore, `Ctrl+Right Arrow` has the key sequence `cright`. Uncommenting the
-- `print()` statements in *core/keys.lua* causes Textadept to print key
-- sequences to standard out (stdout) for inspection.
--
-- ## Commands
--
-- A command bound to a key sequence is either a Lua function or a table
-- containing a Lua function with a set of arguments to pass. They are
-- functionally equivalent; you can use either. Examples are:
--
--     keys['cn'] = buffer.new
--     keys['cz'] = buffer.undo
--     keys['a('] = {textadept.editing.enclose, '(', ')'}
--     keys['cu'] = function() io.snapopen(_USERHOME) end
--
-- Textadept handles [`buffer`]() references properly in static contexts.
--
-- ## Modes
--
-- Modes are groups of key bindings such that when a key [mode](#keys.MODE) is
-- active, Textadept ignores all key bindings defined outside the mode until the
-- mode is unset. Here is a simple vi mode example:
--
--     keys.command_mode = {
--       ['h'] = buffer.char_left,
--       ['j'] = buffer.line_up,
--       ['k'] = buffer.line_down,
--       ['l'] = buffer.char_right,
--       ['i'] = function()
--         keys.MODE = nil
--         ui.statusbar_text = 'INSERT MODE'
--       end
--     }
--     keys['esc'] = function() keys.MODE = 'command_mode' end
--     events.connect(events.UPDATE_UI, function()
--       if keys.MODE == 'command_mode' then return end
--       ui.statusbar_text = 'INSERT MODE'
--     end)
--     keys.MODE = 'command_mode' -- default mode
--
-- ## Key Chains
--
-- Key chains are a powerful concept. They allow you to assign multiple key
-- bindings to one key sequence. Language modules
-- [use key chains](#keys.LANGUAGE_MODULE_PREFIX) for their functions. By
-- default, the `Esc` (`⎋` on Mac OSX | `Esc` in curses) key cancels a key
-- chain, but you can redefine it via [`keys.CLEAR`](). An example key chain
-- looks like:
--
--     keys['aa'] = {
--       a = function1,
--       b = function2,
--       c = {function3, arg1, arg2}
--     }
-- @field CLEAR (string)
--   The key that clears the current key chain.
--   It cannot be part of a key chain.
--   The default value is `'esc'` for the `Esc` key.
-- @field LANGUAGE_MODULE_PREFIX (string)
--   The prefix key of the key chain reserved for language modules.
--   The default value is `'cl'` on platforms other than Mac OSX, `'ml'`
--   otherwise. Equivalent to `Ctrl+L` (`⌘L` on Mac OSX | `M-L` in curses).
-- @field MODE (string)
--   The current key mode.
--   When non-`nil`, all key bindings defined outside of `keys[MODE]` are
--   ignored.
--   The default value is `nil`.
module('keys')]]

local CTRL, ALT, META, SHIFT = 'c', not CURSES and 'a' or 'm', 'm', 's'
M.CLEAR = 'esc'
M.LANGUAGE_MODULE_PREFIX = (not OSX and not CURSES and CTRL or META)..'l'

---
-- Lookup table for string representations of key codes higher than 255.
-- Key codes can be identified by temporarily uncommenting the `print()`
-- statements in *core/keys.lua*.
-- @class table
-- @name KEYSYMS
M.KEYSYMS = {
  -- From Scintilla.h.
  [7] = 'esc', [13] = '\n',
  -- From curses.h.
  [263] = '\b', [343] = '\n',
  -- From Scintilla.h.
  [300] = 'down', [301] = 'up', [302] = 'left', [303] = 'right', [304] = 'home',
  [305] = 'end', [306] = 'pgup', [307] = 'pgdn', [308] = 'del', [309] = 'ins',
  -- From <gdk/gdkkeysyms.h>.
  [0xFE20] = '\t', -- backtab; will be 'shift'ed
  [0xFF08] = '\b', [0xFF09] = '\t', [0xFF0D] = '\n', [0xFF1B] = 'esc',
  [0xFFFF] = 'del', [0xFF50] = 'home', [0xFF51] = 'left', [0xFF52] = 'up',
  [0xFF53] = 'right', [0xFF54] = 'down', [0xFF55] = 'pgup', [0xFF56] = 'pgdn',
  [0xFF57] = 'end', [0xFF63] = 'ins', [0xFF8D] = 'kpenter', [0xFF95] = 'kphome',
  [0xFF9C] = 'kpend', [0xFF96] = 'kpleft', [0xFF97] = 'kpup',
  [0xFF98] = 'kpright', [0xFF99] = 'kpdown', [0xFF9A] = 'kppgup',
  [0xFF9B] = 'kppgdn', [0xFFAA] = 'kpmul', [0xFFAB] = 'kpadd',
  [0xFFAD] = 'kpsub', [0xFFAF] = 'kpdiv', [0xFFAE] = 'kpdec', [0xFFB0] = 'kp0',
  [0xFFB1] = 'kp1', [0xFFB2] = 'kp2', [0xFFB3] = 'kp3', [0xFFB4] = 'kp4',
  [0xFFB5] = 'kp5', [0xFFB6] = 'kp6', [0xFFB7] = 'kp7', [0xFFB8] = 'kp8',
  [0xFFB9] = 'kp9', [0xFFBE] = 'f1', [0xFFBF] = 'f2', [0xFFC0] = 'f3',
  [0xFFC1] = 'f4', [0xFFC2] = 'f5', [0xFFC3] = 'f6', [0xFFC4] = 'f7',
  [0xFFC5] = 'f8', [0xFFC6] = 'f9', [0xFFC7] = 'f10', [0xFFC8] = 'f11',
  [0xFFC9] = 'f12',
}

-- The current key sequence.
local keychain = {}

---
-- The current chain of key sequences. (Read-only.)
-- Use the '#' operator (instead of `ipairs()`) for iteration.
-- @class table
-- @name keychain
M.keychain = setmetatable({}, {
  __index = keychain,
  __newindex = function() error("'keys.keychain' is read-only") end,
  __len = function() return #keychain end
})

-- Clears the current key sequence.
local function clear_key_sequence()
  -- Clearing a table is sometimes faster than re-creating one.
  if #keychain == 1 then keychain[1] = nil else keychain = {} end
end

local none = {}
local function key_error(e) events.emit(events.ERROR, e) end
-- Runs a given command.
-- This is also used by *modules/textadept/menu.lua*.
-- @param command A function or table as described above.
-- @param command_type Equivalent to `type(command)`.
-- @return the value the command returns.
M.run_command = function(command, command_type)
  local f, args = command_type == 'function' and command or command[1], none
  if command_type == 'table' then
    args = command
    -- If the argument is a view or buffer, use the current one instead.
    if type(args[2]) == 'table' then
      local mt, buffer, view = getmetatable(args[2]), buffer, view
      if mt == getmetatable(buffer) and args[2] ~= ui.command_entry then
        args[2] = buffer
      elseif mt == getmetatable(view) then
        args[2] = view
      end
    end
  end
  local _, result = xpcall(f, key_error, table.unpack(args, 2))
  return result
end

-- Return codes for `key_command()`.
local INVALID, PROPAGATE, CHAIN, HALT = -1, 0, 1, 2

-- Runs a key command associated with the current keychain.
-- @param prefix Optional prefix name for mode/lexer-specific commands.
-- @return `INVALID`, `PROPAGATE`, `CHAIN`, or `HALT`.
local function key_command(prefix)
  local key = not prefix and M or M[prefix]
  for i = 1, #keychain do
    if type(key) ~= 'table' then return INVALID end
    key = key[keychain[i]]
  end
  local key_type = type(key)
  if key_type ~= 'function' and key_type ~= 'table' then return INVALID end
  if key_type == 'table' and #key == 0 and next(key) or getmetatable(key) then
    ui.statusbar_text = _L['Keychain:']..' '..table.concat(keychain, ' ')
    return CHAIN
  end
  return M.run_command(key, key_type) == false and PROPAGATE or HALT
end

-- Handles Textadept keypresses.
-- It is called every time a key is pressed, and based on a mode or lexer,
-- executes a command. The command is looked up in the `_G.keys` table.
-- @param code The keycode.
-- @param shift Whether or not the Shift modifier is pressed.
-- @param control Whether or not the Control modifier is pressed.
-- @param alt Whether or not the Alt/option modifier is pressed.
-- @param meta Whether or not the Command modifier on Mac OSX is pressed.
-- @return `true` to stop handling the key; `nil` otherwise.
local function keypress(code, shift, control, alt, meta)
  --print(code, M.KEYSYMS[code], shift, control, alt, meta)
  local key = code < 256 and (not CURSES or (code ~= 7 and code ~= 13)) and
              string.char(code) or M.KEYSYMS[code]
  if not key then return end
  shift = shift and (code >= 256 or code == 9) -- printable chars are uppercased
  local key_seq = (control and CTRL or '')..(alt and ALT or '')..
                  (meta and OSX and META or '')..(shift and SHIFT or '')..key
  --print(key_seq)

  ui.statusbar_text = ''
  --if CURSES then ui.statusbar_text = '"'..key_seq..'"' end
  local keychain_size = #keychain
  if keychain_size > 0 and key_seq == M.CLEAR then
    clear_key_sequence()
    return true
  end
  keychain[keychain_size + 1] = key_seq

  local status = PROPAGATE
  if not M.MODE then
    status = key_command(buffer:get_lexer(true))
    if status <= PROPAGATE and not M.MODE then status = key_command() end
  else
    status = key_command(M.MODE)
  end
  if status ~= CHAIN then clear_key_sequence() end
  if status > PROPAGATE then return true end -- CHAIN or HALT
  if status == INVALID and keychain_size > 0 then
    ui.statusbar_text = _L['Invalid sequence']
    return true
  end
  -- PROPAGATE otherwise.
end
events.connect(events.KEYPRESS, keypress, 1)

---
-- Map of key bindings to commands, with language-specific key tables assigned
-- to a lexer name key.
-- @class table
-- @name _G.keys
local keys

return M

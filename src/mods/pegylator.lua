-- PEGylator

-- A parser generator for LPEG.
require 'pl.strict'
local util = require "util"
local lpeg = require "lpeg"
local ansi = require "ansi"
local epeg = require "peg/epeg"
local core = require "peg/core-rules"
local epnf = require "peg/epnf"
local ast = require "peg/ast"
local grammar = require "peg/pegs/grammars"
local pretty = require "pl.pretty"
local diff = require "diff"

-- Rig 

peg = require "peg/quines/peg"
peg_hl = peg.peg_hl
peg = peg.peg

parse = ast.parse
highlight = require "peg/highlight"
transform = require "peg/transform"
codegen = require "peg/codegen"

local match = lpeg.match
local clear = tostring(ansi.clear)

function tshow(table)
	io.write(pretty.write(table))
end
tree = ast.parse(peg,grammar.peg_s)
tree_hl = ast.parse(peg_hl,grammar.peg_s)
g = ast.parse(peg,grammar.grammar_s)
a = dofile "peg/pegs/a.peg"
a = ast.parse(peg,a)
clu = ast.parse(peg,grammar.clu_s)
w = ast.parse(peg,grammar.wtf)
l = ast.parse(peg,grammar.lisp_s)
lisp = require "peg/quines/lisp"
lisp = lisp.lisp
hl = highlight.light
t  = transform.transform
hi = function(ast) io.write(hl(ast).."\n") end
--[[
t.transform(a)
t.transform(tree)
t.transform(g)
codegen.build(tree)
--]]

assert(tree == tree.index(5):root())
--assert(tree.str == hl(tree))
--print (match(grammar.symbol, symbol_s))

io.write(clear)
--print(tree)

return { peg = peg }
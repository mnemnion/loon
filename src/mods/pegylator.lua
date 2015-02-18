-- PEGylator

-- A parser generator for LPEG.
require 'pl.strict'
local clu  = require "clu/prelude"
local util = require "util"
local lpeg = require "lpeg"
local ansi = clu.ansi
local epeg = require "peg/epeg"
local core = require "peg/core-rules"
local epnf = require "peg/epnf"
local ast = require "peg/ast"
local sort = require "peg/rule-sort"
local grammar = require "peg/pegs/grammars"
local pretty = require "pl.pretty"
local diff = require "diff"


-- Rig 

op = require "peg/quines/ogpeg"
op_hl = op.peg_hl
op = op.peg

parse = ast.parse
sorter = sort
highlight = require "peg/highlight"
transform = require "peg/transform"
codegen = require "peg/codegen"

local match = lpeg.match
local clear = ansi.clear

function tshow(table)
	io.write(pretty.write(table).."\n")
end
tree = ast.parse(op,grammar.peg_s)
g = ast.parse(op,grammar.grammar_s)
a = dofile "peg/pegs/a.peg"
a = ast.parse(op,a)
Clu = ast.parse(op,grammar.clu_s)
w = ast.parse(op,grammar.wtf)
l = ast.parse(op,grammar.lisp_s)
lisp = require "peg/quines/lisp"
lisp = lisp.lisp
hl = highlight.Highlighter(peg)
t  = transform.transform
hi = function(ast) io.write(hl(ast).."\n") end
--t(tree)
--[[
t(a)
t(tree)
t(g)
codegen.build(tree)
--]]

assert(tree == tree.index(5):root())
--assert(tree.str == hl(tree))
--print (match(grammar.symbol, symbol_s))

io.write(ansi.clear_fg(),ansi.clear_bg(),clear())
--print(tree)

return { peg = peg }
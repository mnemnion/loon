#Commands

In Clu, we have expressions. Expressions evaluate, and return a value. We call our expressions exprs.

Exprs are denoted as `(command arguments)`, with a single command and an arbitrary number of arguments. Arguments are not necessarily evaluated before the command is called; if so, they are evaluated 

Exprs are not called lists, and commands are not necessarily functions. A quoted expr of the form `'(command arguments)` is a Node. Like any other quoted value, it is a fragment of syntax. There are no lists anywhere in Clu. 

A command is either a template, a macro, a function, or an implicit function call. Templates are passed their arguments parsed, but not evaluated. Macros expand, in place, over the evaluated arguments, and the resulting form is in turn evaluated. A function is called over the evaluated arguments. An implicit function call is a value treated as a function, which is possible for all compound types. 
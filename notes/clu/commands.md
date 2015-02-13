#Commands

In Clu, we have expressions. Expressions evaluate, and return a value. We call our expressions exprs.

Exprs are denoted as `(command arguments)`, with a single command and an arbitrary number of arguments. Arguments are not necessarily evaluated before the command is called; if so, they are evaluated in the order written. 

Exprs are not called lists, and commands are not necessarily functions. A quoted expr of the form `'(command arguments)` is a Node. Like any other quoted value, it is a fragment of syntax. There are no lists anywhere in Clu. 

A command is either a template, a macro, a function, or an implicit function call. Templates are passed their arguments parsed, but not evaluated. Macros expand, in place, over the evaluated arguments, and the resulting form is in turn evaluated. A function is called over the evaluated arguments. An implicit function call is a value treated as a function, which is possible for all compound types. 

This has non-trivial effects if you try to do things like pass a template as a value and call it. That works, of course, if the calling command is a template, but if the calling command is a function, you might be out of luck, since the function is already compiled. Templates compile a function call on a Node, and simply fail if they don't receive one. They can also take a string and convert it to a Node, so templates can be called in place of functions that receive exactly one string. 

This is a known problem with lisps, where one can't pass a macro to, say, `map`. In general, passing macros and templates around works, if you keep in mind that a command is not necessarily a function and that calling a macro where a function is needed is a runtime error. 

`macromap` is a perfectly reasonable template, `(macromap macro (arg 1) (arg 2))` would take the Node from parsing `(arg 1) (arg 2)` and map `macro` across it, then evaluate each of the resulting exprs

This would probably work with no modifications on templates also, since templates have higher precedence than macros, `defmacro` being a template form and macro expansion being the transformation of that template. 

Normally, this kind of high-level metaprogramming is confusing and indicates over-abstraction on the part of the user. Simple primitives combine in complex ways, we just want to make sure that they do so correctly. 
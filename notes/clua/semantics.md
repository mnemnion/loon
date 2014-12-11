#Semantics

Clua is designed to run atop LuaJIT. Early releases will remain compatible with Lua, but the intention is to start integrating with libraries at a level that will require us to pick a VM and stick with it. The choice is clear. 

Clua is defined in terms of S-expressions in the syntactic sense, and leverages this in ways that are pleasant to a Lisp user. It is not a Lisp. Clua is Lua. Lua provides a more powerful semantics in the form of tables. 

Lisps proper rely on a particular implementation of the tuple, one which happens to be fast on early hardware. For fast, we have LuaJIT, which erases most of the already low overhead of table lookups. 

We don't disguise the fact that we have tables upon tables, and the ability to return multiple unstructured values. We revel in it. 

## Incremental Transpiler

The intention is that Clua is translated to Lua by reading, constructing the AST, and transforming the structure into the minimum necessary amount of Lua. No whole-string representation of the program is generated and there are no line errors from the Lua interpreter. 

The result is an ordinary Lua environment. Code which translates down to chunks is called in the global context, functions and other values are entered into the environment, and so on. 

## Template Forms

Normally, a Lisp starts with a small number of atomic operations, introduces a few special forms, and proceeds on that basis. 

We have no need to bootstrap from a level where consing makes sense. Clua doesn't have cons cells, or proper lists, as a built-in type. What would you do with them, make Lua slower? `first` and `rest` probably draw from an iterator. Clua is Lua first, Clojure second, and only emotionally a Lisp. 

Therefore, our basic building block are template forms. You can define one, once we complete the bootstrap, they're a user-level technology. They take a template, fill it with the arguments, and compile it. They can be recursive, and call other templates, and keep proper track of lexical scope, although it's possible to confuse a template since they don't know what's in the strings. Templates do keep an eagle eye out for `_ENV` and try to do the right thing, so it may be possible to make it, at least, difficult to accidentally subvert hygiene.

It should be the case that the only Clua form that needs to be implemented in pure Lua is `deftemplate`. That would be nice. I'll be writing the whole shebang in Lua first, because that's how bootstrapping works. `deftemplate` is dead simple, of course, and could also be written in Clua, but I prefer to leave the straps on the boot.  

## Lists

The usual approach to a new Lisp is to bootstrap: create linked lists, cons, car and cdr, reverse (for some reason, this is always written early). The axiomatic approach, if you will. Rich Hickey started with really good data structures. T

This is closer to what we're doing with Clua. `first` and `rest` will exist, as a semantic convenience. Reverse is almost useless with a vector class, and anything you'd do with a linked list involving shared structure, you can do with tables and should. 

It actually makes more sense to think of lists as a unit of transpilation, than as anything else. Though a simple function call list in the global environment turns directly into a table lookup function call, as it would in standard Lua, `fn` and a few friends will need to call `loadstring` on a concatenated piece of Lua. Maybe. 

We may be able to get away with function factories. In fact, the more I think about it... I think that'll work. Destructuring will be a challenge, it's not actually a macro in that there's no other syntax for catching several return values. `let` and `set` will be our most special forms, suffice to say. Given a function and several symbols, construct and return a function that calls the function and sets all symbols equal to those values. Can be done, but I'd rather pay the transpiler tax unless it can be done efficiently.

Lists are one of several faces tables wear in the Clua environment, but the ordinary list is stored as a function with arguments. I'm still digging into the precise internal representation of functions in Lua, or rather what a 'chunk' is and whether/how I can get a deferred one. We may have to pay the cost of some additional indirection to get incremental transpilation to work, but we may expect LuaJIT to inline a host of anonymous functions as a first step in optimization. Only the profiler can tell for sure. 

Here's the magic formula that gets us off the ground:

```lua
for i, v in ipairs(chunk) do
	chunk[i](v)
end
``` 

because a chunk is for the most part a series of function calls, and/or can be tranformed into one. 

This is a fine interpreter, possibly dereferenced and slower, possibly not. I still have to figure out how to manually create scopes and hook them to things, but it's all (meta)tables. 

Between LuaJIT and whole-program transpiling, I'll take my chances. We can always add a Closure-style (yes 's') whole program compiler later, if we're feeling ambitious. I'm okay with just letting Lua be small and LuaJIT be fast, and taking a hit if I have to. It's a respectable way to make a language, and again, I can't decide if it's worth the cost until I know the price. 

## Vectors

Vectors get used a lot, since our lists are completely fake half the time. Arguments to functions are defined in a vector, and we use a syntactic vector in our destructuring let, to capture multiple return values in an elegant fashion. 

They behave exactly as you'd expect, if you expect a dense table that starts at 1 and uses -1 for reverse indexing. Clua should make plenty of sense to all three Lua-aware Clojurians.
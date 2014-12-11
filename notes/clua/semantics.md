#Semantics

Clua is designed to run atop LuaJIT. Early releases will remain compatible with Lua, but the intention is to start integrating with libraries at a level that will require us to pick a VM and stick with it. The choice is clear. 

Clua is defined in terms of S-expressions in the syntactic sense, and leverages this in ways that are pleasant to a Lisp user. It is not a Lisp. Clua is Lua. Lua provides a more powerful semantics in the form of tables. 

Lisps proper rely on a particular implementation of the tuple, one which happens to be fast on early hardware. For fast, we have LuaJIT, which erases most of the already low overhead of table lookups. 

We don't disguise the fact that we have tables upon tables, and the ability to return multiple unstructured values. We revel in it. 

###Is it a Lisp though?

Clua handily meets all nine points on [Paul Graham's](http://www.paulgraham.com/diff.html) list of what makes Lisp different. Any programmer who glances at it will call it a Lisp. Anyone who argues with the idea that it's a Lisp, knows what `funcall` does. 

Look I feel you. I'm in favor of Lisp-2 myself, but Lua provides neither linked lists nor a separate namespace for functions, so we're stuck with it. Most people prefer Lisp-1, until they get a chance to try otherwise. For my taste, in English you can list a list, in fact that's very common, so `(list list)` is a fine idiom to my taste. 

Similarly, I feel at least moderately bad about taking away all your lovingly crafted algorithms and tricks using cons cells, improper cells, A-lists, P-lists, and so on. YAGNI, holmes, this is all simpler than that, so you can focus on the part of Lisp where you do crazy things on account of having access to linguistic sillyputty. 

## Incremental Transpiler

The intention is that Clua is translated to Lua by reading, constructing the AST, and transforming the structure into the minimum necessary amount of Lua. No whole-string representation of the program is generated and there are no line errors from the Lua interpreter. 

The result is an ordinary Lua environment. Code which translates down to chunks is called in the global context, functions and other values are entered into the environment, and so on. 

## Template Forms

Normally, a Lisp starts with a small number of atomic operations, introduces a few special forms, and proceeds on that basis. 

We have no need to bootstrap from a level where consing makes sense. Clua doesn't have cons cells, or proper lists, as a built-in type. What would you do with them, make Lua slower? `first` and `rest` probably draw from an iterator. Clua is Lua first, Clojure second, and only emotionally a Lisp. 

Therefore, our basic building block are template forms. You can define one, once we complete the bootstrap, they're a user-level technology. They take a template, fill it with the arguments, and compile it. They can be recursive, and call other templates, and keep proper track of lexical scope, although it's possible to confuse a template since they don't know what's in the strings. Templates do keep an eagle eye out for `_ENV` and try to do the right thing, so it may be possible to make it, at least, difficult to accidentally subvert hygiene.

It should be the case that the only Clua form that needs to be implemented in pure Lua is `deftemplate`. That would be nice. I'll be writing the whole shebang in Lua first, because that's how bootstrapping works. `deftemplate` is dead simple, of course, and could also be written in Clua, but I prefer to leave the straps on the boot. 

I'm told this templating business is important to conducting operations on the World Wide Web. It may also be the case that there are many grammars to cope with in a coherent way, used out there. Blessedly, I would have no idea. 

Can you pass templates a reader? Indeed, though it will default to Lun if you don't provide one. Defaulting to Clua would be pointless, no? But if your template was some kind of angle-bracketed markup language, you can assuredly pass a reader to your template. Templates are expected to evaluate their contents, not merely read them (that's a macro), but parsing is a degenerate case of evaluation, as is returning a string, or writing to a file and returning the handle, or whatever you want. What. ever. you. want. 

I think these reasonably qualify as fexprs. Maybe? I'm pretty sure it's a fexpr if you pass it the Clua reader. 

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

## Quoted lists

Exist in an entirely different form from 'lists'. They're vectors, lists are a series of function calls, some anonymous, some not, since a chunk is just an anonymous function. These you can cons. Then again, `(cons (list one) (list two))` never did the same thing as `(cons '(list one) '(list two))`, did it? 

Unquoting a list and calling it will require compilation, although we could provide an interpreter, see above. I don't want the parser and Lua compiler to have to travel around inside binaries, and Lua is aggressive about stripping functions that aren't called if you give it the correct flag. 

In any case it's an idiom I expect to see mostly from old Lisp heads, and it isn't considered the Loony thing to do in general. I do intend, somehow, to preserve the general semantics. I believe this can be made to work. 

## Vectors

Vectors get used a lot, since our lists are completely fake half the time. Arguments to functions are defined in a vector, and we use a syntactic vector in our destructuring let, to capture multiple return values in an elegant fashion. 

They behave exactly as you'd expect, if you expect a dense table that starts at 1 and uses -1 for reverse indexing. Clua should make plenty of sense to all three Lua-aware Clojurians.

## Tables

Are tables. We'll use a lot of them.

Taking `first` on tables won't do what you expect, until you learn to expect it. `rest`, implemented properly, would be moderately expensive in space and time, requiring a surface copy of the entire table (list, vector...). Prefer `next` in such cases. If you `conj` a table, it will merge, but re-index the second table above the first, if there's an index.

`next` will try to exhaust the index before falling back on pairs. We probably want to meta-tag `:has-index` on tables that do. 

## Macros

My current intention is that templates be clean and macros dirty. Sometimes you want variable capture, it's great for building state machines, for example. Not all macros are intended for reuse outside of their context. 

Some people won't like that. Those people can write a `syntax-rules` to go with `defmacro`, which will be a template. 

## $

`$` is going to be important for Clua. It's a selector that operates on tables. You can use it to perform captures as well as rule-based replacement, it does what you'd expect if you spend time with selectors. I put it right under macros because we'll be using it a lot, since `$` can act on the AST of the code being evaluated. 

I'll be including quote, unquote, and quasiquote (which I don't even understand yet), because a selector-based macro will have invisible effects on the structure, being declarative in nature, while the use of quote and unquote is admirably explicit. Sometimes you want one, sometimes the other. `$` is probably itself a macro. 

## Type Annotations

Lua is a classically dynamic language, in that it has types, but it doesn't do much with them unless you tell it to. 

When I'm good and ready, I'll start adding type annotations to Clua. We need them to work in a useful way, and need to discern what that is. Structurally, they're somewhat unusual in a Lisp, in that they're a proper form, meaning `< form >` is always syntactically correct, but they apply to the next form, formally and implicitly joining into a single form. So `{<int> 3 "foo"}` is syntactically correct, despite the requirement that a table contain an even number of forms.

I believe a type annotation followed by another type annotation is also incorrect. It's not clear what the resulting potential chain of infinite concatenations would mean. 

The meaning is clear enough: if the brackets contain a type, or a form returning a type, then the next form is either of that type, or must be of that type. If the form in the brackets returns another form (type of something that's not Type), then the next form is/must be of that type. 

The mechanism is also clear, it must be a metatable, what other option do we have? 

How to make it function as a type system? That's not clear, and may be moderately difficult. Gradual typing is an art, to be sure, which has been reinvented repeatedly with varying degrees of success. 

I expect this to be useful in interoperating with Rust, and possibly C++. But if you're using that steaming pile too long after Rust 1.0, you are making a mistake, my friend. 


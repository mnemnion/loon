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

## Symbols

Lua has a loose distinction between strings and symbols, which is enforced through syntax. It's not sufficiently first class, by itself, for Clua. 

Happily, strings now have metatables, so equality tests of `"foo"`, `'foo` in one context, and `'foo` from a second context will not report as equal, and the latter two will be of type `<Symbol>` rather than `<String>`.

## Numbers

What a number is needs to be user defined, for any reasonable mathematics to happen. This is why we provide a literal syntax for any number form you want, provided it has no whitespace. 

## Syntax

`<Syntax>` is a first class type in Clu. A syntax takes a `<String>`, currently, and returns an `<Ast>`. A syntax does not evaluate.

## Template Forms

Normally, a Lisp starts with a small number of atomic operations, introduces a few special forms, and proceeds on that basis. 

We have no need to bootstrap from a level where consing makes sense. Clua doesn't have cons cells, or proper lists, as a built-in type. What would you do with them, make Lua slower? `first` and `rest` probably draw from an iterator. Clua is Lua first, Clojure second, and only emotionally a Lisp. 

Therefore, our basic building block are template forms. You can define one, once we complete the bootstrap, they're a user-level technology. They take a template, fill it with the arguments, and compile it. They can be recursive, and call other templates, and keep proper track of lexical scope, although it's possible to confuse a template since they don't know what's in the strings. Templates do keep an eagle eye out for `_ENV` and try to do the right thing, so it may be possible to make it, at least, difficult to accidentally subvert hygiene.

It should be the case that the only Clua form that needs to be implemented in pure Lua is `deftemplate`. That would be nice. I'll be writing the whole shebang in Lua first, because that's how bootstrapping works. `deftemplate` is dead simple, of course, and could also be written in Clua, but I prefer to leave the straps on the boot. 

I'm told this templating business is important to conducting operations on the World Wide Web. It may also be the case that there are many grammars to cope with in a coherent way, used out there. Blessedly, I would have no idea. 

Can you pass templates a reader? Indeed, though it will default to Lun if you don't provide one. Defaulting to Clua would be pointless, no? But if your template was some kind of angle-bracketed markup language, you can assuredly pass a reader to your template. Templates are expected to evaluate their contents, not merely read them (that's a macro), but parsing is a degenerate case of evaluation, as is returning a string, or writing to a file and returning the handle, or whatever you want. What. ever. you. want. 

Specifically, a reader decomposes into a syntax and an evaluator for that syntax. What Lisp folks call a "reader" is actually a `<Syntax>` in Clu, aka `<||>` which we read as 'the type of the empty syntax'. What we call a reader evaluates its context, as well as parsing it.  

I think these reasonably qualify as fexprs. Maybe? I'm pretty sure it's a fexpr if you pass it the Clua reader. But it's more than a fexpr. If we ever decide to bypass the Lua layer, the templates can emit and compile LuaJIT bytecode directly. Or asm.js, or whatever's clever. 

`#`, which is read as 'reader macro', calls the local reader when placed at the head position. 

Templates are read incrementally and recursively by reader calls, and evaluated when the reader exits the form. This means that if you call a template from a template, evaluation happens within the template, if you call a reader within a template, evaluation happens upon return. I trust this is sufficiently clear. 

Templates return an `<Environment>`, that in which they've done their work.  

## Lists

The usual approach to a new Lisp is to bootstrap: create linked lists, cons, car and cdr, reverse (for some reason, this is always written early). The axiomatic approach, if you will. Rich Hickey started with really good data structures.

This is closer to what we're doing with Clua. `first` and `rest` will exist, as a semantic convenience. Reverse is almost useless with a vector class, and anything you'd do with a linked list involving shared structure, you can do with tables and should. 

It actually makes more sense to think of lists as a unit of transpilation, than as anything else. Though a simple function call list in the global environment turns directly into a table lookup function call, as it would in standard Lua, `fn` and a few friends will need to call `loadstring` on a concatenated piece of Lua. Maybe. 

We may be able to get away with function factories. In fact, the more I think about it... I think that'll work. Destructuring will be a challenge, it's not actually a macro in that there's no other syntax for catching several return values. `let` and `set` will be our most special forms, suffice to say. Given a function and several symbols, construct and return a function that calls the function and sets all symbols equal to those values. Can be done, but I'd rather pay the transpiler tax unless it can be done efficiently.

## Quoted lists

Exist in an entirely different form from 'lists'. They're vectors, lists are a series of function calls, some anonymous, some not, since a chunk is just an anonymous function. These you can cons. Then again, `(cons (list one) (list two))` never did the same thing as `(cons '(list one) '(list two))`, did it? 

Unquoting a list and calling it will require compilation, although we could provide an interpreter, see above. I don't want the parser and Lua compiler to have to travel around inside binaries, and Lua is aggressive about stripping functions that aren't called if you give it the correct flag. 

In any case it's an idiom I expect to see mostly from old Lisp heads, and it isn't considered the Loony thing to do in general. I do intend, somehow, to preserve the general semantics. I believe this can be made to work. 

I'm also slowly realizing that I'm probably wrong about this. Quoting something means you read it and defer evaluation. I believe we can do this in a consistent way. 

Question to answer: if I `let` some variables in a lisp, then add them to a quoted list, return it, and evaluate it, what happens? That is, how do quoted lists interact with lexical closures? More importantly what do I want them to do? Probably lift out their context, but I'm not sure.

## Vectors

Vectors get used a lot, since our lists are completely fake half the time. Arguments to functions are defined in a vector, and we use a syntactic vector in our destructuring let, to capture multiple return values in an elegant fashion. 

They behave exactly as you'd expect, if you expect a dense table that starts at 1 and uses -1 for reverse indexing. Clua should make plenty of sense to all three Lua-aware Clojurians.

## Tables

Are tables. We'll use a lot of them.

Taking `first` on tables won't do what you expect, until you learn to expect it. `rest`, implemented properly, would be moderately expensive in space and time, requiring a surface copy of the entire table (list, vector...). Prefer `next` in such cases. If you `conj` a table, it will merge, but re-index the second table above the first, if there's an index.

`next` will try to exhaust the index before falling back on pairs. We probably want to meta-tag `:has-index` on tables that do. 

## Macros

Templates, being evaluators attached to readers (which are core functions applied to a syntax), are dirty by definition. They create an environment, and evaluate inside that environment. `|foo|` will be the same as whatever `foo` happens to be laying around within that environment when evaluation happens. 

Macros, therefore, will be strictly hygenic. Otherwise we have a real headache on our hands. Hygiene should be tractable by overriding the `__newindex` metatable for the macro's metatable.

This leads to the most important thing to know about macros in Clu, which is that they happen before template expansion. All macros are expanded, all template forms are compiled, and then all functions run. Clu. 

## $

`$` is going to be important for Clua. It's a selector that operates on tables. You can use it to perform captures as well as rule-based replacement, it does what you'd expect if you spend time with selectors. I put it right under macros because we'll be using it a lot, since `$` can act on the AST of the code being evaluated. 

I'll be including quote, unquote, and quasiquote (which I don't even understand yet), because a selector-based macro will have invisible effects on the structure, being declarative in nature, while the use of quote and unquote is admirably explicit. Sometimes you want one, sometimes the other. `$` is probably itself a macro.

## Destructuring form

This is a possible use for the `\/` pair. A form such as `(\form/)` would destructure invisibly into its return values.

I like this, but I'm leaving it out of the language for now. The destructuring `let` and `set` is easy to understand, and the anonymous form can be `(ret foo bar baz)`, where `ret` is a template form.  

## Type Annotations

Lua is a classically dynamic language, in that it has types, but it doesn't do much with them unless you tell it to. 

When I'm good and ready, I'll start adding type annotations to Clua. We need them to work in a useful way, and need to discern what that is. Structurally, they're somewhat unusual in a Lisp, in that they're a proper form, meaning `< form >` is always syntactically correct, but they apply to the next form, formally and implicitly joining into a single form. So `{<int> 3 "foo"}` is syntactically correct, despite the requirement that a table contain an even number of forms.

I believe a type annotation followed by another type annotation is also incorrect. It's not clear what the resulting potential chain of infinite concatenations would mean. 

The meaning is clear enough: if the brackets contain a type, or a form returning a type, then the next form is either of that type, or must be of that type. If the form in the brackets returns another form (type of something that's not Type), then the next form is/must be of that type. 

The mechanism is also clear, it must be a metatable, what other option do we have? 

How to make it function as a type system? That's not clear, and may be moderately difficult. Gradual typing is an art, to be sure, which has been reinvented repeatedly with varying degrees of success. 

The edge cases, such a whether to constrain by failure or attempt a structural cast, can be figured out later. The gist is that type annotations attach metatables to values. 

Which is almost impossibly cool. You can attach a metatable to a string; you can even attach a metatable to a number, by making it an anonymous function which, called, returns its value, then attaching a metatable to the function. In Lua, that's a moderate amount of work, in Clua, we can let you make a literal number a `<Liter>` and dividing it by a `<Kilo>` will yield a `<Ratio>` of type `<Density>`. Eventually. `<Kilo>`, being `(is-a <Mass>)`, should be castable to a `<Pound>`, for those benighted cases where we need one. And so on. This is tractable, but we need a langauge before we can subject it to such delightful uses. 

Every metatable has a single metatable, leading back to _G. They may contain arbitrary numbers of *references* to metatables, naturally, enabling, I'm certain, a CLOS level of object orientation. 

Note that my understanding of how metatables work is both more complex and different from how they actually work. Still figuring out how to make them do what I want. 

I expect this to be useful in interoperating with Rust, and possibly C++. But if you're using that steaming pile too long after Rust 1.0, you are making a mistake, my friend. 


#Clua

Clua is a proposed syntax over the semantics of Lua. 

The intention is to provide the syntactic benefits of Clojure, without providing a story around immutability or the corresponding refs, actors etc. A Clojure syntax highlighter will almost get Clua correct, but code in general won't run, beyond a few Rosetta-style snippets. 

##Precepts

Clua is Lua. It is not Lisp nor Clojure. Lisps process lists, Clua processes Lua tables and runs chunks. Clojure provides immutability as a default, Clua doesn't even offer it. Any time we run into semantic friction, Lua wins. 

It should be easy to translate conceptually from Clua to Lua. The nature of S-expression macro syntax is such that translation to the generated code might be ugly, but understanding the syntax tree should not be. 

Clua will offer certain semantic enhancements, notably keywords, a conceptual distinction between a table and a vector, and a set type. This plus a small amount of sugar should suffice to import and use EDN, which is an explicit design goal. 
##Some Clua

Let's dive in.

```clojure
(print "hi")
(print (+ 3 4))
(set foo (+ 5 6))
```

Clua is eager and imperative. These may be wrapped in a `(do (...))` form when useful. These statements are simply executed, as a chunk in the global environment. 

```clojure
(defn funky
	"this is a funky function."
	[ foo bar baz]
	(do
		(frob foo)
		(bar baz))
```

Which becomes

```lua

foo = function (...)
	-- local docstring = "this is a funky function."
	local foo, bar, baz = unpack(...)
	frob(foo)
	return bar(baz)
end
```

more or less. 

In Clojure the `[]` syntax indicates a vector, here it indicates a table used in the lua array fashion. It starts with 1. I didn't do this and won't change it. There is no sugared syntax for indexing, we use the Clojurian `(ith 5 Array)` formation. 

The reason we `unpack(...)` rather than assigning the arguments directly, is to provide a consistent semantics for function calls. My instinct is that this will make macros easier to write. 

I need to get my story straight around multiple return values, which aren't inherently Lispy. It's too easy in that context to return some collection, such as, I dunno. A list?

The answer is probably some destructuring syntax such as `(let { [a,b,c] : (multi-return) })`, that creates a vector and proceeds never to use it. This we most likely leave out of the generated code, which makes locals in the expected fashion. If we want to `let` into a vector, that looks like `(let vector : (vec (multi-return)))`. I'd like to write `let` as a macro, and one that doesn't use `drop!` (which passes bog Lua to the compiler). That means a regular syntax is needed, that `let` emits on expansion. 

This also implies a `return` special form, that takes a quoted list and returns the values in the specified order. So `(let {[a,b,c] : vector-from-args} (return '(a b c))` should destructure the first three elements of the vector into locals a, b and c, then return them atomically. 

This points to a peculiarity of Clua: our lists are imaginary. Depending on context, they exist as a function with arguments or a vector of elements, both of which are treated differently than the underlying tables would be. There are going to be all kinds of mind-bending ways of breaking the logic underlying Clua. Since I'm a Lisper at heart, I encourage this, as long as the resulting syntax is clean. 

In Clua, our let looks a little different than Clojure:

```clojure

(let { foo: bar, baz: bux})

```

reflecting exactly what we're doing: copying the value of a variable over into the local scope, which is a table. It's called `let` but it does what Lua does, and your changes to the new value mutate what Lua would mutate. They go out of scope when Lua does, and so on. 

Comments are whitespace, as is conventional in a Clojure. It is customary to use them to separate key-value pairs in a map. Clua has no maps, only tables: now you don't have to map a map, so you're welcome for that. 

Things Clojure accomplishes with sequences, Clua uses iterators for. As you might expect, this doesn't involve type transformation (turning a map into a list of the map's values in a certain order) nor is it precisely immutable. 

This might mean we have a function like `setseq` that binds an iterator to something like a table. 

`(foo["bar"])` can't produce the value of the key `"bar"`, because it must call foo with the argument of a vector containing only the string `"bar"`. `(foo.bar baz)` could easily call `foo.bar`, which better be a function, on `baz`. 
Since we don't have to interoperate with Java, we don't have the broken dot syntax. and `(foo . bar)` would call `foo` on `.` and `bar`. So how would we interpret `(foo bar.1)`? Well, we kinda have to interpret it as `foo["1"]`, not to be confused with `foo[1]`. 

I want to solve this problem in some fashion. One possibility is to cast `foo.1` to a number, and allow/require `foo."1"` as a valid formation to string-index numbers. This is elegantly sugary, at the expense of some clarity. The alternative would be to use some form such as `foo:1` for numbers, which might be okay. As a Lisper I do like being able to generate symbol names like `into:`, we like punctuating prefixes in general. Perhaps just `foo..1`, though this poses a problem, because `foo[".1"]`, though weird looking, is a valid table lookup. 

The answer might be: a vector in the function position during read, calls a compile time macro that expects a single value, which is interpreted as the index. So `([foo bar baz] 2)` will return `bar`. Not `baz`, because Lua. `([foo bar baz] -1)` will give you baz, because Lua again. 

I like this resolution. It should work on tables also, since they aren't actually different things, at least not yet. The Clua standard environment will never violate the semantic difference between a table and a vector, so if we ever add fast(er) vectors to the runtime, they may be employed profitably. It would even function correctly on sets, which we intend to implement as a table which produces `true` for elements which are in the set. I do need to look carefully into Lua's concept of equality: our sets will simply provide it. This means Clua lacks an important guarantee of Clojure, which uses immutable data sets to ensure the equality of structurally identical compound types. So if you take two different `#{a,b,c}` and add them to a set, you'll have a set that contains either of those literal sets, despite their semantic equivalence. Worse (much worse) providing the anonymous set `#{a,b,c}` as a key will produce `nil`, since that third set is not a member. 

This would qualify as a mistake in Lua as well, so we allow this behavior and expect the programmer to understand that she is using a dynamic, imperative language. Loon will easily allow adding immutable types, with real structural equality, and disguising them with whatever syntax you desire. 


```clojure
(+ a b c d)
```

```lua
a + b + c + d
```

This is a non-obvious point. Lua has overloading of certain operators through the metatable. Those 'functions' are expanded into the form shown. The effect is what it is, and can be anything. I mislike operator overloading, and a Lispy syntax shows why. 

The alternative would be to add gating logic to operators in the runtime, since Clua is as unable as any lisp to infer the value of a symbol at compile. This is of course unacceptable, as we expect operators to be fast. 

The same logic applies to relational operators. Anything a Lua user would expect to be resolved via metatable will do so in Clua. Since they are neither functions (as they would be in a common Lisp), special forms, macros nor expression, we simply call the referents of symbols in this class metamethods. 

Clua is a Lisp 1, since Lua uses a single symbol environment. This would be easy to change, since environments are delightfully simple things in Lua, being tables. Clojure is also Lisp 1, so why bother violating expectations? Only trouble can result. 

`=` is tricksy. We should use `let` and `set` for local and global assignment respectively, leaving an important symbol semantically void. I suggest casting it to mean `==` and making `==` into structural equality, which has a slower but equivalent result on atomic types and is a useful idiom for some compound types. The cleanest thing to do is make them synonyms, to prevent user error. The same should hold for `~=` and `!=`, the former being Lua idiom and the latter universally understood. 
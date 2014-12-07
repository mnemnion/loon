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
		(frob(foo))
		bar(baz))
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

I need to get my story straight around multiple return values, aren't inherently Lispy. It's too easy in that context to return some collection, such as, I dunno. A list?

The answer is probably some destructuring syntax such as `(let { [a,b,c] : (multi-return) })`, that creates a vector and proceeds never to use it. This we most likely leave out of the generated code, which makes locals in the expected fashion. 

In Clua, our let looks a little different:

```clojure

(let { foo: bar, baz: bux})

```

reflecting exactly what we're doing: copying the value of a variable over into the local scope, which is a table. It's called `let` but it does what Lua does, and your changes to the new value mutate what Lua would mutate. They go out of scope when Lua does, and so on. 

Comments are whitespace, as is conventional in a Clojure. It is customary to use them to separate key-value pairs in a map. Clua has no maps, only tables: now you don't have to map a map, so you're welcome for that. 

Things Clojure accomplishes with sequences, Clua uses iterators for. As you might expect, this doesn't involve type transformation (turning a map into a list of the map's values in a certain order) nor is it precisely immutable. 

This might mean we have a function like `setseq` that binds an iterator to something like a table. 

`(foo["bar"])` can't produce the value of the key `"bar"`, because it must call foo with the argument of a vector containing only the string `"bar"`. `(foo.bar baz)` could easily call `foo.bar`, which better be a function, on `baz`. 
Since we don't have to interoperate with Java, we don't have the broken dot syntax. and `(foo . bar)` would call `foo` on `.` and `bar`, 


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
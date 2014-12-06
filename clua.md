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
	foo, bar, baz = unpack(...)
	frob(foo)
	return bar(baz)
end
```

more or less. 

In Clojure the `[]` syntax indicates a vector, here it indicates a table used in the lua array fashion. It starts with 1. I didn't do this and won't change it. There is no sugared syntax for indexing, we use the Clojurian `(ith 5 Array)` formation. 

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

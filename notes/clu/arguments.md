#Arguments

Commands are followed by arguments, which are structurally a vector, being a series of forms. Defining a function, we use a vector, as in Clojure:

```clojure
(defn foo [bar baz] 
	(do ...))
```

We differ decidedly from Clojure in that we don't use destructuring within arguments. Instead, we reuse the semantics of our syntax forms. 

If we want a function to supply a default argument:

```clojure
(defn with-defaults 
	[{foo 23} {bar "baz"}]
	(do ...))
```

If we want to restrict the use of a function by type:

```clojure
(defn with-types
	[[:[Node]: foo bar] {baz #bux}]
	(do ...))
```

I feel like the `:[Node]:` syntax is pretty heavyweight stuff. But types can be passed as values, so we need some literal form or we'll be littered with `[[(type Node) foo bar] baz bux]` which is just awful. `[[a-type foo bar] baz` will look up the value of a-type and produce a runtime error if it doesn't return a Type. Yes, this would mean you can dynamically change the value of `a-type` causing a function to selectively reject and accept different types. Why would you? I don't make these choices for you. 

In LuaJIT dispatching on primitive types is effectively free. Dynamic languages being what they are, type annotation on compound types are a runtime check, basically a built-in unit test for your program. 

All of the defining forms are templates (`fn`), or macros which expand into templates (`defn`), so we can conditionally compile out type checks for production-ready code:

```clojure
(now 	
	(if (production)
		(parse (without-types defn) args)
		(parse (with-types defn) args)))
```

Mas o menos.

##Destructuring

Oh all right. Here's some sugar for the `let` binding, because extra keystrokes are sin.

```clojure
(defn foo [ \[bar baz bux]/ ] (...))
(defn foo ( \{#bar bux #quux flux}/ ) (...))
```

I mean we've got our `\o/`, let's use it. 

##Return form

Since we can specify types, we should also be able to specify return values, with types.

Like this:

```clojure
(defn foo { [ {⟨Apple⟩ foo} {⟨Boa⟩ bux} ]
			[ ⟨number⟩ ⟨boolean⟩ ]}
 	(...))
```

Note that it's an error detected during macro expansion to supply more than one key/value for a table in an argument context. `⟨Type⟩` may be entered as `:[Type]:`, just as `«string»` may be entered as `:"string":`, since method chaining ssyntax requires a symbol that evals to a function. Clu will have certain forms for compatibility with the ASCII era and ease of entry. Unlike C, and unlike most languages in existence, Clu will physically reach into your file and change `:[` to `⟨`, and so on. Whether we do the same to `fn` and `λ` remains to be seen. Most likely, not. 
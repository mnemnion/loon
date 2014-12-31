#A Destructuring Let

All of the forms used in Clu come together in our let statement. 

It is moderately complex, as a result. Clu's virtue is demonstrated in the clarity of the resulting system.

Note that `let`, `set`, and `def` all function using the same assignment structure, with the usual semantics: `let` creates a scope, `set` mutates a value in-scope and may not create new symbols, and `def` creates in the global scope.

## Fundamental Structure

` (let form form* form+ ) `

The first thing we notice is that `let` to function correctly must be at minimum a macro. This is quite ordinary. At this stage it is unclear if it must be a fexpr as well.

The rule is simply that if the first form is a table, the second form is not present, otherwise it is. The reasoning should become clear as we proceed.

### Atomic Let

```clojure

(let foo bar (...)) ; atomic let

(let a (foo bar) (...)) ; atomic compound let

```

If the first form is a symbol, the second form is evaluated and the result assigned to the symbol. 

If there are multiple returns, the first is assigned, the rest discarded.

The remaining forms are evaluated within this scope, and the last form's value(s) are returned. 

### Compound Let

```clojure
(let {foo bar,
	  baz bux} (...)) ; compound let

(let {a (foo bar),
	  b (baz bux)} (...)) ; compound compound let
```

If the first form is a table, the remaining forms constitute the block and are evaluated in-scope.

The values of the table are evaluated in order and the results assigned to the keys. 

### Multiple Returns

Lua and Clu both offer native multiple returns. Our `\o/` form manages this. In order to destructure the left hand side, we use a vector, like so.

```clojure
(let [a,b,c] \(foo bar)/ (...)) ; multiple return values

(let { a (foo bar),
	   [b,c,d] \(baz bux)/} (...)) ; and so on

```

The vector `[a,b,c]` never exists, which is fine, as we have no way to refer to it symbolically. We don't use

```clojure
(let (a b c) \(foo bar)/ (...))
```

or

```clojure
(let '(a b c) \(foo bar)/ (...))

because the first is a runtime error unless `(a b c)` returns a symbol, and the latter would try to assign to a compound quote, which is also illegal, as quotes are values. This makes no more sense than `(let 1 "one")`, since 1 is a number, not a symbol, or `(let "one" 1)` for that matter. 

It is likely that `\foo bar/` will serve as sugar for `\(foo bar)/`, given that interpreting it as returning the symbols would be incorrect. That is either `\'foo 'bar/` or just as likely `\'(foo bar)/`, which is exactly how we destructure within macros (that would be some variety of `` `(foo ~\bar/) `` to destructure the quasiquote, `~` being our clojurian unquote operator.

### Types

In Clu the statement `<foo>` returns the metatable of foo. Conventionally a metatable, or type, is uppercase, so Foo. Therefore we have this:

```clojure

(let <foo> Foo)

(let Foo <foo>) ; we've met this already

(let <foo> <bar> )

(let {foo (bar baz)
	  <foo> Foo}) 

``` 

I trust this is fairly straightforward to read. It's important to realize that this sets the **value** of the symbol to have a metatable. For this reason, this is also valid:

```clojure
(let <'foo> Foo)
```

Which sets the metatable of the symbol "foo" to Foo. This is at least meaningful, though our quotation system is going to take finesse, since there are no lists anywhere in Clu. 

####Syntax Errors

The following forms are meaningless, as far as I can tell, and are therefore syntax errors.

```clojure

(let (foo bar) (baz bux)) ; syntax error
(let '(foo bar) (baz bux)) ; syntax error, macro resolves form from AST, 
						   ; where '(list elements) and [vector elements]
						   ; are not equivalent. 
```
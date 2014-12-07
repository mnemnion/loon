#A Destructuring Let

```clojure

(let foo bar (...)) ; atomic let

(let {foo bar,
	  baz bux} (...)) ; compound let

(let a (foo bar) (...)) ; atomic compound let

(let {a (foo bar),
	  b (baz bux)}) ; compound compound let

(let [a,b,c] (foo bar) (...)) ; multiple return values

(let { a (foo bar),
	   [b,c,d] (baz bux)}) ; and so on

(let (foo bar) (baz bux)) ; syntax error
(let '(foo bar) (baz bux)) ; syntax error, macro resolves form from AST, 
						   ; where '(list elements) and [vector elements]
						   ; are not equivalent. 
```


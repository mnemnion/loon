#Ssyntax

```clojure
(let foo {}
 (...)
 (foo bar)  ; foo[bar]
 (foo "bar") ; foo["bar"]
 (foo #bar)  ; foo.bar, must be valid (clu) symbol
 (foo.bar baz) ; foo.bar(baz)
 (foo #bar) baz) ; foo.bar(baz)
 (foo.bar.baz bux) ; foo.bar.baz(bux)
 \foo #bar #baz #bux/ ; function()
 					  ;   return foo.bar, foo.baz, foo.bux
 					  ; end()
 (foo #bar #baz #bux) ; (function ()
 					  ;    return foo.bar, foo.baz, foo.bux
 					  ;	  end())
 (foo:bar baz)        ; foo:bar(baz), foo.bar(foo,baz)
 (foo:(bar baz):bux quux) ; foo:bar(baz):bux(quux)
 (let temp ((foo bar) foo baz)
 	((temp bux) temp quux)) ; method chaining does 
 							; express otherwise difficult idioms

 )
```
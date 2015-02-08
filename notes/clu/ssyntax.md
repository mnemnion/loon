#Ssyntax

```clojure

(foo.bar baz bux)                ; simple enough

((foo bar) baz bux)				 ; meaning

(foo@bar baz bux)                ; method call

((foo bar) foo baz bux)          ; meaning

(foo.bar.baz bux quux)           ; field access may be chained

(foo.1 bar.3)				     ; presuming they may be indexed why not?

((foo 1) (bar 3))                ; if these are vectors this is the same

(foo."bar" baz.#bux )            ; lookup on strings, keywords, why not?

(foo:(bar:(baz bux quux)))       ; necessary because it might be

(foo:(bar bux:(baz quux)))       ; for example
							     ; which chains the return of (bar bux)
							     ; as the first argument to baz
  							     ; (before quux)

(((foo bar) foo) baz ((foo bar) foo) bux quux)   ; translation of first
												 ; i *think*

(bar (foo foo bar bux) quux)     ; translation of second

(foo . bar . baz bux quux)       ; hard to read, valid

(foo . "bar" . #baz bux . #quux) ; please don't

(foo : (bar : (baz bux quux)))   ; easier to read, valid

(foo :(bar :(baz bux quux)))     ; etc.
```
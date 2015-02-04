#Ssyntax

```clojure

(foo.bar baz bux)              ; simple enough

(foo@bar baz bux)              ; method call

(foo.bar.baz bux quux)         ; field access may be chained

(foo@(bar@(baz bux quux)))     ; necessaary because it might be

(foo@(bar bux@(baz quux)))    ; for example
							   ; which chains the return of (bar bux)
							   ; as the first argument to baz
							   ; (before quuux)

(foo . bar . baz bux quux)     ; hard to read, valid

(foo @ (bar @ (baz bux quux))) ; easier to read, valid
```
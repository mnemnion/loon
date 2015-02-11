#Keywords

I'm not entirely sure we need keywords per se.

```clojure

{ .key "value"
  .another-key 42 } ; fits with foo.key

{ #key "value"
  #another-key 42 } ; still uses foo.key, right? 
  					; no this would be foo#key

 { 'key "value"
   'another-key 42 }

 (foo arg another .param 12 .another-param "value") ; named varargs

 (foo arg #param 12 #another-param "value") ; basically, are they strings?
 											; or specially interned symbols? 
 ```

Verdict: the `.keyword` syntax is winning. I think it just makes a string that must be a valid Clu symbol. Probably, this is actually a memoized table. I dunno. I'm overthinking this question.


Let's try again:

#Tags

Clu offers tags. Tags are a short form for specifying strings that can be valid (Clu) symbols. 

In Clu, tags are strings. Symbols are strings also, but they live in environment tables and resolve to values. 

`(*G* #foo)` is equivalent to `foo` in Lua, which can also be written `_G.foo`. Note that we use a CL-like idiom for variables that would otherwise take a leading underscore; I believe a metamethod like `__call` we would refer to as `^call`. We will have a consistent system for translating forbidden symbols into Lua/Lun for interoperability purposes. 

`*G*.foo` also works. Note that the leading hash is not retained and that we don't allow hashes at the beginning of symbols, anywhere else is okay. 

Tags aren't special anywhere. They're slightly more than a semantic convenience, since they are strings that obey symbol syntax. `(eq "foo" #foo)` is true by design. We'll have an `&key` form for handling final arguments, so `(foo bar #baz bux #quux flux)` on `(defn foo [bar &key])` works as you'd like it to. 

To offer this short form in Lun, we use `$Sigil` rather than `#Tag`, to avoid conflicting with the length operator. 

I considered and rejected using a leading period. We'd like to retain it for an infix operator, which munges most other uses pretty thoroughly. 

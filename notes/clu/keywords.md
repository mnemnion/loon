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


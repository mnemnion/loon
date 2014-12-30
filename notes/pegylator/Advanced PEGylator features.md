#Advanced PEGylator features


So far I've been sticking to idioms easily expressed in LPEG grammar, in declarative form.

I'd like to give declarative access to some of the more advanced pattern matching features of 


##Capture Length Matching

I'd like a rules such as ` S : "A" "A"*^n "B" "B"^*^n ` to match at least one A, followed by at least one B, if the total number of A and B is the same. `n` must not be a rule, and may be any other value. 
` S : "A"+^n  "B"+^m "CD"+^n "E"+^m ` matches at least one `A`, followed by at least one `B`, then exactly as many `CD` as there are `A` and precisely as many `E` as there are `B`. 

Lua style long strings:

` long-string : "[" "="*^n "[" !("]" "="^n "]") ANY "]" "="^n "]" `

this could be cleaned up with a second rule. I believe the correct scoping rule here is that referred values have a flat scope for any regular rule,  and a single scope for any recursive rule. That is `n` will be the same through and up into any regular match, while recursive rules will require scoping. I will probably make it a syntax error to attempt to reuse a length match across a recursive rule. Experience has taught me that it's not always clear which rules are recursive and which aren't. 

Since there's no recursion, this should work:

``` 
 
long-string = open !close ANY* close

open = '[' '='*^n '['

close = ']' '='^n ']'

```

certainly this is the level of clarity we strive for. As regular rules are never reentrant by definition, length tags should function correctly in any combination. 

Should be allow `n` to be a mathematical function of n? Hmm. Constraints are lovely things in a declarative context, if you want to say ` absurd-rule = silly-case*^n ha-ha^m algebra^(n-14/(128 % m)) ` well. It's a meaningful statement, is it not? I do believe we'll want to capture a value rather than set up a system of equations to satisfy. Although....

Of course this exact problem is solved in [Roberto's LPEG paper](http://www.inf.puc-rio.br/~roberto/lpeg/) under "Lua's Long Strings". This is a reasonable template for providing this function declaratively. 
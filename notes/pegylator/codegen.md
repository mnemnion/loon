#Codegen

Still working out the smoothest way to do code generation.

It turns out the right way to handle grammars at this stage is to make all atoms `V"atom"` and let Glob sort it out. 

The others: `T` for anything that will be an anonymous token, `C` for anything to be captured, `I` for anything to be ignored. Making Lpeg work programatically, the way I want it to, is proving a challenge.

But the general approach that makes sense is to have a single function name for each semantic action on the right hand side of a grammar: ignoring a token, capturing a range, capturing an anonymous token (a literal), capturing a rule as a named token, etc. 

This lets us generate several engines from a single function, since the function is called in a custom environment created by `define`. We can pass an expanded `define` different versions of these named functions and it will patch them into the function and generate a grammar accordingly. 

This lets us use a consistent API and generate the various validators. This gets really fun when we define a combinator library using the operator overload semantics of lpeg, letting us define arbitrary operations through the same grammar by combining functinos over pretty much anything. We need this for the table validator and probably to write acceptors, which can dummy up strings a grammar will accept. 
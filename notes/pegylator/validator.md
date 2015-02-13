#Validator

An important class of parsing engine are the table validators.

We have string validators also, they are very simple: they match over a string and return true if it's in the universe of the grammar. 

Table validators are more complex, and more important. With a table validator, we can confirm that a given Node **could have** been generated from a string in the universe of the grammar. 

This is on the Clu critical path, because with a validator, we can confirm that a given Node could have been generated from Lua code. That means it should compile without syntax errors when we pass it to `eval`.

The correct technique for generating this structure is parser combinators. If I were compiling pegylator format into a source engine directly, I would use combinators for clarity, convenience, and reasonable speed. 

I'm pretty sure I can find a memoizing algorithm for combinators if I knock around. Not that we should need one often, for functions that do table lookups and compare pre-interned strings while calling the occasional very-small Lpeg rule. 

Anything which goes into Clu is intended to be reasonably fast. **bridge** will load as a precompiled image, naturally, but loading it from source shouldn't take a long time. 
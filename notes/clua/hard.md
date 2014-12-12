#Hard Things

Or things that look hard right now


##Functionalizing Tables

If I say `(foo bar)` and `foo` turns out to be a table, I want `foo[bar]()`, not `foo(bar)`.

The only resolutions I can picture are moderately expensive. I may luck out and find that Lua has an implicit call build in somewhere. 

Nope, this is easy: [__call](http://lua-users.org/wiki/MetatableEvents) is among the metatable events. 

My oh my, what an orthogonal language we have here. And it looks like Pascal. <shrug>

##Iterating over Function

This one we do with coroutines. There [a separate document](iterator over function.md) for that.
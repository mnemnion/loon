#Hard Things

Or things that look hard right now


##Functionalizing Tables

If I say `(foo bar)` and `foo` turns out to be a table, I want `foo[bar]()`, not `foo(bar)`.

The only resolutions I can picture are moderately expensive. I may luck out and find that Lua has an implicit call build in somewhere. 

Nope, this is easy: [__call](http://lua-users.org/wiki/MetatableEvents) is among the metatable events. 

My oh my, what an orthogonal language we have here. And it looks like Pascal. <shrug>

So what is the meaning of `Table(...)` in Clu? We use the arguments as the index to the table, and multiply return the keys. Naturally. I'm slightly surprised this isn't default behavior, attaching one metatable with a single __call to each table is surely not expensive. They have metatables already, or you couldn't even __index them. 

I want this as a low-cost consistent behavior, and IRC says `hoelzro: mnemnion: you could just define getmetatable(table).__call to create such a table for yourself`, so hey that should work.

I'm a big fan of orthogonal behavior, and Lua doesn't allow shared tables for functions, coroutines, strings, numbers, booleans, and nil. Allowing `nil` to have different behaviors in different contexts would be a serious mistake. For the rest, I can see the value in it.

Adding this would involve promoting any value we wanted to override into an anonymous table with the correct values. This would be expensive to do for every primitive. I may just accept that a symbol which evaluates to a form is valid at the head position, while a symbol which evaluates to an atom is not. That's at least consistent with the overall semantics, and very close to what Lua actually does. 

##Iterating over Function

This one we do with coroutines. There [a separate document](iterator over function.md) for that.
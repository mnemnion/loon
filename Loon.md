#Loon

LuaJIT is amazing. The more I study it the more impressed I become. If you want to make a pilgrimage to a codebase, this is a good one. 

The reason for this is that Mike Pall is a genius, and Lua is very, very well-designed. Most of the things we're inclined to think of as quirks are syntax: easy to accidentally create a global, one-based indexing, 'patterns' instead of regex, and the like. 

Lua is as relentlessly specialized as a Platonic Lisp. Where a Lisp has lists, Lua has the table: a mapping of anything onto anything. Oh, and every table has a chain of metatables going back to the environment. If you know something about Lisps under the hood, you realize there's some hacking involved to provide equivalent functionality. If you don't, read the elisp manual, it's the best thing about emacs. 

Basically everything important is done with function pointers and table lookups. Therefore, LuaJIT is unreasonably good at eliminating the overhead of these operations. In general, looking up a function in a table, looking up a table of arguments, unpacking the arguments, and calling the function over the arguments, shouldn't take more time than simply calling the function with the arguments, because after a few warmup calls, LuaJIT know's what's going on. 

Best of all, LuaJIT has a fast, transparent, powerful C FFI. World class. This comes directly from Lua's minimal design and the way it uses stack frames. 

I wouldn't want to touch LuaJIT and wouldn't know where to begin. Mike Pall is likely to break anything I touch in the relentless pursuit of perfection; when there's an artist like that in the building, gratitude and keen attention is the right approach. Similarly, I happen to think Lua is a fine language and have no proposals to change it. 

Under the hood of Lua/JIT I see a lovely platform for language exploration and development. The Loon toolchain adds two things: a grammar-driven parsing stage, and an intermediate representation. Lua's table and metatable system are ideally suited to the sort of decorated tree we want to use. 

LuaJIT is a keen set of semantic tools. It should be possible to address it using Lua syntax, Lisp, whitespace sugared (MoonScript), brace-style, or even concatenative, since Lua has proper multiple return values which could be modeled as a data stack, since it is. Lua's engine interleaves calls and variables, so a Joy-like syntax would likely be preferred over a Forthright one.

Let's explore how we can build Loon on a principle of least development.

#### Quick check for semantic clarity

Searching for `Loon language` produces scholarly articles about the language of the loon bird. Truly, a haunting call. Searching for `Loon Lua` currently produces a gentleman named Zhong Loon Lua. Remarkably, we appear to be on solid ground. 

##Intermediate representation

Lua has no need for an exposed IR. It's lightweight as is, and can cook down directly to bytecode. By standardizing an intermediate representation, we accomplish a few things. 

One, it should be possible to interpret the IR by a simple recursive table lookup. Maybe LuaJIT will make this as fast as running the compiled code, maybe it won't. With a decorated syntax tree, it's a simple matter to whole-compile a transform string if this proves useful to efficiency. If the Loon IR catches on, adding some LuaJIT logic to optimize paths specific to the IR is practical.

The other factor is the ability to go directly from a grammar to the IR. 

##Grammar driven development.

LuaPEG doesn't appear to have a grammar driven front end, but they're easy to write with a PEG library. Breaking Lua itself down into an IR is strictly speaking extra work, but that work is done, since a PEG for Lua exists. Breaking MoonScript or Clua (my hypothetical 'really neat lualisp') into the IR is more important, for doing things like generating meaningful error messages, and transposing between the source code and the intermediate. 

Again, even if we end up compiling a fully transformed string as one big chunk, there are benefits to this approach. A decorated syntax tree is the basic unit of code comprehension, and rallying around one simple, Lua-based, serializable IR would be a boon.

With this, we can drive syntax extension quite independently of the Lua main track. LuaJIT needn't drift away from compatibility with Lua, though the reverse will no longer apply, and frankly hasn't for awhile now. One of the key uses for such a grammar system is to wrap calls through to various C APIs in a useful little language that extends one or more of the Luaesque languages. Since bog-standard Lua/JIT has a fairly nice language for C calls, it's easy enough to provide the raw libraries to those outside of the Loon ecosystem. 

As an example of what I'm talking about, a shell call such as ` cd("directory/path") ` could be rendered in-script as simply `` ` cd directory/path ` ``, with the wrapper not needed in interactive mode. Even just `` ` cd directory/path ``, with a `` ` `` as the prompt character. Note to self: careful read of default Lua and maybe go over some of the WoW extensions to see if there's wisdom. `` ` `` is a great escape sequence, but a junk prompt. 

I have an interest in making a Lua shell, this is one of the reasons why breaking free of the syntax in a few directions is appealing to me. 

Also, with a top level rule like ` Loon : Lua / Markdown / Moonscript / Clua `, there should be no reason to specify the language in detail. Each dialect will rapidly generate a syntax error if processed as the wrong script, and PEGs completely abandon failed paths. They might memoize but again, we expect a syntax error in under two lines. It's simply not a significant cost. 

I threw Markdown in there because we should be able to embed PEGs in PEGs, allowing for a literate dialect that uses code-gating to allow us to code across dialects. Since I like *real* literate coding environments, I will be tempted to expand this to allow for, e.g., keeping Rust modules in the same place as their Lua wrappers. I'm convinced this is relatively easy to do with Git integration, and painful otherwise, so it's a deferred project. 

This approach allows for dozens of small, simple, cumulative improvements. Another example would be a configuration parser, which reads ordinary Lua files but restricts the output in various ways, notably disallowing the definition of functions or the use of dangerous parts of the standard library. It's almost possible to do this with metatables, but we can completely disallow the use of `function` at the syntax level if we desire. This is nice for, say, an editor, where we'd like to be able to know the difference between configuration and extension. Emacs destroys this line, which should be blurred, not wrecked. 

###Minimum Viable Loon

Loon is remarkably close to completion. It's almost an observation of a pattern in Lua development. LPeg parsers exist for Moonscript and standard Lua already, as well as Moonlisp, @leafo's Lispy dialect. Moonlisp appears to be designed to be as CL-like as possible, whereas I prefer a Clojurian syntax, feeling it will attract more contemporary users. 

The most exciting thing for me about this approach is that it will give us a chance to enforce static constraints. Now this is often a losing proposition with a dynamic language: One often finds oneself writing separate compile-time and runtime versions of the constraint, with complex interactions, and hoping they provide the same behavior. 

LuaJIT, on the other hand, frequently interfaces with static code. If we choose to use our ability to constrain syntax mostly/entirely on structures that cross the FFI, then we're good. If defining an array of floats, it would be nice to just say ` floats = Array<f64>: [1.0, 2.0, "string"]` and have it tell us, correctly, that C ain't having that. 

I'm not sure what type annotations should looklike in Lua or Moonscript, or Clua for that matter. What makes a grammar-driven approach clutch is that my opinions on this don't matter much.

I would like to write a proper grammar front end for LPeg (assuming there isn't one) so that the grammars themselves are separable from the code they generate. This is just nice to have, there's no real need for it at present.

One immediate advantage: given a grammar, it should be possible to construct both a string parser and an IR validator for the same data. The awesome power of being able to parse over your tree should be made available for Loonacy. 

This done, we need to make the IR consistent. I have a feeling Leafo uses the same approach for both of his projects, which leaves LuaMacro. I intend to write a small Lua program to generate validators for tables based on rules: one advantage of having a proper grammar front end to LPEg is that we could boilerplate a validator using that grammar. 

I'd also like to define a rule-based system for syntax error definition and propagation. I see only benefits in separating grammar-driven (hence constraint-driven) concerns from imperative syntax. 

I need to read up on how LPeg does IR already. One of my self-imposed constraints is that no modification of LPeg, LuaJIT, nor the Lua language need happen. If Loon is successful in the community, it may serve to guide LuaJIT development, or it may not. Mike Pall knows what he's doing. 

Note that in LuaJIT "IR" refers to the representation between the bytecode and the trace-compiled native code. We leave this region well alone; we're Loons, but we're not crazy. 

The only scaffolding in this Loon is the Lua language itself. I'm hoping someone who likes this kind of thing will write a compiler to LuaJIT bytecode directly from our IR. It's somewhat of a moving target, sure, but that's the great thing about an intermediate representation: Every dialect targeted against that IR benefits from the compiler. LuaJIT bytecode may change from time to time, the changes might even be breaking, but they get fixed once for the entire ecosystem. If Mike likes the approach, the IR compiler might join LuaJIT. 

In fact I should look into the front-end for LuaJIT. He may have an IR already which could be normalized with the LPeg IR in some fashion. 

###Cool Future Stuff

One problem I'm anticipating is that of providing clean bindings between Rust and Lua. At least the Rust team cares about the problem; C++ never did, not really. Generally, lifetimes and other borrow semantics will be submerged beneath the Lua layer, but making clean use of the type system may prove challenging.

Making sense of all this will likely involve importing the LLVM IR and generating bindings programatically. This sounds like a job for Loon! 

Someday, I intend to write a moderately [sophisticated parser](https://github.com/mnemnion/ggg). The correct language for such tools is Rust, as of its upcoming 1.0 release. As it's a superset of PEG grammrs, we should be able to port the LPegs with a net gain in efficiency. Having separately specified grammars can only help with this. Note that LPeg offers an `r e` module offering "somewhat conventional" regular expression syntax. Loon grammars should favor this module over the use of Lua "patterns", which are a) less powerful and b) syntactially peculiar. 



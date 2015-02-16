#Types

Clu is a dynamic language. Our concept of type owes more to CLOS than anything. As a result, this discussion cannot help but be grating for those from the 'real types' community. To you, the brave and functional, I say this: Clu has the same primitive types and the same union type as Lua. There is a limited idiomatic landscape in programming, and since we refer to 'keywords' as 'tags', we call our tagged values types. Note that if we called our tags keywords, we would be forced to use some other term for a symbol the user isn't allowed to redefine, if our language offered such symbols, which it does not. 

In Clu we express a type as `:[Type]:` or the preferred form `⟨Type⟩`. `⟨⟩` or `:[]:` is the empty type. Clu has an unusual but not unheard of feature, wherein the compiler will alter your original source code, stripping tailing whitespace, replacing horizontal tabs with two spaces, and substituting certain characters which are strictly equivalent. `:[Type]:` is what we call input syntax, `⟨Type⟩` is preferred syntax. This action will be configurable without stress, but is opt-out, and required for any pushes to the main trunk. `⟨⟩` or `:[]:` is the empty type.

Primitive types are written as `⟨string⟩` in lower case. For compound types, the associated metatable is always `Type`. 

##Use

Types are not required. It is perfectly plausible to write a Clu program that doesn't reference types explicitly. Types are used extensively by the core Clu system, and calling a core function with the wrong arguments will produce a type error. 

The Clu object system, which we're calling Cluster, is a simple metaobject protocol based on the existing Lua metamethods, particularly __index, __newindex, and __call. One of the major contemplated uses for types is interfacing with other languages which have powerful and/or strict type systems, such as Rust. Each such language has its own spin on typing: Rust requires lifetimes, Haskell offers a bewildering array of options, and so on. By directing the behavior of slot access, slot creation, and method calls, we can enforce these over the areas where they're required. 

[Wake](http://www.wakelang.com/) has been making the rounds lately, and has an idea I intend to borrow: in some contexts, you can refer to types generically. Example:

```clojure
(defn square [⟨number⟩] 
  (* ⟨number⟩ ⟨number⟩))
```

This function will fail if called on non-numeric values, and will otherwise square the number given. If we wanted it to work for `⟨Number⟩`, a type generic to any number-like entity (rule of thumb: it must do something sensible when primitively operated upon (meaning `+*-/<=`) with a primitive number), we'd use that in the defn and body. 

Combining this with the `@` syntax for `self` or `this`, which is just the first argument to any command, and we can have a tight-yet-readable syntax for many commands. 

LuaJIT makes a specialty of eliminating lookups which either always succeed or fail, and is capable of optimizing entirely past primitive type comparison, due to its tag architecture. There should be little need to remove type checking from the runtime of a program, but our compiler is flexible, and we can add it where we want it. Clu proper needs to run in any old Lua environment: we'll even link in a pure-Lua lpeg if we can't use C libraries, the Clu compiler will always have a dependency-free edition, the bridge environment is free to rely on LuaJIT, as **bridge** is a (Rust|Nim|Terra|C) program containing LuaJIT as a library. 
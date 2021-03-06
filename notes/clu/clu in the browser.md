#Clu in the browser

Though obvious, it is by no means beneath mention: Clu can be natively run in the browser and will be an excellent match for it.

The Javascript runtime is mutable, prototype based, and has strings, floats, table-like objects, and real arrays that happen to obey the vector semantics we apply to Lua tables with the `[]` syntax. 

We should be able to write a library-compatible version of Clu, since Clu itself will use Clu syntax for as much core function as possible once bootstrapping is underway. We can either write a Lun-JS bridge, or make `(with-syntax JavaScript)` the default use of `||`, the latter being lower-effort and easier for the JS crowd to reason about. I'd suggest the former as a shim. 

The most important shim is a Table object which contains a Map-like and a Vector-like subobject, the latter as an Array. Tables have to be able to take any value as a slot, and faking this in JS is not as difficult as it might be. There are a few Lua-JS compilers, we can draw on them for inspiration. 

The resulting JS will be at least readable if not particularly idiomatic. Certainly a much closer semantic match than ClojureScript, while hopefully giving a similar feel. Cluje (The Clu JavaScript Environment) and Clu should be capable of being identical to the point where Cluje is an implementation, not a dialect. It will of course expect different libraries, hence, Environment.

After all, we're able to support the JS syntax eventually using the Tessel compiler, so JS-Lua is within reach once we have a parser for it. We could cheat and not define the JS grammar, but let's not, for the sake of consistent tooling. 

Cluje may also be used on the server side to interface with Node and whatever gets built with ServoMonkey. Since we can cross-translate Lua and JS directly, at least in the JS -> Lua direction, this has the potential for much happy synergy. 
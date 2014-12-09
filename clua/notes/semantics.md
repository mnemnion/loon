#Semantics

Clua is designed to run atop LuaJIT. Early releases will remain compatible with Lua, but the intention is to start integrating with libraries at a level that will require us to pick a VM and stick with it. The choice is clear. 

Clua is defined in terms of S-expressions in the syntactic sense, and leverages this in ways that are pleasant to a Lisp user. It is not a Lisp. Clua is Lua. Lua provides a more powerful semantics in the form of tables. 

Lisps proper rely on a particular implementation of the tuple, one which happens to be fast on early hardware. For fast, we have LuaJIT, which erases most of the already low overhead of table lookups. 

We don't disguise the fact that we have tables upon tables, and the ability to return multiple unstructured values. We revel in it. 

## Incremental Transpiler

The intention is that Clua is translated to Lua by reading, constructing the AST, and transforming the structure into the minimum necessary amount of Lua. No whole-string representation of the program is generated and there are no line errors from the Lua interpreter. 

The result is an ordinary Lua environment. Code which translates down to chunks is called in the global context, functions and other values are entered into the environment, and so on. 

I'm still studying precisely how to do this, but I expect it to prove tractable.  
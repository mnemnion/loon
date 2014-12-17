#<Node>

The Node metatable ends up being a central Loon idiom. Let's design it carefully.

##Metamethods

###__call

Calling an AST node compiles it  and executes it, with the evaluator specified by the reference node. An AST is normally generated with a particular kind of evaluation in mind, so we attach that intention to the reference node. 

This compilation happens once, and the result is memoized. `__newindex` on any node is responsible for clearing the function cache on all upstream nodes. 

###__newindex

as mentioned, `__newindex` is responsible for checking for cached functions in upstream nodes. It is also responsible for making sure that the reference index is updated, back references are maintained, region information in the tree is correct, and so on. 

Hopefully we can have a cheap __newindex for generating ASTs from the flats, and an expensive one for modifying existing ASTs.

If we add Cor and Cow, which may not prove necessary, __newindex will have to handle those types. 
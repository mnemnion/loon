#<Node>

The Node metatable ends up being a central Loon idiom. Let's design it carefully.

##Metamethods

###__call

Calling an AST node compiles it  and executes it, with the evaluator specified by the reference node. An AST is normally generated with a particular kind of evaluation in mind, so we attach that intention to the reference node. 

This compilation happens once, and the result is memoized. `__newindex` on any node is responsible for clearing the function cache on all upstream nodes. 

use this wisdom: % t = setmetatable({a=1},{__call=function(self, a, b) print(a, b, self.a) end}) t("asdf", "foo")

###__newindex

as mentioned, `__newindex` is responsible for checking for cached functions in upstream nodes. It is also responsible for making sure that the reference index is updated, back references are maintained, region information in the tree is correct, and so on. 

Hopefully we can have a cheap __newindex for generating ASTs from the flats, and an expensive one for modifying existing ASTs.

If we add Cor and Cow, which may not prove necessary, __newindex will have to handle those types. 

### __add

adding concatentes two Nodes into a new Node.

### __tostring

Rewrite to use the index. 


### copy

Copying: Make a new table, copy anything that isn't an index or a backref, add all children in the same fashion, then walk the new bare AST to decorate it with an index and proper back references. Include a 'back' 

#Todo for loon

##AST

###0.2

Add weak-table back references to parent node. Ideally we do this by adding to the constant time of the parse on match. I can't find a good way yet, so I'll make this a separate walk. 

Add an AST metatable for nodes that does this automatically. 

Write rule-based validator for resulting decorated AST. This will become complex when we want to include literal tables in our AST. This is one reason we attach a metatable to nodes, so as to provide a way to differentiate them from tables created during AST transformation, which will be common elements.

write a Unicode-aware replacement for lpeg.S, capable of detecting the uniqueness of characters within a string. This was made cheap on purpose, and is a refreshing exercise I can crib from the internet.

###0.3

Write a PEG front end that generatively creates various LPeg contraptions. Examples:

Memoizing an index of each node in the order visited. This aids debugging and makes flattening trivial.

Region encoding of each node, so that it contains the full span matched, not just the furthest cursor position. This should be standard in AST building.

The index and memoizing functionality should be separate, opt-in, YAGNI stuff. That's the philosophy of the PEGylator in general.

With index and region added, a flexible, rule-based error report can be generated. The weak tables let us look at parents and grandparents. It all kinda hangs together. 
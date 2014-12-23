#Forest

The Forest metatable is applied to vectored, borrowed Nodes.

##Principles

A Forest is flat. Selecting over a Forest of Nodes produces another Forest, not a nested Forest of Forests. 

A Forest, if it has an index, is presumed to contain Nodes belonging to that root. If an index is not provided, it must be retrieved individually for each Node. 

##Metamethods

##select(id)

Selects and unpacks all Nodes matching `id` from within all Nodes of the Forest. Returns a new Forest containing these Nodes. 

##__tostring

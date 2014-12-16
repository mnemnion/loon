#PEGylator

I'm well on my way to capturing grammars for the PEGylator. Now to plot out the necessary transformations.

##Side balancing

All left-hand references reachable from the start rule are detected. The rest are marked dead.

All right-hand references in living rules must have a left-hand definition.

##Recursion detection

We cycle-count the tree, separating rules into regular and recursive. 

## Code generation

Our template is based on epnf. 

We make all regular rules into locals in the generated module, and import them into the function's scope explicitly.

We organize all recursive rules in the order discovered by the grammar. The only constraint on `.peg` syntax is that the first rule is the top rule. Ordering the grammar makes it easier to figure out what PEGylator has done with it. 

The code templates are just a vector of engines, all of which are called and the resulting functions packed into another vector. The user may add to the engine list, and `nil` out any engines she doesn't need. Modifications to existing engine code which change the semantics are discouraged, please copy-paste the code and rename the engine accordingly. 

Code gen can write to files, or just load the string, configurably. 

###Steps

All regular rules are defined outside the context, as lpeg.P patterns. They are redefined in the calling context as P pr C as appropriate to the engine.
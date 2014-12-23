#PEGylator

I'm well on my way to capturing grammars for the PEGylator. Now to plot out the necessary transformations.


##Critical Path

- Recursion Sorting

- Rule Transformation

- Templating

###Nice to have

- Side Balancing

##Side balancing

All left-hand references reachable from the start rule are detected. The rest are marked dead.

All right-hand references in living rules must have a left-hand definition.

##Recursion detection

We cycle-count the tree, separating rules into regular and recursive. 

Specifically: we generate a table. LHS is the rule name, RHS is everything that rule calls. 

We start with an LHS, and count: tabulate the RHS, lookup each on the LHS, tabulate the RHS, and continue. 

Naturally, we refrain from visiting anything on the LHS more than once. We mark these rules as cyclic.

All rules marked cyclic are transformed with a cyclic template, all other rules with a regular template. 

## Code generation

Our template is based on epnf. 

We make all regular rules into locals in the generated module, and import them into the function's scope explicitly.

We organize all recursive rules in the order discovered by the grammar. The only constraint on `.peg` syntax is that the first rule is the top rule. Ordering the grammar makes it easier to figure out what PEGylator has done with it. 

The code templates are just a vector of engines, all of which are called and the resulting functions packed into another vector. The user may add to the engine list, and `nil` out any engines she doesn't need. Modifications to existing engine code which change the semantics are discouraged, please copy-paste the code and rename the engine accordingly. 

Code gen can write to files, or just load the string, configurably. 

###Steps

All regular rules are defined outside the context, as lpeg.P patterns. They are redefined in the calling context as P pr C as appropriate to the engine.
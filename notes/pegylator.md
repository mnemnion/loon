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

We start with the top rule, which is always the first rule. We index it in a new vector, and add all the RHS rules to a set that is the value of the index. We index by rule name, which must be unique; we will build that check in later. 

We then go to the next rule, and add all the RHS to its visited category. 

We proceed down. We visit each rule once, and compare/add the RHS buckets to the LHS set. We then sweep through: sets which are self-referential, are self-referential. Every time we add a recursive LHS in a sweep, we have to check every RHS to see if the LHS is called, if so, the LHS of that RHS is also recursive. 

All rules marked recursive are transformed with a recursive template, all other rules with a regular template. 

## Code generation

Our template is based on epnf. 

We make all regular rules into locals in the generated module, and import them into the function's scope explicitly.

We organize all recursive rules in the order discovered by the grammar. The only constraint on `.peg` syntax is that the first rule is the top rule. Ordering the grammar makes it easier to figure out what PEGylator has done with it. 

The code templates are just a vector of engines, all of which are called and the resulting functions packed into another vector. The user may add to the engine list, and `nil` out any engines she doesn't need. Modifications to existing engine code which change the semantics are discouraged, please copy-paste the code and rename the engine accordingly. 

Code gen can write to files, or just load the string, configurably. 

###Steps

We want to proceed 'inside out'. The first step is to convert all atoms to Lua-standard format, by replacing all `-` with `_`. Then, the RHS atoms that correspond to recursive rules are replaced `modified_symbol -> V"modified_symbol"`. 

Next, we perform all atomic conversions, turning `symbol?` into `symbol^-1` and so on. These compose over our already modified atoms. Where necessary we throw parentheses at the problem. 

Next, we impose captures over the appropriate rules. This is moderately complex, and we do it differently for different engines. It may suffice to impose a single abstract "capture" function over all captures, assigning it differently when generating the different engines. It may not.

The step after this is assembling the compounds by adding `*` for concatenation and `+` instead of `\`, while reimposing parentheses. We then glue our rule pieces into the necessary context, and place them into either the recursive or regular slot of the template. 


All regular rules are defined outside the context, as lpeg.P patterns. They are redefined in the calling context as P pr C as appropriate to the engine.
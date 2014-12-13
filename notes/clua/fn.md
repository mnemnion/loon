#fn

`(fn)` has a couple argument forms, to account for type annotation. 

`(fn [])` is the usual, specifying a vector of arguments, with optional type annotations.

`(fn { args, <Type> })` specifies a type for return value(s). I believe the syntax for multiple atomic return values is `(fn { args, \<Foo> <Bar> <Baz>/ })`. Looking at it, it has a clarity to it. I'm settling into this idea. 

I don't *think* it's really meaningful to to have more than one key/value pair for this case, so that's a syntax error. Since fn is a macro this can be enforced. 
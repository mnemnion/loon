#Codegen

Time to stop tinkering with the base classes and start doing codegen.


##Symbol Transformation

All atoms get rewritten in Lua form. 

Done.

## Recursion Detection

Rules are sorted into regular and recursive form. Done.

## Atomic transformations

This is detailed work but conceptually straightforward. 

For each type of 'simple' rule, we rewrite it to have an LPEG equivalent.

Examples:

` foo = bar*  ->   foo = V"bar"^0 `

` foo = bar+   ->   foo = bar^1 `

` bar?  ->  bar^-1 `

` bar$2  ->  (bar * bar) `

` bar$2..5 -> (bar * bar) * bar^-3 `

` -------------`

` !bar  ->  -bar `

` &bar  ->  #bar `  
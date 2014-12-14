#PEG 

Clua, Lun, and the ported MoonScript should have only one dependency for their compiler, namely the lpeg library. Happily, MoonScript's only dependency is currently lpeg. 

No coincidence, generating PEGs with a rich functional syntax allows for Turing-complete recursive descent parsing, which is, ahem, all you need. More, often. The downside of the approach is that it's work to reuse grammars. One can't simply share them and generate any number of consistent parsing programs using that grammar. 

This functionality is essential to the `<Syntax>` type in Clu, which generates abstract syntax trees from arbitrary data. 

##Things we can make from a grammar

The idea is that by feeding an abstract grammar to the PEGylator, we automatically generate templates for several uses of that grammar. There are a few important ones.

A string validator. This parses the string entirely with matches, returning nothing, retaining nothing, and ultimately rendering a boolean judgement, surrendering all cursory data to the garbage collector. Fast. 

A scanner, which validates a string and provides region information in a vector, without copying anything from the string.

A parser, which creates a consistent type of abstract syntax tree out of the grammar. 

And a table validator, which can take an AST from that parser, and validate the information as something which could have at one time conformed to that grammar. This one is tricky because we allow elision of rule nodes and literal strings, which means we must know when both nodes and leaves can be missing as well as when they must be present. I think we just remove them from the grammar but haven't proven it to my own satisfaction. 

Let's also make a registry, so our error messages can refer to nodes and leaves in their grammar form, not their functionalized Lua equivalent. `expected: form* "#";   got: "^" is how we want an error to read. 

## Standard PEG Syntax

We want our PEGs to look familiar. I like Instaparse, personally, and I think a coroutine-based GSS is at least possible. Certainly a fast Rust GLL could be linked and loaded when I get around to writing it. But in the meantime, we want something like this:

```text

rule :  concatenated rule          concatenated * rule

rule : ordered / rule               ordered + rule

rule : optional* rule ; greedy      optional^0 rule
 
rule : \lazy-optional rule           -- Don't have?

rule : at-least-one+ rule            at-least-one^1

rule : one-or-zero?                  one-or-zero^-1

rule : exactly$2                     exactly * exactly

rule : more-than-two$+2               more-than-two^2

rule : no-more-than-two$-2           no-more-than-two^-2

rule : a-number-between$2..5          -- fake it.

rule : !not-this rule                rule - not-this

rule : -not-this-period              -not-this-period   

rule : &if-also-this rule              #if-also-this

rule : [a-b]                            R"ab"        -- customized

rule : {set-rul}                        S"set-rul" -- needs the Unicode treatment
 
rule : "literal rule"                 P"literal rule"

<hidden rule> : <hidden output>       SUPPRESS "hidden rule"

```

So what does that look like exactly? Something like this:

```

     rules : rule+

      rule : _lhs_ ":" _rhs_

       lhs : symbol

       rhs : "(" match+ ")" rhs* / match+ rhs*

     match : ord-match / _atom-match WS 
     -- I believe this provides precedence to cat

 cat-match : (match _)+

 ord-match : match "/" match   -- so a b c / d e f groups (a b c)/(d e f)

atom-match :  option               ; note, this order is not meant to be efficient. 
           /  lazy 
           /  at-least 
           /  single 
           /  exactly 
           /  no-more-than 
           /  between 
           /  not-this
           /  not-this-period
           /  if-also-this
           /  range
           /  set
           /  literal 
```

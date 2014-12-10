#PEG 

Clua, Lun, and the ported MoonScript should have only one dependency for their compiler, namely the lpeg library. Happily, MoonScript's only dependency is currently lpeg. 

No coincidence, generating PEGs with a rich functional syntax allows for Turing-complete recursive descent parsing, which is, ahem, all you need. More, often. The downside of the approach is that it's work to reuse grammars. One can't simply share them and generate any number of consistent parsing programs using that grammar. 

I don't need this tool for Clua, or even for Loon, exactly. But it will make using Loon to do any old crazy nonsense easier, and besides, I want this tool for Clua. 

## Standard PEG Syntax

We want our PEGs to look familiar. I like Instaparse, personally, and I think a coroutine-based GSS is at least possible. Certainly a fast Rust GLL could be linked and loaded when I get around to writing it. But in the meantime, we want something like this:

```text

rule :  concatenated rule

rule : ordered / rule 

rule : optional* rule

rule : at_least_one+ rule

rule : !not-this rule

rule : ?if-also-this rule

```
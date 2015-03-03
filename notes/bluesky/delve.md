#Delve

I don't know if it's my destiny to write syntactic skins. Other than the CoffeScript and MoonScript fellows, the notion isn't popular. 

It's actually more popular than that, but most of them are sold as new languages. Adherence to the original semantics isn't normally considered a virtue.

Okay. Delve is a Clu project off the main path but damn, I really want it. It's an s-expression C.

Why? Well, C is great and every extension of it is an attempt to automate things that are idiomatic in C. Also conditional compilation really suck in C, which is a painful state of affairs for a metaassembler.

Nothing ANSI C provides is available as a runtime. Anything else is more like a preprocessor than a compiler, though since it's all in S-expressions and the compile time stage is Lispy two times over, since it's run by Clu and it's Sexprs. You could call it SexC and I wouldn't stop you but the name is Delve. I'll let you guess why. 

There's not much to add except I intend to use cryptics: Anything in the standard keyword plane can be written using two or three glyphs in combination. Everything built out of letters is available to the user, redefining cryptics must be flag enabled and is normally illegal. This is a tool for advanced users. Cryptics are exactly equivalent to their plain English cousins and you can filter them into such if you insist, just watch your namespace hygiene.
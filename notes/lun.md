#Lun

Lun is pronounced `lun` in IPA. Americans, you would say "Loon". Please don't call it luhn. You will make me super sad. Think Lūn, we will probably stylize in that fashion. 

Clua is one pillar of the Loon environment. The second is Moonscript. The third begins as Lua. We turn it into Loona.

Loona is Lua, empowered by our silly-putty syntax to be useful to our nefarious purposes. In particular, I want Loona to function as a command-line scripting language for a Unix shell.

This justifies our first change, which will make many serious Lua heads happy: There is no `local` keyword, at all. Implicit declaration of a variable creates it in the local context, always. I will probably choose to use the word `global`, to stay in the Lua paradigm, which never uses abbreviations. 

This is absolutely necessary in a command-line scripting language. The global environment must be protected, and the logic the shell will use to persist and maintain aspects of the global environment after executing a script will be moderately complex. Global pollution is bad news in any case, leading to more heartache than the inevitable "where's x? I defined it right there!"

I am tempted to replace `function` with `fn` and use `pub` for global, because I hate typing. But this is Lua; no one learning to program for the first time should have to say "what do 'fun' and 'pub' mean?" and it's practically a sin to increase the semantic load of reading Lua, which generally does what you expect. 

If you want to add a bunch of abbreviations to Luna, or translate all the keywords into Dutch, just change the grammar and write a syntax transform to express the new semantics. The IR will be completely consistent, just target it. Or you can use the macro system, since Loona passes through an IR and can have a reasonably powerful (for an Algol) macro system.

If you like macros, however, I urge you to just use Clua. It's designed for that. 

Changes to Loona will be mild, and will be Lua compatible by definition. That is, Loon will always run Lua if coerced, and any Loona (or Clua, or Moonscript) will interact with ordinary Lua in reasonably consistent ways.

##Shell and Program syntax.

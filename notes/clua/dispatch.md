#dispatch

**dispatch** is the name of a little language and program in the Loon environment. It is a key component. 

**dispatch** will become moderately complex, and may not be the same function in all contexts. We're discussing Clua here, so we'll stick with that for now.

Clua has a syntax boundary token, `|`, which immediately stops parsing, consuming the token, and calls dispatch. 

The first thing dispatch does is try and parse as Lua. If it sees a comment-bang immediately, `--!`, dispatch continues to read up to the next whitespace character not found enclosed in a string. If it hasn't decided to do something else by then, it continues to parse using Lua. 

Any reader in the Loon ecosystem is expected to co-operate with dispatch at all times. Eventually, and I mean as soon as I can get proper cooperation with LPEG, this will be done with coroutines. Basically, the parser will be expected to yield in sensible places. These needn't constitute valid parses on their own.

One of the uses of the syntax boundary that has me salivating is statements such as `(let y | 4*x^3 - (3+g/torque)x^2 | )`. Here, we're expecting Clua to provide the left hand of an assignment, and Loona to provide the right hand. The parse contained between the `|` marks is strictly speaking a syntax error, since Lua has RHS and LHS rules in its grammar, and certain constructions cannot be found on the LHS. 

**dispatch** makes sure this all works correctly. Syntax errors are deferred until the construction of a block is complete, at which point the AST is inspected, and dispatch tries to find the source of fault if there is one. 

## Dispatching dispatch.

**dispatch** has special behavior when it encounters a comment-bang. This is familiar syntax for a command shell, purposefully. If dispatch encounters lowercase latin letters up to a whitespace, it looks this string up to see if it has a reader with that name. A release version of the Loon environment ships with `clua, lua, moon, loona` as basic options. 

MoonScript is really cool and I'd like to sugar it slightly, so a line of the form `|--|` followed by a newline is a block of moonscript. The closing idiom is `--|`, the comment parser is expected to check this. Moonscript is a language with meaningful whitespace, so we enforce a syntax requiring it to have its own line structure. Anything else would be confusing. 

Technically anything can come between the `|--|`, dispatch treats that line as a comment. 

Back to bang dispatch. If dispatch encounters a string after the comment-bang, it treats this as a file in the current context, and tries to load it as a syntax reader. We will provide a version of dispatch that can't do this, it's a convenience to the developer. 

## Ending the Parse

Therefore, we want to `yield`-on-match whenever possible. This is possible anytime the syntax can't expect a `|`.

Lua doesn't use the `|` operator for anything, making it a convenient symbol in context. Clearly the parser won't yield in the middle of a string, and that's the only valid place to find one. 

What if we want real problems, and add `|` as the syntax boundary marker for Loona? How could dispatch possibly figure out what's going on, how could it tell a new syntax context from the old one? 

Well, in Loona, a bare `|` means 'start parsing as Clua'. So there's no difference between the yields in this case.

Incredibly, MoonScript doesn't use `|` either. I guess it just isn't useful in a Lua context, unless you have syntax boundaries you want to enforce.

On the other hand, many useful languages make use of `|`. Happily, a language without some kind of syntax error is truly unusual. The reader is responsible for detecting the end-of-parse boundary, and consuming everything up to, and requisitely including, a `|`. **dispatch** always consumes the last `|`, while the first one is consumed by the reader which calls dispatch. 

And now you've met the syntax boundary marker. Behold its remarkable power. Gaze upon it. Remember macros? Remember them? Yeah we have them too. In Clua, and in Lun. 
#dispatch

**dispatch** is the name of a little language and program in the Loon environment. It is a key component. 

**dispatch** will become moderately complex, and may not be the same function in all contexts. We're discussing Clua here, so we'll stick with that for now.

Clua has a syntax boundary token, `|`, which immediately stops parsing, consuming the token, and calls dispatch. 

The first thing dispatch does is try and parse as Lua. If it sees a comment immediately, `--!`, dispatch continues to read up to the next whitespace character not found enclosed in a string. If it hasn't decided to do something else by then, it continues to parse using Lua. 

Any reader in the Loon ecosystem is expected to co-operate with dispatch at all times. 
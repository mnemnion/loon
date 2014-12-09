#Syntax

Numbers begin with a digit. If that digit is zero, one Unicode alphabetic code point may specify characteristics of that number. If the meaning is not recognized by the reader, the number is interpreted as decimal, or is an error. A reader must recognize `b,d,x`, representing binary, decimal, or hexadecimal. For `b`, the valid continuations are `0` and `1`, for `d` `0-9`, for `x`, `0-9A-Fa-f`. Any other leading digit, or a zero followed by another character in...blah blah

Symbols contain any valid alphanumeric in Unicode, plus at least `!?-_*+=&^`. They may not contain `(){}[]<>/\`, which are reserved for pairs, nor `` `~'" ``, macros and strings, nor `,`, which is whitespace, nor `;`, which begins comments. `:` at the beginning of a symbol makes it a keyword. They must not begin with a digit, after which much leniency is shown.


##Characters

The following describes the behavior of the Clua reader with respect to various characters. 

The outer context is assumed, unless otherwise stated. 

###Whitespace

The characters space, newline, comma, and tab, denoted `\s \n , \t` are whitespace in Clua. 

Tabs are deprecated. 

###Single Tokens

The characters ``. ` ~ ; : ' " # |`` are not valid in symbols. If encountered, the parsing of the symbol will end. 

`.` represents field access. 

`` ` `` and ` ~ ` quasiquote and unquote within the macro system.

`;` begins a comment, which ends with a newline. 

`:` must be followed by a valid symbol, which may not be separated by whitespace. This is a keyword.

`'` quotes the following form.

`"` begins and ends strings, with `\` as an escape character for `"` in this context.

`#` is a signal to the reader, which has various effects on the following form. 

`|` is reserved syntax.

### Paired Tokens

The characters `( ) [ ] { } < > \ /` are not valid in symbols. They must be balanced: Any left member of the set
must receive a right member of the set, in the order encountered by the reader, across all pairs. To illustrate, `({})` is valid `({}` is invalid, and `({)}` is invalid also. 

`( )` constitute a list. 

`[ ]` constitutes a vector. 

`{ }` constitutes a table. 

`< >` is reserved syntax, intended for type annotation.

`\ /` is reserved syntax. Note that the backslash begins, and the slash ends, a pairing. `\o/`
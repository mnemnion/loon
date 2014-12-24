#Syntax

Clua is defined in UTF-8 format.

#Reading

The following describes the behavior of the Clua reader with respect to various characters. 

The outer context is assumed, unless otherwise stated. 

###Whitespace

The characters space, newline, comma, and tab, denoted `\s \n , \t` are whitespace in Clua. 

Any member or quantity of the set is allowed where indicated, and will not affect semantics.

Tabs are deprecated. 

##Single Character Tokens

###Unary Tokens

The characters ``.  @ ` ~ ; : ' " # |`` are not valid in symbols. If encountered, the parsing of the symbol will end. 

`.` represents field access in a symbol, or the decimal in a numeric context. It is invalid in the outer context.

`@` represents method access within a symbol, or as a prefix, method access to the first argument of a function. 

`` ` `` and ` ~ ` quasiquote and unquote within the macro system.

`;` begins a comment, which ends with a newline. 

`:` must be followed by a valid symbol, which may not be separated by whitespace. This is a keyword.

`'` quotes the following form.

`"` begins and ends strings, with `\` as an escape character for `"` in this context.

`#` is a signal to the reader, which has various effects on the following form. 

`|` marks a syntax boundary.

### Paired Tokens

The characters `( ) [ ] { } < > \ /` are not valid in symbols. They must be balanced: Any left member of the set
must receive a right member of the set, in the order encountered by the reader, across all pairs. To illustrate, `({})` is valid, `({}` is invalid, and `({)}` is invalid also. 

`( )` constitute a list. 

`[ ]` constitutes a vector. 

`{ }` constitutes a table. 

`< >` constitutes a metatable. 

`\ /` destructures the enclosed element. Note that the backslash begins, and the slash ends, a pairing. `\o/`

## Atomic Tokens

Atomic tokens translate to semantic atoms, that is, data which is singular under most conditions. 

### Symbols

The reader, encountering any character not previously defined, will attempt to construct a symbol. 

If it encounters a character in the range `[0-9]` it will fail to do so. If it encounters `-` and a digit, it 
will also fail.

A symbol is guaranteed to be valid if it begins with a Latin alphabetic character, and continues with any valid alphanumeric code point in Unicode. Any single character token immediately ends the symbol. 

A symbol may also contain at least `!@$%?-_*+=&^`, which are allowed to begin symbols also.

Currently undefined behavior: beginning a symbol with a non-Latin alphanumeric, or including Unicode characters outside of the defined alphabetic ranges. The former requirement will likely be relaxed, the latter is unlikely to be checked for. 

The reader is fairly permissive in terms of the symbols it will accept, currently accepting all undefined behavior. The reader and runtime environment are strictly literal, defining symbol equivalence in terms of the UTF-8 sequence accepted.

### Numbers

The reader will attempt to make a number if it fails to make a symbol by encountering characters in the range `[0-9]` or `-`. 

If the character is `-`, the reader will attempt a decimal negative number.

If the character is a `0`, the reader will first look for a radix, which is any valid Unicode alphabetic code point. `b, d, and x` have predefined meanings, providing binary, decimal, and hexadecimal decodings respectively. `i I e E` are not interpreted as radices. All other lowercase Latin characters are reserved and may not be redefined by a valid runtime.

An unrecognized radix will provoke the reader to look for a decoder matching the radix value. If this fails it defaults to decimal behavior. The absence of a radix is decimal by default. 

If the decimal reader encounters a `.`, it will resolve the digits following the decimal as the fractional value. `e E` interpret the following digits as an exponent. 

The character `/` encountered in a numeric context is reserved for represention ratios. The characters `i I` are reserved to represent the imaginary component of complex numbers. They are currently syntax errors in the numeric context.

Any numeric decoder will stop immediately upon encountering whitespace, or any unary or paired character other than `.`, `/` or `-`. A safe implementation of the reader should parse the input stream by this rule before passing the string to the decoder. 

### Strings

The reader, upon encountering a `"`, will construct a string. It does so by accepting all input, including the digraph `\"`, or any odd number of `\` followed by `"`, until encountering the paired `"`. This pattern is expected to be familiar.

The reader specification does not provide an internal format for strings, other than to indicate that they should be valid UTF-8. The implementation expects the internal format to follow that of Lua. 

###Keywords

`:` begins a keyword. It must be followed by a symbol, with no whitespace. 

Keywords are always equal to themselves, and never refer to another value. 

#### Reminder

Behavior described is in the outer context unless otherwise specified. Several single character tokens change that context in indicated ways.

## Compound Token Groups

Compound groups of tokens translate to semantic forms. These forms necessarily include atoms, as such, an atom is semantically also a form. 

### Lists

The token `(` begins a list, which may contain any form and is delimited by a closing `)`. The semantics are similar to those of Lisp, with potentially different properties, particularly in O(n) complexity. 

### Vectors

The token `[` begins a vector, which may contain any form and is delimited by a closing `]`. A vector is index-addressable, compact, and follows the Lua convention, where in `1` is the first element, `-1` is the last, `0` is off the index, and so on. 

It is a semantic error to treat a vector as having other characteristics, though due to the Lua runtime, this may not be possible to prevent. 

### Tables

The token `{` begins a table, which may an even number of forms and is delimited by a closing `{`. The odd forms are interpreted as keys and the even forms as values, in keeping with Lua's vexing yet familiar convention of denoting the first element with `1`. 

The underlying representation of lists and vectors may be a table, and normally is, given Lua. The semantics of Clua will not normally subvert this. 

## Types

`<` and `>` mark a type annotation.  `<>` is the empty metatable.

The mathematical `<` and `>` are `lt` and `gt` respectively. `<=` and `=>` are `lte` and `gte`. `<=>` returns the type `Operator`, which is a metatable. 

## Destructuring

Lua provides multiple return values, Lisps canonically do not. `\ foo bar baz /` returns all of foo, bar, and baz. `\(function foo bar)/` returns all of the return values of `function` to the context, `(function foo bar)` returns only the first. `(/ foo bar)` performs division and is not a syntax error. `div` is a synonym, so `(let {a,b,c} \'(div 2 3)/)` won't create a parse error. The values will be `a <- div, b <-2, c <-3`.

##Reader-Modifying Tokens

Certain tokens modify reader behavior. These are briefly described here.

###Quoting

The `'` character quotes the following form. The effects of this depend on the form, the transform happens at the reader level. 

`` ` `` and `~` are part of the macro system. That's what I have today. I have to go over all the macro systems very carefully, to repea^H^H^H^H^H avoid the previous mistakes. 


###The Hash Modifier

The `#` character, in general, modifies the following form. 

`#{}` produces a set. Unlike a table, a set does not require paired forms within the region. 

`#[]` produces a ring. A ring is a vector, with a zero element, which may be indexed modulo its length. 

`#!` is reserve, causing the following form to be immutable. 

`#_` causes the following form to be parsed and immediately discarded. 

`#!#{}` creates an immutable set. `#_#!#{}` parses and discards an immutable set without creating it. `#!#_#{}` is a parse error, because there is a hash-modifier context and that statement doesn't make sense. 

The Clua reader may not currently be extended by the runtime to use the `#` modifier. At least not legally. But that doesn't matter because of

###The Syntax Boundary Marker

Of which I'm proud. Or will be when I write it.

`|` in the outer context immediately surrenders the reader to another reader, called dispatch. Dispatch is a little language that decides what to do with the rest of the input stream. This will fall through to a very close cousin of Lua, initially, Lua itself. 

The resulting program can do anything at all, but should be programmed to parse conservatively. As soon as it's done doing something reasonable, it should hand back over to the reader, which will look for another `|`. If it doesn't find one, it just hands control back over to the new syntax handler. 

One doesn't want to hand control back over at a place where the enclosing language allows for a `|`, for reasons that should be clear. The dispatch little language provides some sugar for these cases. The average user is not expected to design entire syntaxes; the macro system will be more than adequate for that purpose, and there will be at least three provided. 

### Comments

Comments begin with `;`, continuing to the end of the line. 

Comments containing more than one `;`, with only whitespace between the `;` and the preceding newline, should be formatted in Markdown and otherwise conform to Clua documentation conventions. 

The Clua runtime discards comments, which hold no place in the resulting syntax tree. 

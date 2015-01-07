#Keywords

Clua offers keywords. They could not be simpler to implement in Lua. 

The Clua environment provides an ordinary table called kw. It provides a function to look up a keyword, which it memoizes as a key in the table, returning an empty table as the value. The next lookup will return the empty table, which is locked and cannot have contents without shenanigans. The table is also interned as a key, the value of which is the string. 

Looking up the table gives you the string, looking up the string gives you the table. From a Lua perspective, keywords don't have a colon, so for many keywords `keyword` will work. That looks like `:keyword` in a Clua context, this is for interoperability. 

Do you pass a keyword as a string or as a table? Table. I'm fairly sure that the equality of two tables is an order of magnitude faster than the equality of two strings, and don't want to rely on JITting this away. 

Note that to use keywords 'by hand' in Lua, you must first generate them. In Clua keywords exist as soon as you mention them, since they're syntax. Code generated within the Clua environment will have no need to lookup the string values of keywords, in general. 

This isn't normally a problem, since if you're using keywords, you're probably interoperating with a Clua library, since there's little point in having them in Lua. So your keywords are provided, and most likely interned. Also in Loona, you can break out into Clua any time you desire, so defining up a few keywords is as simple as creating a vector that mentions all of them. The vector will be garbage collected but the keywords will remain interned for later use. 


#NSML

Not Stupid Markup Language is very simple.

The document is analysed prior to markup, to identify unique pairs that aren't used, in a specific order. 

We then pick the simplest possible brace pair that can possibly work. This will often be `«»`, unless you're parsing Clu.

We then use that to enclose all semantics. Everything within a brace pair is a tag, there are no attributes in the markup.

The entire document is enclosed using this marker. The parser reads anything before the string `doc` as the opening symbol. All opening symbols are deterministically paired with the closing symbol. 

Note that this recursively marks up itself, is guaranteed to work in all cases, avoids the ambiguity between tags and attributes, and is dead simple to parse. A working implementation would actually prefer paired control sequences, which are one byte and seldom found inside texts, being unprintable by definition. It is a simple matter to select a distinct representation for viewing the resulting document, which was probably also compressed before being sent. In any case, faster by far than HTML, due to the lack of attributes.

The End. 

####footnote

It is not generally possible for an assailant to determine in advance of receiving a document what the markup pairs will be. This makes static injection inconvenient. 
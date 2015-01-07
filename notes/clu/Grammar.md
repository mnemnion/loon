#Grammar

This is the grammar of [clu](clu.md), expressed in the form in which it will, eventually, be compiled.

```text

     clu :  form* / EOF

      form :  [unary]* (_atom_ / _compound_) / _<comment>

     unary :  ","
              /  "~"
           /  "`"
           /  reader-macro

      atom :  symbol 
           /  number 
           /  keyword
           /  string

  compound :  list
           /  hash
           /  vector
           /  type 
           /  syntax

   symbol  :  latin !(forbidden) ANYTHING
   keyword :  ":" symbol

    list   :  "(" form* ")"
    hash   :  "{" form:2* "}"
    vector :  "[" form* "]"
    type   :  "<" form* ">" 
    multi  :  "\" form* "/"
    syntax :  "|" dispatch* "|"

  dispatch :  "--|" moonscript "|--" 
           /  "--!" dispatch-string 
           /  lun
       lun :  !"|" ANYTHING    ;-) looks like lua!  
moonscript :  !"|" ANYTHING    ;-) looks like moonscript!

     latin :  ([A-Z] / [a-z])
 <comment> :  ";" !"\n" ANYTHING "\n"
```

... I think that's it. I didn't specify what can't go into a symbol in much detail. None of the quoted literal forms, that's for certain. Actually, "--!" is the sole exception to this, that is a valid character string within a symbol.

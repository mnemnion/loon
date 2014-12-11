#Grammar

This is the grammar of Clua, expressed in the form in which it will, eventually, be compiled.

```text

     clua :  form* / EOF

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
    vector :  "[" form "]"
    type   :  "<" form ">"
    syntax :  "|" dispatch "|"

  dispatch :  "--|" moonscript "|--" 
		   /  "--!" dispatch-string 
		   /  lun
       lun :  !"|" ANYTHING    ;-) looks like lua!  
moonscript :  !"|" ANYTHING    ;-) looks like moonscript!

     latin :  ([A-Z] / [a-z])
 <comment> :  ";" !"\n" ANYTHING "\n"
```

... I think that's it. I didn't specify what can't go into a symbol in much detail. None of the quoted literal forms, that's for certain. 

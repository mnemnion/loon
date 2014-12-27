local g = {}

 g.range_s = [[ \]\--CD ]]
 g.symbol_s = "rgsr09gao--ijf-sdfkrtjhaADSFASDFAr"

 g.set_s   = [[ abc\def\}g䷀䷁ ]]
 g.string_s = [[ asldfr\"adf  asdf\asdf]]
 g.grammar_s = [[ A : B C ( E / F ) / F G H
			  I : "J" 
			  K : L* M+ N?
			  O : !P &Q -R
			  <S> : <T (U V)>
			  W : {XY} [a-z] 
			  A : B$2 C$-3 D$4..5 E$+4]]

 g.deco_s  = [[ A: <-(B C/ D)$2..5*> ]]
 g.rule_s  = [[A:B C(D E)/(F G H)
			  C : "D" 
			  D : E F G
]]

 g.peg_s = [[
	rules : rule +
	rule : lhs rhs
	lhs       =  _pattern_ ":"
    rhs       =  element more-elements
	<pattern> =  symbol / hidden-pattern
	hidden-pattern =  "<" symbol ">"
	<element>  =  match / factor
	more-elements  =  choice  /  cat / ""
	choice =  _"/" element more-elements
	cat =  WS element more-elements
	match    =  -lhs_ (compound / simple) 
	compound =  factor / hidden-match 
	factor   =  _"("_ rhs_ ")" 
	hidden_match =  _"<"_ rhs_ ">"
	simple   =  prefixed / suffixed / enclosed / atom 
	prefixed =  if-not-this / not-this / if-and-this
	if-not-this =  "!" symbol
	not-this    =  "-" symbol
	if-and-this =  "&" symbol
	suffixed =  optional / more-than-one / maybe
	enclosed =  literal / set / range
	literal =  "\"" (string / "") "\""  
    set     =  "{" set-c+ "}"   
    range   =  "[" range-c "]"   
	optional      =  symbol "*"
	more-than-one =  symbol "+"
	maybe         =  symbol "?"
    atom =  symbol / ws 
    ws = "_"
]]

 g.clu_s = [[

     clu :  form* / EOF

      form :  unary* (_atom_ / _compound_) / _<comment>

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
    hash   :  "{" form$2* "}"
    vector :  "[" form* "]"
    type   :  "<" form* ">" !type form
    syntax :  "|" dispatch* "|"

  dispatch :  "--|" moonscript "|--" 
           /  "--!" dispatch-string 
           /  lun
       lun :  !"|" ANYTHING    ;-) looks like lua!  
moonscript :  !"|" ANYTHING    ;-) looks like moonscript!

     latin :  ([A-Z] / [a-z])
 <comment> :  ";" !"\n" ANYTHING "\n"

]]

return g
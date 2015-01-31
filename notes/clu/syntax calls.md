# Ways to use a syntax

```clojure

; default, uses Lun and returns to Clu
(fn [] | return 3 + 4 |)

; eval style
(fn [] (eval |"3 + 4"|))

; with-syntax

(with-syntax lua (| global = require "module.lua" |))

; eval-with
(eval-with lua "global.value = false")

; these combine like so

(with-syntax lua 
  (do 
    (stuff to things) 
    (eval «(set str "this is Clu"»))
    (| local this = lua
       return this |)))

```
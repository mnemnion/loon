#Rationale

Here you are, in a code repository nurturing what appears to be another programming language. 

[For the love of God, why?](http://en.wikipedia.org/wiki/List_of_programming_languages)

Short answer: we wish to replace `bash` and `emacs`, while modestly extending the xterm protocol. That's the purpose of Clu, Lun, and the Loon ecosystem generally. They should be a pleasant toolkit to work within, as a result of this design choice. 

`bash` and `emacs` are both programming languages. `bash` is referred to as a 'shell', while `emacs` is an 'editor'. A shell is the exoskeleton of a mollusk, and an editor is a vanishing profession. 

##Bourne Again, again

When I refer to replacing `bash`, I do not mean in the sense in which `zsh` replaces `bash`. I mean in the sense in which the shell replaced batch editing, or the sense in which the GUI has replaced `bash` itself for some less-interesting subset of tasks. 

The shell persists where batch does not. It carried itself over into the GUI through the simple trick of emulation, and has lived there happily ever since. It offers certain advantages, which no other tool in the chain can pretend to offer. 

We treat bash, the programming language, much like Church Latin. It is needed, for the preservation and wholeness of our systems going forward. But we needn't limit ourselves to speaking it. 

###The Language of the Keybashers

bash is an expressive programming language. So much so that users are fooled into thinking they know a 'few commands', when in fact they speak a rough, but conversant bash. If you know `ls` and `cd`, you know a couple words of bash. If you know the character `茶`, you can get a steaming cup of it wherever Chinese is used. 

If you can write a `dd` command without first typing `man` or hitting your browser, then certainly, you appreciate the analogy with Chinese. Ancient Chinese, no less. 

Anything `bash` can execute is the bash programming language. It is Unix. It is the most complex programming language in existence, and has been since before the days of `#!/usr/bin/perl`. Which of course says the rest of the file is Perl, and `perl` is expected to deal with it. This makes Perl a dialect of bash. 

This trick, where our language is able to launch another language, is a good trick. We intend to hold onto it. 

This is bash's only trick, and it's why you still use it. Bash is the language where you can call all the other languages, and all the other little gizmos and whatsits they spit out, and munge them together. It is the tool of final resort. Crude, terrible, but here it is, under our fingers, and toes. 

To use a programming language, you either type something into bash, or you click. Clickety clack. When Clu is done, to use `bash`, you will type some bash into Clu. 

###The Language of the Gnomes

"Welcome to Georgian! The extensible, programmable language that anyone can speak!"

Blessedly, this sentence is in English. To dismiss it, type `C-x-C-c`. **Yes I had to look it up why are you looking at me like that now I have to restart emacs excuse me**

Emacs lisp is the best documented language in existence. It is ancient, crufty and weird, but `emacs`, the emacs lisp repl, has decades of relentless optimization surrounding the tail-swallowing problem of teaching the user to program it in itself. 

Emacs is eloquent. It has won its place in history. We must retire it, because it is an editor, and editors, as I hope to demonstrate, are wrong. That is, the (textual) editor, distinct from the shell, distinct from the language, is harmful, an extrusion, bolt-on or aggregate. It should be a use case, just that: a simple, central use case, the editing of texts which themselves comprise programming languages, and the interaction therewith. 

This is the chief reason, salient others include: it is dynamic, with lexicality bolted on. The VM is terminally slow. The namespace problem shall never be solved. Last, but not least, it is in the hands of the Gnomes, and is the handiwork of the Gnome in Chief. 

I could continue, but to what end? I come to bury, not to disparage. Emacs comes the closest, of all programs that float upon `bash`, of swallowing its own tail and superseding `bash` entirely. That it doesn't do so, may be traced directly to the question of syntax.

####An aside to the Partisans of vim

I do not intend to abandon your spare, thoughtful, and in my opinion severe and confusing, approach to the editing of text. 

Please do not compare your editor, which I'm sure is excellent, with emacs, which is a programming language. A rational shell will support vimification. Where matters of syntax are concerned, we come to the field well equipped.

## Why Clu?

I've made the case that a language that replaces `bash` and `emacs` might be useful. Why invent one? Why not write the whole thing in Python and call it a day?

In a sense that's precisely what I'm doing. LuaJIT and lpeg are written, Clu rides along. Lua, the program, is small, easy to understand, easy to embed in C. The language Lua doesn't expose the Lua(JIT) program in a sufficiently flexible way for our purposes, and that is the intention behind Clu. 


### The Requirements

We're designing a tool that conflates and replaces the shell and the editor. We can't call it a browser, despite the excellent historical precedent. Referring to it as a REPL is suggestive, but technically incorrect, as we'll see: a shell reads, evaluates, and prints in a loop, while our program will have more options available. 

We're going to call this kind of program a bridge. This is in two senses: the bridge as place from which a ship is piloted, and a bridge as a structure that bridges gaps in various channels. **bridge** is our program, invoked as `br`. `br` is not a command in my current Unix environment, and `brew` won't install it, so that's reasonable namespacing. 

Our bridge should run in a virtual machine. It should be small, so we can launch many of them; it should have a simple, easy to program interface from the systems side (C,D,Nim,Rust,etc), with a complementary FFI, semantics that are easy to grasp, and the ability to sandbox, so `curl http://example.com/init.br | br` will not by default hose you in the face of a hostile script. It should be as fast as possible given these constraints, and it should be designed and maintained by someone else, ideally a genius whose work is widely emulated but never yet surpassed. 

LuaJIT fits the bill perfectly. I can, and will, go into detail as to why the table object in Lua is the perfect compromise data structure for the kind of highly dynamic system needed to conn a bridge, as well as why prototype objects are correct for this use case. Here I will indicate the argument, and link to it when it exists. 

Lua, the language, is not currently suitable. The reasons for this are subtle, and covered [elsewhere](lun.md), still, the changes must be made. In particular, a bridge language must consider the global namespace sacred and allow only the most limited tampering with it. This requires the full tool kit of local by default, `local` to force shadowing, `outer` to refer to an otherwise shadowed variable, and either `def` or `export` to declare a variable into the global namespace.

This is not, in itself, sufficient. Lua is so simple and beautiful as to be nearly homoiconic, certainly tables may be loaded up in arbitrary ways, but programming computers is neither horseshoes nor hand grenades. Writing a bridge will involve large amounts of generated code, complex introspection, and other concepts that are cleanly expressed with [s-expression](http://en.wikipedia.org/wiki/S-expression) syntax. 

### JSON, Clojure, EDN

Our homoiconic system is simple, and based firmly on the principle of least surprise. No one programming in the twenty teens should be surprised to find `{}` enclosing a map, `[]` defining a vector, nor `()` as an expression. Note that we call `()` an expression or expr, not a list. The `l` in Clu is from Lua and Clojure, not Lisp. `'()` we call a quoted expression, any form which is quoted is literally a table bearing a Node metatable. Nodes can be almost arbitrarily complex. The use of `\o/` (the `o` is stylistic) for destructuring is novel, but consistent, and some convention is absolutely necessary to cleanly represent Lua's embrace of multiple returns. I flirted with hijacking `<>` for type related matters, but relented and returned them to userspace. Jacking `\/` is already fairly provocative behaviour, though I expect I should be able to make `\'(/ 2 3)/` parse correctly and return `~'/, ~'2, ~'3`. Clu's syntax is not particularly minimalist.   

The resulting language must hew closely to the underlying semantics of Lua: it is prototype based, using (meta)tables for the usual purposes including the environment, mutable, imperative, etc. Where we break with Clojure is with the latter's emphasis on immutable operations and resulting memory model. Clojure has that ground thoroughly covered. A bridge needs to expose and work with the underlying OS concepts for mutation and concurrency: Lua's single-core imperative model with coroutines is a good fit for expressing a bridge instance.  

A Lispy language is absolutely the right tool for many of our tasks. The particular strength of Algol is that it was build to resemble the pseudocode with which computer programmers exchange algorithms. I'm writing Clu because I believe it to be possible to harmoniously combine the virtues of these two approaches, while accounting for any other syntax we may need to work with. 

### The Clu contribution

A language in which syntax is a first-class property is a language equipped to marshal, edit, run, chain and interact with other languages. Clu is an S-expression language simply because without the resulting cellularity the whole enterprise falls apart. 

A syntax is a tool that forms a string into a tree. Given a symbol not recognized by that syntax, it is possible to construct a pair of symbols which may enclose that syntax, and those symbols may if necessary be further enclosed with `||` to form an S-expression within a larger arcy. Without this enclosing property, composability is never frictionless.

We use this tool to switch from Lun to Clu as appropriate, and to embed other syntaxes and their transformations. 

### The path ahead

I am working on the PEGylator engine that will drive Clu. Spending a lot of time on the parser is a weird place to be while writing a Lisp-like, but then, Clu Is Not Lisp: our parser generator is central to the aesthetic and function. PEGylator written, Clu will take form fairly rapidly. For writing several extended Xterm programs and a bridge, I'm going to need (a lot of) help and some means of consistent financial support. 
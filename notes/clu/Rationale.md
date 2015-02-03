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


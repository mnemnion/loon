#femto

I'll write a few bridge tools early. femto might be the first, as a lepr library.

femto is two things, a text editing API and a drop-in replacement for nano that doesn't segfault when you add undo and syntax highlighting, and has a hook to call Clu.

drop-in nano almost, we won't read .nanorc because those are nar nar. Someone can write an old-fashioned regex grammar, I'd rather not. Command-compatible out of the box, but with syntax and undo built in, and a prominent switch to a more modern set of keyboard defaults. 

nano-level functionality is surprisingly useful and should be mastered before advanced crap is tried. I just can't deal with how incredibly primitive nano proper is and want to just link LuaJIT to Scintilla and rewrite the puppy. I'm just holding out on a proper language.

putting femto on the wishlist also keeps me from wasting too much time jacking up lepr. 

Of course, maybe I shouldn't bother. Maybe I should launch NaNoNaNovember, wherein you reimplement as much nano as possible in the language of your choice. 
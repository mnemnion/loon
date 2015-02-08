#Bridge User Experience

**bridge** is a [choose-o-phone](http://www.infoq.com/presentations/Design-Composition-Performance) by design. A system this basic must be eminently modifiable. It is incumbent upon us to provide sensible and reasonably familiar defaults. "Familiar" is a difficult word in the context of shells, repls, and editors. There are so many to be familiar with.

In doing so, we choose to avoid certain problems with our predecessors. Happily, Lua provides a functioning subset of what is meant by 'namespacing', with a bit of discipline, and we can use this to our advantage. 

Let's discuss certain defaults, in no particular order.

##Backspace instead of CapsLock

We may not be able to ship this without help on common platforms. People might hate it. 

Everyone should try this. The capslock key is singularly useless, almost criminally so. In **bridge** you can contextually define shift to be sticky, modal, and sticky-modal (where it acts modal if you press and release and isn't otherwise), sticky-modal gives you a caps lock function and if we can we'll blink the caps light for this, and not for backspace.

This is core ergonomics, it really hurts to delete with the right pinky. Deleting happens more often than hitting return, in my experience. Also, the forward-delete key is useful, I can't personally imagine programming without it. 

Many paradigms will depend on having both delete and backspace available. They are considered navigation keys, not glyphs, for purposes of further discussion. 

##Modality

No one has ever designed a non-modal editor. Your choices are restrictive (vim) and confusing (emacs). We put our own stamp on it. 

vim has two modes, insert and command. What I suspect most users of vim like is the fluid nature of an abbreviated, concatenative command syntax, rather than this particular stricture. We provide this by allowing modes to define abbreviated syntax for the commands, as well as keypresses. These are sticky-modal off the Alt key: an Alt-glyph issues only that command, while Alt-release and Alt-; begin a command mode that ends with the next ;. 

The emacs rules for mode precedence are intricate, don't work reliably, and ultimately depend on the peculiar properties of the a-list data structure. I have a piece of elisp specifically for juggling certain modes to the top of the pack, which I stole, quite possibly from Xah Lee. **bridge** uses [roshambo](../../src/mods/roshambo.lua) for the same purpose.

#term

**bridge** and the **bridgetool** suite expect to run on a program called **term**. By design, they can run acceptably given the fundamental ANSI escape sequences, but this is an impoverished environment.

**term** is not a terminal emulator, it is a program called **term** which provides enriched terminal functionality within the native operating system environment. Separate implementations for each major OS/GUI combination will be necessary. **term** is by intention a standard program, one with minimal implementation-specific behavior. Implementing **term** and providing a POSIX-ish environment is intentionally sufficient to run **bridge**. 

##Rationale

**bridge** is a control environment intended for advanced users of a personal computer. The advantages of the command line interface and basic Unix substrate are so considerable, that despite meaningful updates to the paradigm in the last 30 years, it remains fundamental to user interaction for many classes of users.

We consider this a strength and wish to build on it, believing that the textual grid offers advantages which the WIMP GUI can't replace. One cannot help but notice that terminal emulators, versus actual terminals, are universal in practice. 

Given that one can trivially run all 2015 terminal tools of substance on a real, honest-to-God, built-in-the-USA VT-100 *terminal*, continuing to provide support going forward seems overly generous. 

The intention of **term** is to minimally change the function of the terminal, to augment its fundamental role. Supplanting windowing systems, browsers, and so on, is pointless, wasted effort. 

##Keyboard

The requirements that actual terminals place on communication make for an impedance mismatch between what the user may press and what the terminal may detect. **term** must both detect every available keyboard action, and translate it into a stream protocol, utf-8 compatible, which **bridge** can consistently decipher. 

All keystrokes pass through **term** and through **bridge**, which may or may not pass them through to the OS in some fashion. Command-Q may well quit on a Mac, but the user has the chance to remap this. 

This is true of all mouse, track, or touch events which the system is capable of detecting: they pass through **term** onto **bridge** (or indeed any other program using the **term** protocol) in a system-independent, utf-8 compatible fashion. 

##Screen

**term** has screens, which may be attached to via a /dev/term.* file interface. They have a size in cells, and each cell has a size in pixels. 

**term** is capable of allocating subsections of this grid, provided they are requested via an exact number of cells. These are always rectangular, and are either in pixel or character mode. **term** is capable of writing around these allocations. Conceptually there are two planes, the main plan and the allocated plane, which is above the main plane. 

These image frames are powered by the GUI and their use is implementation-specific, in the sense that **bridge** provides the interfaces for graphics in the terminal. **term** will accept a textual stream as an alternate to the image frame, this stream may be the driver for the image frame or it may provide equivalent information for accessibility.

**term** allocates and writes to multiple cursors on a socket-type basis, which is also used by the frame allocator. These are the basic abilities, we may provide some degree of enhanced self-report. There are contexts where it's helpful to know what character a cell is displaying, for example. 

##Unicode

**term** handles Unicode *correctly*. utf-8 of course, the others are dead to me. This means it knows, to the glyph, how many cells to advance the cursor, and therefore how many cells a glyph is occupying. It does this, correctly, no matter which of the four valid directions the cursor is traveling in, and no matter which fancy control characters you throw at it. 

We also need to provide at least one comprehensive font family that does this. It can be a Frankenfamily, we don't have to reinvent the wheel here, but it's depressing how few monospace fonts correctly connect all box-drawing characters, large parens, and other weirdo members of the Unicode family. 


##Escape Sequences

**term** interprets a modified set of ANSI-like escape sequences. We don't arbitrarily change semantics, but we can and will drop pointless sequences and possibly reuse them. These handle the usual set of tasks, as well as frame allocation and multiple cursor tracking as discussed earlier, and a few miscellaneous operations like spawing a new terminal in a new window or tab. 

A reasonably well behaved xterm program should have nothing to fear running under **term**. A weird one may have to force xterm compatibility, which is worth providing. 

###Nothing else

This is the full function of **term**. It is plausible to specify the behavior completely and implement it on any modern GUI. **term** provides a consistent, monospaced textual interface, a way to write to canvas-like frames over that interfaace, comprehensive translation of user input to the underlying program, and that is all. 

##Philosophy

The advanced user of the computer is inevitably concerned with textual manipulation and transformation of data. Whether she writes programs or runs them is immaterial. In point of actual fact, sequences as simple as `ls` constitute programming of a somewhat ad-hoc and janky language called bash. 

A monospaced grid arrangement provides minimum impedance for doing this work. Keyboard interaction must be programmable, because each application, and each user, has different expectations and preferences in this regard. 

The road from simple user, to advanced user, to programmer, should be as smooth as practical. The status quo, a combination of xterm and bash (or what have you) with line-printer oriented Unix tools, is in need of a consistent interactive paradigm, one that takes it for granted that cursors can move backwards as well as forwards. 

To write a better shell, we demand a better terminal. Not dramatically better, just powerful enough to be useful. A user can be taught to use a command-line photo filter if she can see the intermediate results, go back to the command, modify it, and tinker until she likes what she sees. Our shells don't work that way, and our terminals don't quite either. 
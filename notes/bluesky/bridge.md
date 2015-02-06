#The Bridge

Clu is a new programming language, written to write a new type of program called a bridge. Many aspects of Clu will be familiar. Many aspects of a bridge will be familiar also. 

Clu clearly resembles a Lisp, particularly Clojure; just as clearly, it embraces the Lua semantics. A bridge is most like a shell, a REPL, or an editor, embracing and extending each of these functions. 

A [bridge](http://en.wikipedia.org/wiki/Bridge_(nautical)) is a command center for interacting with a computer. This activity is also referred to as programming. `cd ~` is a small program, written in bash, executed by `bash`. If you type it into `br`, it has the same effect, in context. 

It does so somewhat differently. In a shell, running `cd ~` causes `pwd` to change to `/~`, and causes stdio to print another command line. Often, this new command line includes the updated directory, but this is of course configurable, and we will often treat defaults as a given.  

On a bridge, `cd ~` is inscribed on a card, along with its output, in this case, the new prompt. That card is placed at the top of the active deck, and a new empty card issued. Result: the familiar cursor, full of possibility. 

`ed`, by contrast, will not do as you expect. `ed file`, or in many cases just `file`, will open a card on the new file a mode into an editing context accordingly. You are still on the bridge.

Can you open a new deck and pipeline several programs together into stacks of cards which update as you move through each stage of the pipeline, interacting with the data flow accordingly? Yes, though I am charmingly unsure what your fingers will type to do so. 

Welcome to the fleet, let's get oriented.

##First tour of duty

The bridge is an abstraction which lets hackers get work done.

For any interface, there can be a single canonical best fit. For the bridge, it is the laptop and desktop computer. A bridge may be squeezed into a jeejaw but we depend on the user having access to keys and a trackpad. The trackpad/mouse/trackball/clit/moveypointey is both optional and useable, won't be referred to often, and does what you expect. 

The screen of a bridge is rectangular, and is composed of a grid of cells, in rows and columns. A typical Unicode point fills exactly one cell on a bridge. Not all Unicode points are typical; Chinese being what it is, the atypical may even outnumber the typical, in any case, all Unicode points have an exact and predictable effect when displayed by the cells of a bridge. 

This is not the only use of cells. It is the *typical* use of cells. We use monospacing because we are hackers, and it is correct to our purposes. When we wish to display graphical elements, we do so. 

A frame is some subdivision of this screen. When we open a new frame, it displays a blank card, with a cursor. The default is command mode, which is line oriented: each line is a program, each return generates a fresh card at the top of the deck. One way to break out of command mode is to type `(` and begin writing Clu. Other options are available. 

In a clean default, you have no directory, or need for one. Perhaps you want to compose a tweet; the card is not picky. Typing `cd` and a return will give you your user directory, and put us in directory mode. 

`ls` launches **ls**, an interactive file browser. It prints precisely what you expect, you can configure it persistently on a per-directory basis, clicking around will select in various ways. `ls` is launched onto a card, the interface looks like what happens when bash prints `ls` to a VT-100, there is a new card below all the action. Navigation between cards is done using chord-arrows or by clicking. 

I hope you're nodding along. To help you picture it: a card can be less than a screen, or a full screen. If it's more than a screen, it's still only a screen big. So an `ls` call on a huge directory, you get the first page and then the prompt on your next card. You want more, you upcard, scroll around, then downcard. Capiche? Molto bem.

There is no strange, legacy paper trail of terminal residue above you. Everything is on a card, cards are a screen tall but can contain multitudes, and wake up when you visit them. 

What that means, depends on the program that is the card. The simplest card, like `cat foo.txt`, just has some text on it. Would you expect to be able to edit on a cat card? You would not. 

A more complex card might contain several screens of data, and wake up enough to let you scroll around in it and select something. A long `cat` would do this. A card containing a video would offer you controls to replay it, or edit it. Depends on what you were doing with that card.

Wait, a video? I thought we were in the Matrix? We're not on a terminal, though we're using an evolution of the xterm protocol to drive the bridge. It's not challenging to request a frame of cells and render pixels onto it using graphics acceleration, requesting a fractional number of cells is what's impossible. Normally our bridge will want to render text into cells, but exceptions are normal among the Fleet.

Cards have history, as do decks, as does the bridge. Since the bridge must reckon with the operating system, we are able to copy and paste. When we do so, we also pick, and place, and when we cut, we snip also. Cut, copy and paste act on text, pick, place and snip on cards, and the contents of cards. No hacker who has used a descendent of Finder should be lost here.

##Aesthetics of the Bridge

The hacker is normally concerned with telling computers what to do. We use digital text as an acceptable compromise between pure numbers and the beautiful, pure depictions of which our hands are capable. This accord is thousands of years old, and it is the basis of civilization. 

At one time, interface was subject to technical constraints. The design of typewriters and line printers is greatly simplified if each glyph is of the same width. For this reason, these tools are naturally monospaced. The terminal, too, was simplified by monospacing: each glyph assigned a cell, lit in certain ways. 

This is not a natural match to the Latin character set. Particularly with minuscules, i and w are not of a width. Just look at them. We [lucked out](https://imgflip.com/readImage?iid=101470) in that the Latin alphabet is a less uncomfortable fit for monospacing than many of its relatives and anything from a different clade. 

I say lucked out, because we're hackers. We need to use every gift Evolution has given us to make sense of our own creations. We can't make Intel, or Apple, or the hordes of the Pearl Delta, into something they are not; we must weave our homes from the fibers they provide. 

Look at your keyboard. Take a good hard look at it. A Zen look. This is your instrument, redesigning it is futility. 

Variations and edge cases ignored, you're looking at 47 keys which, when you press them, normally generate precisely one glyph. Shift them, they generate another glyph. One other key, a large one, is never shifted, and makes a space. You have a key which we'll call return, by tradition, a key you call backspace and I call delete, and a key you call caps lock and I call backspace. Those give you a fresh line, delete forward, and delete backward, as you'd expect.

Note that on the bridge you delete mistakes with the left pinky off the home row and then hit return with the right pinky, also off the home row. Try it, you'll like it. I do not care if you Dvorak, but I do care that you do this. 

In any case, these glyphs, on the bridge, are all a single cell wide. Backspace removes the contents of a cell to the left of the cursor, delete does the same to the right, and return puts you in the leftmost sensible cell, below the row of cells you were on. Sometimes. 

This is important because it lets us aggressively overlay data in a consistent and viable way. The most information rich unit is the glyph, and we have many, but choose to use few. Because, as mentioned, we can only type 94 in any given keyboard configuration. Though it would seem we have more buttons...

You may have an escape key. On the bridge, you are certainly allowed to touch it, if that's your thing. It's certainly there, if small, up, and to the left. It's a mere remap of one of your four chord keys, which in Neoclassical space cadet fashion, we refer to as hyper, control, alt, and super. You could call this a political compromise. You'd be right.
They are `h-, c-, a-, s-` for short. Because of the equivalence of escape and alt, the alt key is sticky, making `a-n` and `esc n` equivalent in all cases. The command `a-esc, esc-esc, a-a-` is a null command. The other space cadets are not sticky unless you assign them so, nor is shift.  

On a bridge, we remap the huge and tasty caps lock to backspace, and make a single alt press equivalent to escape. A bridge being a hacker tool, you can of course fuck this up if you're stubborn. But try it first, you only have two wrists and statistically the right is more important (I'm an outlier here).

Speaking of your wrists, you'll be using one of three techniques to navigate: arrows, touchpad, or that weird vim thing you guys always want to implement. Only weirdos and holdouts navigate by typing space cadet keys and hitting glyph keys. It's passé. The vim thing isn't, that's pleasant, just weird. You can of course provide any keymapping your heart desires, the bridge is both Turing complete and sensibly designed. That's why it needs an aesthetics. We have arrow keys. Use them to their intended purpose. 

Arrow navigation, and some edit actions, are coupled to the space cadets on a chorded basis. This is subtle kung fu and the basis of fluid bridge hacking. There are 14 ways you can press hyper, control, alt, and super. We only abuse that privilege where the arrow keys are concerned, and there we abuse it heavily: 56 navigational idioms become available. Saying something like `s-c-r` is silly, `s-c-→` might well not be. 

The hyper key is mostly left undefined for userspace, and the super key is normally needed to cooperate with the OS in various ways. We support an `altgr, ag-` for those who require it. 

You can also click on things. Sometimes you're feeling lazy, drinking coffee, high, or otherwise not in the mood. 

Ah, and we have a tab key. Poor tab key: the single most ad-hoc, confusing key on the board. We continue the tradition of combining some navigation functions with indentation, though we intend to issue the actual tab character as seldom as possible. Horizontal Tab is Deprecated, yo. I may actually forbid the issuing of physical tabs in edit modes for programming languages that don't require them, on the main trunk. 

The deep wisdom of editor writing: always doing the right thing when the user strike the tab key. This goes double for the bridge. 

The bridge has no truck with function keys, or anything on an extended board. The user is welcome to populate them as desired. They aren't deprecated, so much as superfluous. The same is true for any keys not commonly found on a laptop, and pointer devices are only expected to provide the equivalents of left and right clicks. 

As for which chord is mapped to what function in which context: don't know, don't care. We construct the bridge in such a way that the user can discover and assign these things. This takes thorough design, culminating in a help card that actually tells you which keys do what in various contexts, and contains information that's accurate to the running bridge. 

This is critical: the underlying bridge structure is tight enough that if you define the bare key `a` to mean `quit`, the tutorial will tell you to press `a` to quit. I can't make your blogs automagically update, but all internal documentation within a running bridge is generated from the bridge itself, and there is no blessed mapping between keystrokes and the functions they invoke. On reflection, perhaps I can make your blogs automagic; it would be a simple thing to put some JSON in a consistent location, containing the up to date and by-context mappings of the local bridge. 

The grid is cellular and addressable. This is an enormous leap in our expressive power, when we choose to use it. Further, we can render the glyphs in living, vivid color. In bridge programming, we abstract color, the background is called Black, default text White, something else might be Red and so on: for a blind user, these are clearly not colors at all. 

This is not typical, just better. As hackers, some of us like to use color to interact with data, and those who can should, because it's an extra dimension and hence more usable information on the screen. We like this. Programmers map a semantics to a Color, users map that Color to a color, or some other pleasing affect. We recognize foreground and background colors, but provide no underlining or strikeout, considering those Unicode matters.  

Again: the bridge is quite capable of rendering images, moving or otherwise, within a frame of cells. The essence is that the grid is respected and textuality is primary.

**bridge** runs inside another program. We call it the terminal by long convention; the changes we make to this program don't justify a new genus. **bridge** will degrade gracefully in xterm, perform glumly in a black and white setting, and become unusable should the user encounter a genuine line printer in the wild. Changes are good the shuttles need a good oiling. 

The enhanced terminal does little more than interpret an extension of the xterm protocol that allows programs to display canvases over selected frames. One might display a browser window, I'd imagine this as quite a normal activity, all the terminal would then know is that a certain region is being blitted to rather than texted at. **bridge** would have as much awareness of the underlying processes as desired: any program of this nature wants to grow until you can check your gmail. 

The terminal is a single running instance that creates and manages various windows in the GUI, and is able to move stdios around from window to window, when cards are moved. So epsilon more integrated with the GUI than a typical terminal emulator. Our terminal program, which we just call **term**, is a terminal, not a terminal emulator. It can't emulate terminals it's not descended from, though **bridge** could do so. 

We build as little into **term** as practical. I consider keyboard comprehension an edge case. If you know about keyboards, you'll know that it's non-trivial in some contexts to capture keypresses and render them intelligibly. Whether that's a bridge or term level function is unclear. 

**bridge** is responsible for translating addresses. A card has a certain amount of frame, and as far as the card is concerned, the leftmost fillable corner is 1,1. **bridge** turns these into absolute jump calls into the window's grid. The card has in principle infinite positive dimensions it may fill, **bridge** sees to it that the relevant cells are displayed. **term** informs **bridge** of the pixel density of a single cell, so it can allocate and fill regions accordingly. 

The grid is an interface abstraction, and may be locally reset to a different pitch. A 10x10 allocation of cells from a window may be cast by a **bridge** process as 7x7, making glyphs larger, and what have you. Can you do arbitrary suballocation? In principle, yes, but this abstraction is difficult to support on current hardware and brings more headaches than value. At first. We do want **bridge** to function well in xterm, so it should be reasonably mature before we start relying on enhanced function from **term**.

Decks, and I chose not to emphasize this, are recursive, a deck being properly a 'deck card'. This is no particular surprise, I imagine, no different from directories being a type of file, and if you guessed files and directories are cards and decks in a bridge you're not missing anything I'm laying down for you. 

A somewhat degenerate bridge could run in a browser window. Degenerate not for display purposes, but because it is impossible for a Q1 2015 browser to capture all keystrokes issued by a user and translate them to a webapp. It is probably easier for us to jack a render engine, hopefully ServoMonkey, into **term** than to petition the powers that be to redress this grievance. 

This would also have the advantage that your #FaceTweetGrams can be decks of cards, organized by date of retrieval. I'd enjoy that, personally, as well as the ability to pipe and filter the `curl` on the way to the render engine. 

I hope this suffices as a brief introduction to the project. Don't expect to see quick action on anything presented here, because the bridge wants to be written in Clu. If you're into mockups, I'm into collaborations. 



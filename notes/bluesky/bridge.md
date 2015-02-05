#The Bridge

Clu is a new programming language, written to write a new type of program called a bridge. Many aspects of Clu will be familiar. Many aspects of a bridge will be familiar also. 

Clu clearly resembles a Lisp, particularly Clojure; just as clearly, it embraces the Lua semantics. A bridge is most like a shell, a REPL, or an editor, embracing and extending each of these functions. 

A [bridge](http://en.wikipedia.org/wiki/Bridge_(nautical)) is a command center for interacting with a computer. This activity is also referred to as programming. `cd ~` is a small program, written in bash, executed by bash. If you type it into `br`, it has the same effect, in context. 

It does so somewhat differently. In a shell, running `cd ~` causes `pwd` to change to `/~`, and causes stdio to print another command line. Often, this new command line includes the updated directory, but this is of course configurable, and we will often treat defaults as a given.  

On a bridge, `cd ~` is inscribed on a card, along with its output, in this case, the new prompt. That card is placed at the top of the active deck, and a new empty card issued. Result: the familiar cursor, full of possibility. 

`ed`, by contrast, will not do as you expect. `ed file`, or in many cases just `file`, will open a card on the new file a mode into an editing context accordingly. You are still on the bridge.

Can you open a new deck and pipeline several programs together into stacks of cards which update as you move through each stage of the pipeline, interacting with the data flow accordingly? Yes, though I am charmingly unsure what your fingers will type to do so. 

Welcome to the fleet, let's get oriented.

##First tour of duty

The bridge is an abstraction which lets hackers get work done.

For any interface, there can be a single canonical best fit. For the bridge, it is the laptop and desktop computer. A bridge may be squeezed into a jeejaw but we depend on the user having access to keys and a trackpad. The trackpad/mouse/trackball/clit/moveypointey is both optional and useable, won't be referred to often, and does what you expect. 

The screen of a bridge is rectangular, and is composed of a grid of cells, in rows and columns. A typical Unicode point fills exactly one cell on a bridge. Not all Unicode points are typical; Chinese being what it is, the atypical may even outnumber the typical, but in either case, all Unicode points have an exact and predictable effect when displayed by the cells of a bridge. 

This is not the only use of cells. It is the *typical* use of cells. We use monospacing because we are hackers, and it is correct to our purposes. When we wish to display graphical elements, we do so. 

A frame is some subdivision of this screen. When we open a new frame, it displays a blank card, with a cursor. The default is command mode, which is line oriented: each line is a program, each return generates a fresh card at the top of the deck. One way to break out of command mode is to type `(` and begin writing Clu. Other options are available. 

In a clean default, you have no directory, or need for one. Perhaps you want to compose a tweet; the card is not picky. Typing `cd` and a return will give you your user directory, and put us in directory mode. 

`ls` launches **ls**, an interactive file browser. It prints precisely what you expect, you can configure it persistently on a per-directory basis, clicking around will select in various ways. 
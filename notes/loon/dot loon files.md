# .loon files

loon looks for a .loon in your root directory, and one in your current directory.

it also searches underneath any .loon specified director between you and the current directory,
and in any flat directory off the beaten path.

More specifically, when you boot up loon, it: 

loads `~/.loon`

loads any `.loon` between `~/` and `pwd`, in order, and 

loads `./.loon`.

this evaluator needs to be sandboxed. These are configuration files, not scripts per se. 
#Pipes

A short insight about pipes: **bridge** should provide the arguments to a program to the next program in the pipeline. 

Also worth noting: we have a distinction between waking a program and running it. They can be the same action. Waking a program may trigger a cascade through the other programs it is piped to: these will also be wakes, not runs. 

Waking **cat** will do nothing other than open the card's text in a read-only context. **cat** is immutable, if you want a new cat issue a new command. `run current-card` could run **cat** with arguments, thus running all piped programs again.

Waking **ls** will update it with current directory information. This will be piped to subsequent programs, which are woken with the new information. 

For an invocation of `foo -a | bar -b | baz -c`, a program is provided with certain environment variable, call them `stdin-from` and `stdout-to`. For `bar -b`, `{#stdin-from «foo -a», #stdin-to «baz -c»}`. 

We also add an extension to stdio in the form of `stdback` and `stdfeed`. `stdback` lets a program communicate up-pipe, `stdfeed` lets a program receive communication from down-pipe. They are `/dev/null` when they aren't needed, which is normally. 
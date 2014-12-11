#Iterator over function

This is madness. I don't know what it would be good for. But what if you could iterate over a function? 

You can with a coroutine. `defiterate` defines a function which is iterable. It has a coroutine, and yields everywhere it plausibly could. To iterate it, you resume it. 

This is slower, and generates overhead, so we should just make a version of the function that doesn't iterate, that is the call form of the function. If you pass a function to a context that expects an iterator, it will look up the iterable version, if it finds it, it uses it. If not, runtime error. The alternative is to force a runtime eval, and we avoid that in core functionality. 

I need to brush up on coroutines and write some real code with them, but I believe I can make this work. Iterators are first-class citizens of Clua, type `<Iterator>` eventually, which `(is-a :function)`. If you have full code introspection in your Clua environment, any function may be transformed into an iterable version of itself, adding a satisfying layer of composability to the syntax. 
#Compiling

The Clu compiler is incremental. It consists of parsers, templates, and macros. Here's how it works. 

`eval` is a template form. A template form takes a string as input, using a parser. We will presume the parser is Clu, since we're discussing the Clu compiler, which is, entirely, the template form `eval`. 

The first thing the Clu parser will do is read the string into an ast, which we call a Node. Macros are hygenically expanded over this Node, then a series of transforms, defined in the body of `(deftemplate eval Clu [source] (...))`, which turn the Clu code into an AST that flattens into valid LuaJIT source code.

If the template is called from a non-template context, it then flattens and evaluates the resulting string. Note that if we were doing `(deftemplate C C-parser [source] (...)` we would want to call something like an assembler on the resulting string. In either case, if a template is called from within another template of the same context, it defers evaluation, returning the completed Node. The transformation happens in-place, that is, it is a mutation of the AST. 

"Of the same context" means a common evaluator. `deftemplate` does not require an explicit evaluator, it presumes you're building for the runtime environment. If this is overrided in the arguments, evaluation takes place when the evaluator exits. 

Therefore the transforms specified in the body of `eval` are themselves templates, with definitions like `deftemplate Clu-fn Clu.fn [source] (...))`, that are called by the macro-expanded code over Nodes with the id `fn`. These completed, we may call an optional validator on our generated tree. Validators are constructed from the same grammar as parsers, and confirm that a Node **could have** been generated by parsing over a string that is in the universe of the grammar. 

So our special forms are fexprs, aren't special at all, and are simply units of compilation. A syntax generates a parser automatically, that parser is combined with functions over a Node, evaluation is deferred, and when all source is loaded, the transformed code is evaluated, and the Node released for GC. 

The transform context has an important consequence, inner evaluators can be used to launch arbitrarily elaborate subprograms, either waiting for their results or simply continuing. As a salient example, the source might contain a script to launch unit tests and/or continuous integration, then continue compiling and running without waiting for the results. One might keep git parameters in a configuration table and autocommit with each run. 

There is a separate instance of the Lua evaluator called `Now`, and a template designed to use it will evaluate in the `Now` context. Note that, called within an existing `Now` context, the template wil defer, don't be thrown by the name. The effect is the same, a Now template will execute during compilation. By default, the string is parsed by Clu, it is of course possible to e.g. parse with JSON and evaluate with Now. 

When templates are defined, they are given a syntax, which is a parser, a transformer, and an evaluator. The `Now` context is normally called using the template form `(now ...)`. This evaluates and executes Clu code in the Now context. Note a subtlety: the inner template forms, say `defn`, are called in their usual context, and thus defer, executing whenever they return to the `Now` context. Consider the difference between `(now (foo bar) (baz bux))` and `(now (do (foo bar)(baz bux)))` to understand how this will work: to really drill in, ask yourself how these would be different if `foo` contained a `(now ..)` call that mutated state. 

So what is `(now (eval (or file stdin)))`? The Clu compiler.

We could use our transform functions to emit LuaJIT bytecode directly, and there is a port of the LuaJIT bytecode generator in pure Lua. There are few advantages, and the disadvantages are many. One of the charms of Lua is that it is freeform, so a given line of Clu may normally be mapped to the generated Lua on a one-for-one basis. Clu itself will (eventually?) generate its own errors that refer into the source code directly.

Note that we have, not `read, eval, print, loop`, but `parse, transform, eval`. Our line mode has a `parse, eval, report, loop` configuration: `eval` literally has the form `(transform eval)` where `transform` is idempotent with respect to the structure of the Node. It happens that acronym is [taken](http://en.wikipedia.org/wiki/Perl) by a pathologically eclectic, rubyesque language, from the Silver Age. Ours is called **bridge**, though sometimes we call it the `loon evaluator-printer-redactor`. We promise it's not contagious.

Note further that the `transform` step is not guaranteed to be free of side effects. `parse` is, if an ordinary syntax is used. `transform` is allowed to check your email. Because we defer evaluation as we walk the parse tree, templates which perform conditional compilation need access to environment variables, and this is the usual use of transform-time execution. 

The boundary layer between evaluation contexts is determined by the evaluator, not the parser or transformer. Normal embedded syntaxes are called in the Clu evaluation context. `defsyntax` is defined in the `Now` context, because a syntax must register itself within the Clu environment before a string containing that syntax is encountered. Otherwise `dispatch` wouldn't know how to parse the terminator of the syntax boundary and we would be unable to read before evaluation. 

This means that deferral of evaluation is always optional on the part of the transformer, which may eval part or all of the Node as it sees fit. Our first pass compiler of Clu will be whole-program, we want to retain this for loading Clu code into existing Lua environments. A better compiler can execute small anonymous functions that build chunks and add them to the namespace. Ultimately we can generate LuaJIT bytecode directly. 

Thus we refer to transformation and evalutation somewhat interchangeably: either can be null, `transform` happens before `eval`, `transform` is idempotent **including side effects**, and a bare call to `eval` will `transform` first. `transform` can't *quite* be null, it does have to mark the Node as transformed, but the effect is identical as the metatable provides this default.

## Macros

Macros are expanded as part of `transform`. This introduces a subtlety: templates happen before macros, and call them, but the expansion of a macro will quite normally reveal templates, and those templates could contain macros, as could the ordinary function calls, and on and on down. It's actually quite straightforward: templates expand macros until there are none left, and transform other templates, deferring their execution until an evaluation context is crossed.  

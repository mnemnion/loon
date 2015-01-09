#Lun

Lun is pronounced `lun` in IPA. Americans, you would say "Loon". Please don't call it luhn. You will make me super sad. Think Lūn, we will probably stylize in that fashion. 

Clu is one pillar of the Loon environment. The second is Moonscript. The third begins as Lua. We turn it into Lun.

Lun is Lua, empowered by our silly-putty syntax to be useful to our nefarious purposes. 

##Scope

Lun creates locals by default. Variables may only be created on the left hand side of a statement. 

This solves global leakage, but requires more nuanced keywords: we need a declarative for globals, and a way to resolve inner references. `def` is a fine term for declaring a global, and must be called in an outer scope. 

For inner references, I feel like the principle of least surprise means that we only create a local if we cannot bind the reference from the global environment. To prevent such a binding I'm tempted to use `let`. It has a strong presumption of immutability, which could be confusing, but it has a well recognized meaning of 'shadow this symbol in the local scope'. The other option is simply `local`. 

Lua offers no way other than querying `_ENV` or `_G` to resolve a global reference that has been shadowed, we might allow a reference to `outer foo`. Playing all these conceits together gives us something like this:

```lua

def foo = "global"

defn moneymaker()
	bar = "local "
	baz = foo -- baz = "global"
	let foo = "another local"
	outer foo = "changed our def"
	print (bar, foo) -- local another local
	print (bar, outer foo) -- local changed our def
end

print(foo) -- global
moneymaker() -- local another local \n local changed our def
print(foo) -- changed our def

```

`defn` being the obvious `def function`. Note that `outer` is a compiler directive that can be found to the left of most symbols, the exception that comes to mind being inside the arguments of a function definition, where it would be meaningless, since we're binding local references by definition. 

##Keywords and Method Calls

Clu will make extensive use of keywords, as any language does which provides them. Lun can call and use keywords natively, employing the same `:keyword` syntax as is familiar. This is of course a collision with method calls, and we resolve this in the same fashion as in Clu: `class@method()` calls a method and is equivalent to `class:method()` in Lua.

This is chunky. The reason is that typographically `:` is punctuation while `@` is not, we are practically forced to pronounce it. To apologize for this, `@` can be used as equivalent to `self` and `@method` to `self.method(self)` within method definitions. 

This is similar to usage in Moonscript also. Moonscript provides an object system, which Lun intends not to do, at least not initially. There's a strange tension between prototyping and inheritance, where neither one is powerful enough. If stuck with prototyping, the temptation is to build inheritance. We should resist this, and build a properly flexible object system instead. 

Perhaps our CLOS should be Cluster: The Clu System for Table Extension and Representation.  

##Equality and Assignment

Lun will allow you to say `if (foo = 23)`. It will issue a warning, which cannot be suppressed, but it will treat this like `if (foo == 23)`, because assigngment is a statement, not an expression, and this is illegal. The author always means `==`, so we choose to DWIM. The intention is that one corrects the offending code in the next pass, while in this pass, the code compiles. 

We also provide all of the `+=` style shorthands for operators, and include `!=` as the preferred nonequality. 

##Nil-returning Field Lookups

This is a maybe, but I find it tedious to have to check that `type == "table"` before doing lookups on possibly-table values. I would prefer that a table lookup on a symbol that doesn't resolve to a table return two values: nil, and the type of the value bound to the symbol. So if I call `if (foo.field)` on a string, it returns `nil, "string"`. The first is falsy, so the predicate matches, the second could be useful information. 


### Djikstra Day

This is more of a Loon matter than something Lun specific. I believe this simply must happen, sooner or later: we must begin our indexes from zero, or wallow forever in sin.

Edsger W. Djikstra made a [persuasive argument](https://www.cs.utexas.edu/users/EWD/transcriptions/EWD08xx/EWD831.html) for the sort of indexing that is prevalent in every sensible, modern language. That isn't Lua. Wirth was simply not correct here, Djikstra was. 

Therefore, some day in the future, a May 11th, we shall switch to zero for all core functions in Loon. Everything gets patched, no exceptions, and you're using a legacy syntax (of course this is possible) or you're using zero as God intended. 2017 sounds about right. 

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


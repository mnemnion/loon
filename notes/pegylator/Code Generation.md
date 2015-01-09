#Code Generation

Eventually the PEGylator will produce several engines as standard.

Some of these will be complete. No need exists to express the Lua, we just load it, writing it to a file if desired.

Other engines will generate templates for further coding. Doc generators, syntax highlighers, error handler and unit tests all come to mind, and we may want to procedurally produce other sorts of code as well.

We'd like to be able to non-destructively regenerate these templates when there are changes to the base grammar. This requires some care. 

## General Principles

There will be a comment beginning and ending any template. Code found before or after these comments is never modified.

When we regenerate a template, certain regions are 'owned' by the generator. By default this is anything between the pre and post matter. For a Markdown doc, the regions are code blocks. Anything not owned is also not modified.

Within the owned regions, the template generates certain structures, which will have certain key words. The easy example is a template with one function per rule. We parse the existing template, and generate new forms for any keywords that don't yet exist. 

If we have forms based on keywords that no longer exist, or any forms that are unexpected, we comment them out. No attempt is made to figure out what change might have been made. 

So if you change a `foo` to a `bar`, you get a fresh `bar` template and the old `foo` template is commented out. It's simple surgery to restore functionality, and a moment to ask if that's what you want after the semantic shift. 

If you carelessly leave some code at the bottom that should be in the post matter, it gets commented out too. Move it. 
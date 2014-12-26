#Structural Digest

This is off in bluesky because it's an optimization, strictly speaking.

For purposes such as code diffs, it's helpful to evaluate both the structural identity and the structural similarity
of a node.

So we should be able to `digest` a Node using its syntax as a guide, and producing a string that will match exactly for any structurally identical node, and approximately for one which is close. 

This is already done at the semantic level, as a Node will not contain whitespace or tokens which must be present and are therefore no longer useful. This would mean our `diff` tool would be serenely unaware of reformatting, which is already nice. 


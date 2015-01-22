#dispatch

**dispatch** is the little language which handles syntax boundary markers.

In general, dispatch takes anything between one `|` and another, and parses it using the alternate syntax. By default this is Lun, using `(withsyntax syntax (...))` we may define any fallthrough we wish. As long as `|` is an invalid token, or not found within our particular string if you want to be really slack, we're good. 

This is a terrible idea for syntaxes not designed to error on `|`. If any amount of `|--|` is sufficient for a syntax error, you may use the long form. Sometimes we're stuck using some alternate boundary marker. 

There is a manual way, but normally we simply define a boundary marker as part of the syntax and use that. This implicit rendering will break any syntax highlighter that isn't Loon-aware, but that's the nature of a syntax directed language for you, and we intend to provide good tooling for rendering. 
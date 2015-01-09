#Parse Tree Adjustment

The piece de resistance of PEGylator is a tree validator, and an incremental re-parser.

This is conceptually straightforward: we simply run the engine backward and inside-out. 

Any change is within a span that contains a capture. We start by using this existing capture rule against the change, if we concur, we're good. 

If the new change is impossible, we have to be careful, because PEGs are ordered choice. We need a structure that tells us, for each single-assigned place in the call graph, what the order of prior failed choices happens to be, and where they begin. 

If they failed somewhere prior to our changes, they'll fail again on the way back to our change, so we needn't bother. If they failed within or after our change, we try them in the indicated order. 

To get this effect, we need to add a function that executes on failure of a rule. Basically this means every rule succeeds always, and the final success is a failure mark. 

When we fail-on-modify, we walk through the fail index, looking for a failure reasonably close to our start point. Prior to it is good, we'd like to account for a bit of whitespace deletion or what have you, and we can afford to re-run our rules. We then attempt the possibilities in PEG order, using the table-validation engine so as to avoid perturbing our Nodes. If we're sorted, we're sorted, if not, we contain the error within a region and report it. 

Containing the error means looking around until we find something we've already parsed, and adjusting the indexes accordingly. 
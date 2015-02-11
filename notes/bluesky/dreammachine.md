#The Dream Machine

Write a C reader for Loon (we'll need this anyway, to codegen FFI stuff). 

Integrate TinyCC. 

Add DynASM.

Harmonize TinyCC and LuaJIT such that the tracing optimizer is aware of TinyCC pathways.

Profit.

## Letter to LuaJIT list

Hi,

I'm new to the list. I did a bit of searching for similar topics before posting, apologies if this has been covered elsewhere.

It is my understanding that LuaJIT is unable to trace through the C FFI. I don't understand the precise reasons for this, but gather that it's generally because the information needed for trace isn't present in the generated code. 

An attempt to solve this problem might compile the C into LuaJIT bytecode, a la Enscripten, and trace that. For various reasons this strikes me as a non-starter, or at least not likely to produce the results one would want.

Here's what I'm wondering. Would it be possible to modify TinyCC to use DynASM to generate native code from within a C program that also includes LuaJIT, lay out the native code in a way that LuaJIT can understand, and then trace the entire memory-resident program? Everything C would have to be statically compiled on-the-fly, but this is what TinyCC is good for. 

Even an explanation of why this wouldn't work would help me understand LuaJIT. If this is possible, it's my idea of a dream machine. 

Thanks for reading,
-Sam
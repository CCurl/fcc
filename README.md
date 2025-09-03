# A minimal and simple Forth compiler for a FASM-based tool chain.
FC is a minimal compiler that supports a Forth syntax.<br/>
Its initial purpose was to be a pedagogical tool for learning about compilers.<br/>
It has morphed into a serious attempt at a minimal but useful full-fledged compiler.<br/>
The compiler currently does a minimal amount of error checking.<br/>
It generates assembly code for the FASM assembler.<br/>

## How it works
Since FC generates assembly code for FASM, forward branches are not a problem.<br/>
FC breaks the input stream into a stream of tokens.<br/>
The current token is associated with some code.<br/>
That code can look at the next token (if necessary) and decide what to do next.<br/>

It is broken into multiple parts
- each part is implemented in a single file.

fcc.c: the forth compiler
- This takes a source file as the only argument.
- If no argument is given, it reads the source from STDIN.
- The output is FASM assembly, written to STDOUT.
- Any fatal errors are written to STDERR.

Running:
```
make test 
make bm
```

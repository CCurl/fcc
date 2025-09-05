# FCC Documentation

## Overview

**FCC (Forth Compiler)** is a minimal and pedagogical Forth compiler written in C that generates assembly code for the FASM assembler. It supports a Forth-like syntax and serves as both a learning tool for compiler construction and a functional compiler for simple programs.

## File Structure

- **Author**: Chris Curl
- **License**: MIT License (c) 2025
- **Language**: C
- **Dependencies**: `heap.h` for memory management
- **Target**: 32-bit x86 Assembly (FASM format)

## Architecture

The compiler follows a traditional three-phase approach:
1. **Lexical Analysis** - Tokenization of input stream
2. **Parsing** - Generation of Intermediate Representation Language (IRL)
3. **Code Generation** - Assembly code output with platform-specific optimizations

### Constants and Configuration

```c
#define VARS_SZ    500    // Maximum number of variables/symbols
#define STRS_SZ    500    // Maximum number of string literals
#define CODE_SZ   5000    // Maximum number of IRL instructions
```

### Key Data Structures

#### Symbol Table Entry (`SYM_T`)
```c
typedef struct { 
    char type;          // 'I'=Integer, 'F'=Function, 'T'=Target
    char name[23];      // Symbol name
    char asmName[8];    // Generated assembly name
    int sz;             // Size in bytes
} SYM_T;
```

#### String Table Entry (`STR_T`)
```c
typedef struct { 
    char name[32];      // Generated string name (S1, S2, etc.)
    char *val;          // String value (heap allocated)
} STR_T;
```

## Core Components

### 1. Lexical Analysis

#### Token Processing
- **`next_ch()`** - Advances to next character, handles line reading and EOF
- **`next_line()`** - Reads next line from input file
- **`next_token()`** - Extracts next token, handles comments (`//`) and numbers

#### Number Recognition
- **`checkNumber(char *w, int base)`** - Parses numbers in multiple bases:
  - Binary: `%1010` (prefix `%`)
  - Octal: `o755` (prefix `o`)
  - Decimal: `#123` or `123` (prefix `#` or none)
  - Hexadecimal: `$FF` (prefix `$`)
  - Character literals: `'A'` (single quotes)
  - Supports negative numbers with `-` prefix

### 2. Symbol Management

#### Symbol Operations
- **`findSymbol(char *name, char type)`** - Locates symbol by name and type
- **`addSymbol(char *name, char type)`** - Adds new symbol to table
- **`genTargetSymbol()`** - Generates unique target labels (Tgt1, Tgt2, etc.)

#### String Management
- **`addString(char *str)`** - Adds string literal to string table
- **`dumpSymbols()`** - Outputs symbol declarations in assembly format

### 3. Intermediate Representation Language (IRL)

#### IRL Opcodes
The compiler uses an internal instruction set:

**Stack Operations:**
- `PUSHA`, `POPA` - Push/pop accumulator
- `SWAP`, `SP4` - Stack manipulation
- `POPB` - Pop to second register

**Memory Operations:**
- `VARADDR` - Load variable address
- `STORE`, `FETCH` - Memory store/load
- `LOADSTR` - Load string address

**Arithmetic:**
- `ADD`, `SUB`, `MULT`, `DIVIDE` - Basic arithmetic
- `LT`, `GT`, `EQ`, `NEQ` - Comparisons
- `AND`, `OR`, `XOR` - Bitwise operations

**Control Flow:**
- `JMP`, `JMPZ`, `JMPNZ` - Conditional/unconditional jumps
- `TARGET` - Jump target labels
- `DEF`, `CALL`, `RETURN` - Function definition and calls

**Special:**
- `LIT` - Literal values
- `PLEQ` - Plus-equals operation (`+!`)
- `INCTOS`, `DECTOS` - Increment/decrement top of stack

#### Code Generation
- **`gen(int op)`** - Emit single opcode
- **`gen1(int op, int a1)`** - Emit opcode with one argument
- **`optimizeIRL()`** - Performs peephole optimizations

### 4. Parser and Code Generator

#### Language Constructs

**Variables:**
```forth
var myVar           // Declare integer variable
```

**Functions:**
```forth
: myFunc            // Function definition
  42 myVar !        // Store 42 in myVar
;                   // End function
```

**Control Structures:**
```forth
condition if        // Conditional execution
  // code
then

begin               // Loops
  // code
  condition
while               // While loop
again               // Infinite loop
until               // Until loop
```

**Stack Operations:**
```forth
42                  // Push literal
dup                 // Duplicate top
drop                // Remove top
swap                // Swap top two
over                // Copy second to top
```

**Arithmetic and Logic:**
```forth
+ - * /             // Basic arithmetic
< = <> >            // Comparisons
AND OR XOR          // Bitwise operations
```

**Memory Operations:**
```forth
@                   // Fetch from address
!                   // Store to address
+!                  // Add to memory location
1+ 1-              // Increment/decrement
```

### 5. Platform-Specific Code Generation

#### Windows (32-bit)
- Uses WIN32 API calls
- FASM PE format
- Standard library functions via `msvcrt.dll`

#### Linux (32-bit)
- Direct system calls
- ELF executable format
- Minimal runtime dependencies

#### Built-in Functions
- **`bye`** - Program termination
- **`puts`** - String output
- **`emit`** - Character output
- **`.d`** - Number output

### 6. Utility Functions

- **`push(int x)`, `pop()`** - Internal stack for parser state
- **`strEq(char *s1, char *s2)`** - String comparison
- **`accept(char *str)`** - Token matching
- **`msg(int fatal, char *s)`** - Error reporting with source location

## Usage

### Command Line
```bash
./fcc source.fcc > output.asm    # Compile file
./fcc < source.fcc > output.asm  # Compile from stdin
```

### Error Handling
- Syntax errors show line number, column, and source context
- Fatal errors terminate compilation
- Warnings are displayed as comments in output

### Example Program
```forth
var counter

: increment
  counter @ 1+ counter !
;

: main
  0 counter !
  10 begin
    dup .d
    increment
    counter @ 10 =
  until
  drop
  bye
;
```

## Compilation Process

1. **Initialization** - Set up symbol table with built-in functions
2. **Parse Declarations** - Process `var` declarations and function definitions
3. **IRL Generation** - Convert Forth constructs to intermediate representation
4. **Optimization** - Perform peephole optimizations on IRL
5. **Assembly Generation** - Output platform-specific assembly code
6. **Symbol Dump** - Output variable and string declarations

## Limitations and Features

### Current Limitations
- Minimal error checking
- No floating-point support
- Limited control structure nesting
- No user-defined data types
- Basic optimization only

### Key Features
- Multi-base number literals
- String literals with escape sequences
- Cross-platform code generation
- Pedagogical clarity
- Minimal dependencies
- Stack-based execution model

## Memory Management

- Uses external heap manager (`heap.h`)
- String literals are heap-allocated
- Symbol table has fixed size limits
- Stack-based execution with return stack

This compiler serves as an excellent example of a minimal but functional compiler implementation, demonstrating core compiler concepts in a clear and understandable way.

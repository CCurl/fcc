# FCC Documentation

## Overview

**FCC (Forth Compiler)** is a minimal and pedagogical Forth compiler written in C that generates assembly code for the FASM assembler. It supports a Forth-like syntax and serves as both a learning tool for compiler construction and a functional compiler for simple programs.

## File Structure

- **Author**: Chris Curl
- **License**: MIT License (c) 2025
- **Language**: C
- **Target**: 32-bit x86 Assembly (FASM format)

## Files

- **fcc.c**: Main Forth compiler source code
- **system.c**: Platform-specific code generation (Windows/Linux)

## Architecture

The compiler follows a streamlined three-phase approach:
1. **IRL Generation** - Parse source and generate Intermediate Representation Language (IRL)
2. **Iterative Optimization** - Repeatedly perform peephole optimizations until no changes
3. **Code Generation** - Output platform-specific assembly code (Linux/Windows)

### Constants and Configuration

```c
#define VARS_SZ    500    // Maximum number of variables/symbols
#define STRS_SZ    500    // Maximum number of string literals
#define LOCS_SZ    500    // Size of local storage array
#define CODE_SZ   5000    // Maximum number of IRL instructions
#define HEAP_SZ   5000    // Maximum number of characters in the HEAP
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
  - Decimal: `#123` or `123` (prefix `#` or none)
  - Hexadecimal: `$FF` (prefix `$`)
  - Character literals: `'Y'` (single quotes)
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
- `STORE`, `FETCH` - 32-bit memory store/load
- `CSTORE`, `CFETCH` - 8-bit (byte) memory store/load
- `LOADSTR` - Load string address

**Arithmetic:**
- `ADD`, `SUB`, `MULT`, `DIVIDE` - Basic arithmetic
- `DIVMOD` - Division with both quotient and remainder
- `LT`, `GT`, `EQ`, `NEQ` - Comparisons
- `AND`, `OR`, `XOR` - Bitwise operations

**Control Flow:**
- `TESTA` - Test accumulator against zero
- `JMP`, `JMPZ`, `JMPNZ` - Conditional/unconditional jumps
- `TARGET` - Jump target labels
- `DEF`, `CALL`, `RETURN` - Function definition and calls


**Register and Pointer Operations:**
- `MOVAB`, `MOVAC`, `MOVAD` - Copy accumulator to EBX, ECX, EDX
- `ADDEDI`, `SUBEDI` - Add/subtract constant to EDI (pointer arithmetic)
- `EDIOFF` - Load EDI+offset into EAX
- `SYS` - System call interrupt

**A-Register Operations:**
- `AFET`, `ASTO` - Fetch from/store to A register variable
- `AINC`, `ADEC` - Increment/decrement A register variable

**Special:**
- `LIT` - Literal values
- `PLEQ` - Plus-equals operation (`+!`)
- `INCTOS`, `DECTOS` - Increment/decrement top of stack

### 4. Parser and Code Generator

#### Language Constructs

**Variables:**
```forth
var myVar           // Declare integer variable (default size 1)
var buffer 100 allot // Declare integer variable with size 100
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

**Memory Operations:**
```forth
@                   // Fetch 32-bit value from address
!                   // Store 32-bit value to address
c@                  // Fetch 8-bit (byte) value from address  
c!                  // Store 8-bit (byte) value to address
+!                  // Add to memory location
1+ 1-               // Increment/decrement TOS
```


**Register, Locals, and System Operations:**
```forth
->reg1              // Copy TOS to EAX (no-op, EAX is TOS)
->reg2              // Copy TOS to EBX
->reg3              // Copy TOS to ECX
->reg4              // Copy TOS to EDX
sys                 // Execute system call (INT 0x80)
+locs               // Add 24 to EDI (allocate 6 locals)
-locs               // Subtract 24 from EDI (free last 6 locals)
l0..l5              // Push addr of local #x to the stack
```

**A-Register Operations:**
```forth
a@                  // Fetch value from A register variable
a!                  // Store value to A register variable
a+                  // Increment A register variable
a-                  // Decrement A register variable
```

**String Literals:**
```forth
s" Hello"           // Push string address to stack
```
**Arithmetic and Logic:**
```forth
+ - * /             // Basic arithmetic
/mod                // Division with quotient and remainder
< = <> >            // Comparisons
AND OR XOR          // Bitwise operations
```

**Source Code Comments:**
```forth
//                  // Comment until the end of the line
( ... )             // In-line comment
```

### 5. Platform-Specific Code Generation

#### Cross-Platform Support

**Linux (32-bit):**
- Direct system calls via `sys` command
- ELF executable format
- No external library dependencies
- Custom function call convention using EBP stack

**Windows (32-bit):**
- Windows API integration
- PE executable format
- Built-in console output support

**Common Features:**
- Uses EDI for pointer arithmetic and a `locs` array for local storage
- Enhanced optimization with iterative peephole passes
- A-register variable for quick access operations

## Usage

### Command Line
```bash
make fcc                       # Compile the fcc program (creates fcl executable)
./fcl > output.asm             # Compile fcc.fth to assembly code (default)
./fcl myfile.fth > output.asm  # Compile specific file to assembly code
fasm output.asm program        # Assemble to executable using FASM
chmod +x program               # Make the program executable
./program                      # Run the program
```

### Error Handling
- Syntax errors show line number, column, and source context
- Fatal errors terminate compilation
- Warnings are displayed as comments in output

### Example Program
```forth
var counter
var limit 100 allot

: increment counter @ 1+ counter ! ;
: mil ( n--m ) 1000 dup * * ;

: main
  0 counter !
  1 mil limit !
  begin
    counter @ a!    // Store counter in A register
    a@ // Process counter value
    increment
    a@ limit @ >
  until
  // Program complete
;
```

## Compilation Process

1. **Input Processing** - Read source file (defaults to `fcl.fth` if no argument provided)
2. **IRL Generation** - Parse declarations and generate intermediate representation
3. **Iterative Optimization** - Repeatedly perform peephole optimizations until no changes
4. **Code Generation** - Output ELF assembly with startup code and runtime support
5. **Symbol Output** - Generate variable and string declarations with proper sizing in data section

## Limitations and Features

### Current Limitations
- No built-in I/O functions (must use system calls via `sys`)
- Limited error checking and recovery (errors output to stderr)
- No floating-point support
- Fixed-size tables and heap
- `else` clause not yet implemented

### Key Features
- Byte and word memory access (`c@`, `c!`, `@`, `!`)
- Direct system call support via register operations
- Pointer arithmetic and local array access via EDI and `locs`
- Variable-sized variable declarations with `allot`
- A-register variable for optimized frequent access
- Multi-base number literals (binary, decimal, hex, character)
- Iterative optimization passes for better code generation
- Compact, self-contained compiler
- Clean separation of IRL generation and code emission
- Stack-based execution model with register and pointer access
- Enhanced error reporting with stderr output

This compiler serves as an example of a minimal but functional compiler implementation, demonstrating core compiler concepts in a clear and understandable way.

/* Chris Curl, MIT license. */
/* Please see the README.md for details. */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "heap.h"

#define BTWI(n,l,h) ((l<=n)&&(n<=h))
#define BCASE break; case

//---------------------------------------------------------------------------
// Tokens
int ch = ' ', tok, is_num, digit, int_val;
FILE *input_fp = NULL;
char token[32], cur_line[256] = {0};
int is_eof = 0, cur_lnum, cur_off;
int stk[64], sp=0;

void push(int x) { stk[++sp] = x; }
int  pop() { return stk[sp--]; }

void statement();

void msg(int fatal, char *s) {
    printf("\n%s at(%d, %d)", s, cur_lnum, cur_off);
    printf("\n%s", cur_line);
    for (int i = 2; i < cur_off; i++) { printf(" "); } printf("^");
    if (fatal) { fprintf(stderr, "\n%s (see output for details)\n", s); exit(1); }
}
void syntax_error() { msg(1, "syntax error"); }

//---------------------------------------------------------------------------
// Lexer

void next_line() {
    cur_off = 0;
    cur_lnum++;
    if (fgets(cur_line, 256, input_fp) != cur_line) {
        is_eof = 1;
    }
}

void next_ch() {
    if (is_eof) { ch = EOF; return; }
    if (cur_line[cur_off] == 0) {
        next_line();
        if (is_eof) { ch = EOF; return; }
    }
    ch = cur_line[cur_off++];
    if (ch == 9) { ch = cur_line[cur_off-1] = 32; }
}

int strEq(char *s1, char *s2) { return (strcmp(s1, s2) == 0) ? 1 : 0; }

int isDigit(char c, int b) {
    if ((b == 2)  && (BTWI(c, '0','1'))) { digit = c - '0'; return 1; }
    if ((b == 8)  && (BTWI(c, '0','7'))) { digit = c - '0'; return 1; }
    if ((b == 10) && (BTWI(c, '0','9'))) { digit = c - '0'; return 1; }
    if (b == 16) {
        if (BTWI(c, '0','9')) { digit = c - '0'; return 1; }
        if (BTWI(c, 'A','F')) { digit = c - 'A' + 10; return 1; }
        if (BTWI(c, 'a','f')) { digit = c - 'a' + 10; return 1; }
    }
    return 0; 
}

int checkNumber(char *w, int base) {
    int_val = 0;
    if ((w[0] == '\'') && (w[2] == w[0]) && (w[3] == 0)) { int_val = w[1]; return 1; }
    if (*w == '%') { ++w; base = 2; }
    else if (*w == 'o') { ++w; base = 8; }
    else if (*w == '#') { ++w; base = 10; }
    else if (*w == '$') { ++w; base = 16; }
    if (*w == 0) { return 0; }
    while (*w) {
        if (isDigit(*(w++), base) == 0) { return 0; }
        int_val = (int_val* base) + digit;
    }
    return 1;
}

void next_token() {
    start:
    token[0] = 0;
    tok = 0;
    while (BTWI(ch, 1, 32)) { next_ch(); }
    if (ch == EOF) { return; }
    while (BTWI(ch, 33, 126)) {
        token[tok++] = ch;
        next_ch();
    }
    token[tok] = 0;
    if (strEq(token, "//")) { next_line(); goto start; }
    is_num = checkNumber(token, 10);
}

//---------------------------------------------------------------------------
// Symbols - 'I' = INT, 'F' = Function, 'S' = String, 'T' = Target
typedef struct { char type, name[23]; char asmName[8]; int sz; } SYM_T;
typedef struct { char name[32]; char *val; } STR_T;

SYM_T vars[500];
STR_T strings[500];
int numVars, numStrings;

int  varType(int i)  { return vars[i].type; }
char *varName(int i) { return vars[i].name; }
char *asmName(int i) { return vars[i].asmName; }
int accept(char *str) { return strEq(token, str); }

int findVar(char *name, char type) {
    int i = numVars;
    while (0 < i) {
        if (strEq(varName(i), name)) {
            if ((varType(i) == type)) { return i; }
        }
        i = i-1;
    }
    return 0;
}

int addVar(char *name, char type) {
    if (strlen(name) > 20) { msg(1, "name too long"); }
    int i = ++numVars;
    SYM_T *x = &vars[i];
    x->type = type;
    x->sz = 4;
    strcpy(x->name, name);
    sprintf(x->asmName, "%c%d", type, i);
    return i;
}

int addFunction(char *name) {
    return addVar(name, 'F');
}

int genTargetSymbol() {
    static char name[8];
    static int seq = 0;
    sprintf(name, "Tgt%d", ++seq);
    return addVar(name, 'T');
}

int addString(char *str) {
    int i = ++numStrings;
    sprintf(strings[i].name, "S%d", i);
    strings[i].val = hAlloc(strlen(str) + 1);
    strcpy(strings[i].val, str);
    return i;
}

void dumpSymbols() {
    printf("\n\n; symbols: %d entries, %d used\n", 100, numVars);
    printf("; num type size name\n");
    printf("; --- ---- ---- -----------------\n");
    for (int i = 1; i <= numVars; i++) {
        SYM_T *x = &vars[i];
        if (x->type == 'I') { printf("%-10s dd 0 ; %s\n", x->asmName, x->name); }
        if (x->type == 'C') { printf("%-10s db %d DUP(0) ; %s\n", x->asmName, x->sz, x->name); }
    }
    for (int i = 1; i <= numStrings; i++) {
        STR_T *x = &strings[i];
        printf("%-10s db \"%s\", 0\n", x->name, x->val);
    }
    printf("rstk       rd 256\n");
}

//---------------------------------------------------------------------------
// IRL
enum { NOTHING, VARADDR, LIT, LOADSTR, STORE, FETCH
    , ADD, SUB, MULT, DIVIDE
    , DUP, DROP, SWAP, OVER
    , AND, OR, XOR
    , JMP, JMPZ, JMPNZ, TARGET
    , DEF, CALL, RETURN
    , LT, GT, EQ, NEQ
    , PLEQ, DECTOS, INCTOS
};

int opcodes[10000], arg1[10000], here;

void gInit() { here = 0; }
void gen(int op) { ++here; opcodes[here] = op; }
void gen1(int op, int a1) { gen(op); arg1[here] = a1; }

void optimizeIRL() {
    int i = 1;
    while (i <= here) {
        int op = opcodes[i];
        int a1 = arg1[i];
        i++;
    }
}

void genStartupCode() {
    printf("\ninit:\n\tLEA EBP, [rstk]\n\tRET\n");

    printf("\nRETtoEBP:    ; Move the return addr to the [EBP] stack");
    printf("\n\tPOP  EDX ; NB: EDX is destroyed");
    printf("\n\tADD  EBP, 4");
    printf("\n\tPOP  DWORD [EBP]");
    printf("\n\tPUSH EDX");
    printf("\n\tRET\n");

    printf("\nRETfromEBP:  ; Perform a return from the [EBP] stack");
    printf("\n\tPUSH DWORD [EBP]");
    printf("\n\tSUB  EBP, 4");
    printf("\n\tRET");
}

void genCode() {
    genStartupCode();
    int i = 1;
    while (i <= here) {
        int op = opcodes[i];
        int a1 = arg1[i];
        char *vn = varName(a1), *an = asmName(a1);
        switch (op) {
        // printf("\n; %3d: %-3d %-3d %-5d\n\t", i, op, a1, a2);
            case VARADDR:  printf("\n\tPUSH EAX\n\tLEA  EAX, [%s] ; %s", an, vn);
            BCASE LIT:     printf("\n\tPUSH EAX\n\tMOV  EAX, %d", a1);
            BCASE DUP:     printf("\n\tPUSH EAX");
            BCASE DROP:    printf("\n\tPOP  EAX");
            BCASE SWAP:    printf("\n\tXCHG EAX, [ESP]");
            BCASE OVER:    printf("\n\tPUSH EAX\n\tMOV  EAX, [ESP+4]");
            BCASE LOADSTR: printf("\n\tPUSH EAX\n\tLEA  EAX, [%s]", strings[a1].name);
            BCASE STORE:   printf("\n\tPOP  ECX\n\tMOV  [EAX], ECX\n\tPOP  EAX");
            BCASE FETCH:   printf("\n\tMOV  EAX, [EAX]");
            BCASE PLEQ:    printf("\n\tPOP  EBX\n\tADD  [EAX], EBX\n\tPOP  EAX");
            BCASE DECTOS:  printf("\n\tDEC  EAX");
            BCASE INCTOS:  printf("\n\tINC  EAX");
            BCASE ADD:     printf("\n\tPOP  EBX\n\tADD  EAX, EBX");
            BCASE SUB:     printf("\n\tPOP  EBX\n\tXCHG EAX, EBX\n\tSUB  EAX, EBX");
            BCASE MULT:    printf("\n\tPOP  EBX\n\tIMUL EAX, EBX");
            BCASE DIVIDE:  printf("\n\tPOP  EBX\n\tXCHG EAX, EBX\n\tCDQ\n\tIDIV EBX");
            BCASE LT:      printf("\n\tPOP  EBX\n\tCMP  EBX, EAX\n\tMOV  EAX, 0\n\tJGE  @F\n\tDEC  EAX\n@@:");
            BCASE GT:      printf("\n\tPOP  EBX\n\tCMP  EBX, EAX\n\tMOV  EAX, 0\n\tJLE  @F\n\tDEC  EAX\n@@:");
            BCASE EQ:      printf("\n\tPOP  EBX\n\tCMP  EBX, EAX\n\tMOV  EAX, 0\n\tJNZ  @F\n\tDEC  EAX\n@@:");
            BCASE NEQ:     printf("\n\tPOP  EBX\n\tCMP  EBX, EAX\n\tMOV  EAX, 0\n\tJE   @F\n\tDEC  EAX\n@@:");
            BCASE DEF:     printf("\n\n%s: ; %s\n\tCALL RETtoEBP", an, vn);
            BCASE CALL:    printf("\n\tCALL %s ; %s", an, vn);
            BCASE RETURN:  printf("\n\tJMP  RETfromEBP");
            BCASE TARGET:  printf("\n%s:", vn);
            BCASE JMP:     printf("\n\tJMP  %s", vn);
            BCASE JMPZ:    printf("\n\tTEST EAX, EAX\n\tJZ   %s", vn);
            BCASE JMPNZ:   printf("\n\tTEST EAX, EAX\n\tJNZ  %s", vn);
        }
        i++;
    }
}

//---------------------------------------------------------------------------
// Parser / code generator.
void winLin(int seg) {
#ifdef _WIN32
    // Windows (32-bit)
    if (seg == 'C') {
        char *pv = asmName(findVar("pv", 'I'));
        printf("format PE console");
        printf("\ninclude 'win32ax.inc'\n");
        printf("\n; ======================================= ");
        printf("\nsection '.code' code readable executable");
        printf("\n;=======================================*/");
        printf("\nstart:\n\tCALL init");
        printf("\n\tCALL %s\n", asmName(findVar("main", 'F')));
        printf("\n;================== library ==================");
        printf("\n%s:\n\tPUSH 0\n\tCALL [ExitProcess]\n", asmName(findVar("bye", 'F')));
        printf("\n;=============================================");
        printf("\n%s: ; puts", asmName(findVar("puts", 'F')));
        printf("\n\tCALL RETtoEBP");
        printf("\n\tMOV [%s], EAX", pv);
        printf("\n\tcinvoke printf, \"%s\", [%s]", "%s", pv);
        printf("\n\tPOP EAX");
        printf("\n\tJMP RETfromEBP");
        
        printf("\n\n%s: ; emit", asmName(findVar("emit", 'F')));
        printf("\n\tCALL RETtoEBP");
        printf("\n\tMOV [%s], EAX", pv);
        printf("\n\tcinvoke printf, \"%s\", [%s]", "%c", pv);
        printf("\n\tPOP EAX");
        printf("\n\tJMP RETfromEBP");

        printf("\n\n%s: ; .d", asmName(findVar(".d", 'F')));
        printf("\n\tCALL RETtoEBP");
        printf("\n\tMOV [%s], EAX", pv);
        printf("\n\tcinvoke printf, \"%s\", [%s]", "%d", pv);
        printf("\n\tPOP EAX");
        printf("\n\tJMP RETfromEBP");
    }
    else if (seg == 'D') {
        printf("\n\n;================== data =====================");
        printf("\nsection '.data' data readable writeable");
        printf("\n;=============================================");
    }
    else if (seg == 'I') {
        printf("\n;====================================");
        printf("\nsection '.idata' import data readable");
        printf("\n; ====================================");
        printf("\nlibrary msvcrt, 'msvcrt.dll', kernel32, 'kernel32.dll'");
        printf("\nimport msvcrt, printf,'printf', getch,'_getch'");
        printf("\nimport kernel32, ExitProcess,'ExitProcess'\n");
    }
#else
    // Linux (32-bit)
    if (seg == 'C') {
        char *pv = asmName(findVar("pv", 'I'));
        printf("format ELF executable");
        printf("\n;================== code =====================");
        printf("\nsegment readable executable");
        printf("\n;================== library ==================");
        printf("\nstart:\n\tCALL init");
        printf("\n\tCALL %s ; main", asmName(findVar("main", 'F')));
        printf("\n\n%s: ; bye", asmName(findVar("bye", 'F')));
        printf("\n\tMOV  EAX, 1");
        printf("\n\tXOR  EBX, EBX");
        printf("\n\tINT  0x80");

        printf("\n\n%s: ; puts", asmName(findVar("puts", 'F')));
        printf("\n\t; TODO: fill this in");
        printf("\n\tCALL RETtoEBP");
        printf("\n\tMOV  [%s], EAX", pv);
        printf("\n\tPOP  EAX");
        printf("\n\tJMP  RETfromEBP");
        
        printf("\n\n%s: ; emit", asmName(findVar("emit", 'F')));
        printf("\n\tCALL RETtoEBP");
        printf("\n\tMOV  [%s], EAX", pv);
        printf("\n\tMOV  EAX, 4");
        printf("\n\tMOV  EBX, 0");
        printf("\n\tLEA  ECX, [%s]", pv);
        printf("\n\tMOV  EDX, 1");
        printf("\n\tINT  0x80");
        printf("\n\tPOP  EAX");
        printf("\n\tJMP  RETfromEBP");
        
        printf("\n\n%s: ; .d", asmName(findVar(".d", 'F')));
        printf("\n\tCALL RETtoEBP");
        printf("\n\t; TODO: fill this in");
        printf("\n\tMOV  [%s], EAX", pv);
        printf("\n\tPOP  EAX");
        printf("\n\tJMP  RETfromEBP");
        printf("\n;=============================================");
    }
    else if (seg == 'D') {
        printf("\n;================== data =====================");
        printf("\nsegment readable writeable");
        printf("\n;=============================================");
    }
#endif
    if (seg == 'S') {
        addFunction("bye");
        addFunction("puts");
        addFunction("emit");
        addFunction(".d");
        addVar("pv", 'I');
    }
}

void ifStmt() { push(genTargetSymbol()); gen1(JMPZ, stk[sp]); }
void elseStmt() { printf("\n\t; WARNING - ELSE not yet implemented"); }
void thenStmt() { gen1(TARGET, pop()); }
void beginStmt() { push(genTargetSymbol()); gen1(TARGET, stk[sp]); }
void whileStmt() { gen1(JMPNZ, pop()); }
void untilStmt() { gen1(JMPZ, pop()); }
void againStmt() { gen1(JMP, pop()); }

char tmpStr[256];
void stringStmt() {
    int i = 0;
    next_ch();
    while (ch != '"') {
        if (ch == EOF) { syntax_error(); }
        tmpStr[i++] = ch;
        next_ch();
    }
    tmpStr[i] = 0;
    next_ch();
    i = addString(tmpStr);
    gen1(LOADSTR, i);
}

void statement() {
    if (is_num) { gen1(LIT, int_val); return; }
    int i = findVar(token, 'I');
    if (i) { gen1(VARADDR, i); return; }
    i = findVar(token, 'F');
    if (i) { gen1(CALL, i); return; }
    
    if (accept("@"))    { gen(FETCH); }
    else if (accept("!"))     { gen(STORE); }
    else if (accept("1+"))    { gen(INCTOS); }
    else if (accept("1-"))    { gen(DECTOS); }
    else if (accept("if"))    { ifStmt(); }
    else if (accept("else"))  { elseStmt(); }
    else if (accept("then"))  { thenStmt(); }
    else if (accept("begin")) { beginStmt(); }
    else if (accept("while")) { whileStmt(); }
    else if (accept("until")) { untilStmt(); }
    else if (accept("again")) { againStmt(); }
    else if (accept("exit"))  { gen(RETURN); }
    else if (accept("dup"))   { gen(DUP); }
    else if (accept("drop"))  { gen(DROP); }
    else if (accept("swap"))  { gen(SWAP); }
    else if (accept("over"))  { gen(OVER); }
    else if (accept(";"))     { gen(RETURN); }
    else if (accept("+!"))    { gen(PLEQ); }
    else if (accept("+"))     { gen(ADD); }
    else if (accept("-"))     { gen(SUB); }
    else if (accept("*"))     { gen(MULT); }
    else if (accept("/"))     { gen(DIVIDE); }
    else if (accept("<"))     { gen(LT); }
    else if (accept(">"))     { gen(EQ); }
    else if (accept("="))     { gen(GT); }
    else if (accept("\""))    { stringStmt(); }
    else if (accept(""))      { return; }
    else { syntax_error(); }
}

void funcDef() {
    next_token();
    int s = addVar(token, 'F');
    gen1(DEF, s);
    while (1) {
        next_token();
        statement();
        if (accept(";")) { return; }
    }
}

void parseVar() {
    next_token();
    addVar(token, 'I');
}

void parseDef() {
    if (accept("var")) { parseVar(); }
    else if (accept(":")) { funcDef(); }
    else { statement(); }
}

/*---------------------------------------------------------------------------*/
/* Main program. */
int main(int argc, char *argv[]) {
    char *fn = (argc > 1) ? argv[1] : NULL;
    input_fp = stdin;
    if (fn) {
        input_fp = fopen(fn, "rt");
        if (!input_fp) { msg(1, "cannot open source file!"); }
    }
    winLin('S');
    while (ch != EOF) { next_token(); parseDef(); }
    if (input_fp) { fclose(input_fp); }
    optimizeIRL();
    winLin('C');
    genCode();
    winLin('D');
    dumpSymbols();
    winLin('I');
    return 0;
}

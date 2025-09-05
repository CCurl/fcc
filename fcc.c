/* Chris Curl, MIT license, (c) 2025. */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define VARS_SZ    500
#define STRS_SZ    500
#define CODE_SZ   5000
#define HEAP_SZ   5000

#define BTWI(n,l,h) ((l <= n) && (n <= h))
#define BCASE break; case

typedef struct { char type, name[23]; char asmName[8]; int sz; } SYM_T;
typedef struct { char name[32]; char *val; } STR_T;

int ch = ' ', is_num, int_val;
int is_eof = 0, cur_lnum, cur_off, stk[64], sp=0;
int numVars, numStrings;
int opcodes[CODE_SZ], arg1[CODE_SZ], here;
char token[32], cur_line[256] = {0};
char heap[HEAP_SZ];
SYM_T vars[VARS_SZ];
STR_T strings[STRS_SZ];
FILE *input_fp = NULL;

//---------------------------------------------------------------------------
// Utilities
void push(int x) { stk[++sp] = x; }
int  pop() { return stk[sp--]; }
int strEq(char *s1, char *s2) { return (strcmp(s1, s2) == 0) ? 1 : 0; }
int accept(char *str) { return strEq(token, str); }
char *varName(int i) { return vars[i].name; }
char *asmName(int i) { return vars[i].asmName; }
void gen(int op) { ++here; opcodes[here] = op; }
void gen1(int op, int a1) { gen(op); arg1[here] = a1; }

void msg(int fatal, char *s) {
    printf("\n%s at(%d, %d)\n%s", s, cur_lnum, cur_off, cur_line);
    for (int i = 2; i < cur_off; i++) { printf(" "); } printf("^");
    if (fatal) { fprintf(stderr, "\n%s (see output for details)\n", s); exit(1); }
}

char *hAlloc(int sz) {
    static int hHere = 0;
    int newHere = hHere + sz;
    if ((sz <= 0) || (HEAP_SZ <= newHere)) { return NULL; }
    hHere = newHere;
    return &heap[hHere - sz];
}

//---------------------------------------------------------------------------
// Tokens
void next_line() {
    cur_off = 0;
    cur_lnum++;
    if (fgets(cur_line, 256, input_fp) != cur_line) { is_eof = 1; }
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

int checkNumber(char *w, int base) {
    int isNeg = 0;
    int_val = 0;
    if ((w[0] == '\'') && (w[2] == w[0]) && (w[3] == 0)) { int_val = w[1]; return 1; }
    if (*w == '%') { ++w; base = 2; }
    else if (*w == '#') { ++w; base = 10; }
    else if (*w == '$') { ++w; base = 16; }
    if (*w == '-') { isNeg = 1; ++w; }
    if (*w == 0) { return 0; }
    while (*w) {
        char c = *(w++), digit = 99;
        if (BTWI(c, '0', '9')) { digit = c - '0'; }
        else if (BTWI(c, 'A', 'F')) { digit = c - 'A' + 10; }
        else if (BTWI(c, 'a', 'f')) { digit = c - 'a' + 10; }
        else { return 0; }
        if (digit >= base) { return 0; }
        int_val = (int_val * base) + digit;
    }
    if (isNeg) { int_val = -int_val; }
    return 1;
}

void next_token() {
    int len;
    start:
    len = 0;
    while (BTWI(ch, 1, 32)) { next_ch(); }
    while (BTWI(ch, 33, 126)) { token[len++] = ch; next_ch(); }
    token[len] = 0;
    if (strEq(token, "//")) { next_line(); goto start; }
    is_num = checkNumber(token, 10);
}

//---------------------------------------------------------------------------
// Symbols - 'I' = INT, 'F' = Function, 'T' = Target
int findSymbol(char *name, char type) {
    for (int i = numVars; 0 < i; i--) {
        if (strEq(varName(i), name) && (vars[i].type == type)) { return i; }
    }
    return 0;
}

int addSymbol(char *name, char type) {
    if (strlen(name) > 20) { msg(1, "name too long"); }
    int i = ++numVars;
    SYM_T *x = &vars[i];
    x->type = type;
    x->sz = 4;
    strcpy(x->name, name);
    sprintf(x->asmName, "%c%d", type, i);
    return i;
}

int genTargetSymbol() {
    static int seq = 0;
    char name[8];
    sprintf(name, "Tgt%d", ++seq);
    return addSymbol(name, 'T');
}

int addString(char *str) {
    int i = ++numStrings;
    sprintf(strings[i].name, "S%d", i);
    strings[i].val = hAlloc(strlen(str) + 1);
    strcpy(strings[i].val, str);
    return i;
}

//---------------------------------------------------------------------------
// IRL
enum { NOTHING, VARADDR, LIT, LOADSTR
    , STORE, FETCH, CSTORE, CFETCH
    , ADD, SUB, MULT, DIVIDE, DIVMOD
    , AND, OR, XOR
    , POPA, PUSHA, SWAP, SP4
    , JMP, JMPZ, JMPNZ, TARGET
    , DEF, CALL, RETURN
    , LT, GT, EQ, NEQ
    , PLEQ, DECTOS, INCTOS
    , MOVAB, POPB, TESTA
};

void optimizeIRL() {
    for (int i = 1; i <= here; i++) {
        int op = opcodes[i], op1 = opcodes[i+1], op2 = opcodes[i+2];
        if ((op == POPA) && (op1 == PUSHA)) {
            // NOTE: this assumes we modifying EAX next
            opcodes[i] = NOTHING;
            opcodes[i+1] = NOTHING;
        }
        if ((op == PUSHA) && (op1 == POPB)) {
            opcodes[i] = MOVAB;
            opcodes[i+1] = NOTHING;
        }
        if ((op == PUSHA) && (op2 == POPB)) {
            opcodes[i] = MOVAB;
            opcodes[i+2] = NOTHING;
        }
        if (((op == INCTOS) || (op == DECTOS)) && (op1 == TESTA)) {
            opcodes[i+1] = NOTHING;
        }
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
    printf("\n;=============================================");
}

void genCode() {
    genStartupCode();
    for (int i = 1; i <= here; i++) {
        int op = opcodes[i];
        int a1 = arg1[i];
        char *vn = varName(a1), *an = asmName(a1);
        // printf("\n; %3d: %-3d %-3d %-5d\n\t", i, op, a1, a2);
        switch (op) {
            case VARADDR:  printf("\n\tLEA  EAX, [%s] ; %s", an, vn);
            BCASE LIT:     printf("\n\tMOV  EAX, %d", a1);
            BCASE PUSHA:   printf("\n\tPUSH EAX"); // DUP
            BCASE POPA:    printf("\n\tPOP  EAX"); // DROP
            BCASE POPB:    printf("\n\tPOP  EBX");
            BCASE SWAP:    printf("\n\tXCHG EAX, [ESP]");
            BCASE SP4:     printf("\n\tMOV  EAX, [ESP+4]"); // Used by OVER
            BCASE LOADSTR: printf("\n\tLEA  EAX, [%s]", strings[a1].name);
            BCASE STORE:   printf("\n\tMOV  [EAX], EBX");
            BCASE CSTORE:  printf("\n\tMOV  [EAX], BL");
            BCASE FETCH:   printf("\n\tMOV  EAX, [EAX]");
            BCASE CFETCH:  printf("\n\tMOV  AL, [EAX]\n\tAND  EAX, 0xFF");
            BCASE PLEQ:    printf("\n\tADD  [EAX], EBX");
            BCASE DECTOS:  printf("\n\tDEC  EAX");
            BCASE INCTOS:  printf("\n\tINC  EAX");
            BCASE ADD:     printf("\n\tADD  EAX, EBX");
            BCASE SUB:     printf("\n\tXCHG EAX, EBX\n\tSUB  EAX, EBX");
            BCASE MULT:    printf("\n\tIMUL EAX, EBX");
            BCASE DIVIDE:  printf("\n\tXCHG EAX, EBX\n\tCDQ\n\tIDIV EBX");
            BCASE DIVMOD:  printf("\n\tXCHG EAX, EBX\n\tCDQ\n\tIDIV EBX\n\tPUSH EDX");
            BCASE AND:     printf("\n\tAND  EAX, EBX");
            BCASE OR:      printf("\n\tOR   EAX, EBX");
            BCASE XOR:     printf("\n\tXOR  EAX, EBX");
            BCASE LT:      printf("\n\tCMP  EBX, EAX\n\tMOV  EAX, 0\n\tJGE  @F\n\tDEC  EAX\n@@:");
            BCASE GT:      printf("\n\tCMP  EBX, EAX\n\tMOV  EAX, 0\n\tJLE  @F\n\tDEC  EAX\n@@:");
            BCASE EQ:      printf("\n\tCMP  EBX, EAX\n\tMOV  EAX, 0\n\tJNZ  @F\n\tDEC  EAX\n@@:");
            BCASE NEQ:     printf("\n\tCMP  EBX, EAX\n\tMOV  EAX, 0\n\tJE   @F\n\tDEC  EAX\n@@:");
            BCASE DEF:     printf("\n\n%s: ; %s\n\tCALL RETtoEBP", an, vn);
            BCASE CALL:    printf("\n\tCALL %s ; %s", an, vn);
            BCASE RETURN:  printf("\n\tJMP  RETfromEBP");
            BCASE TARGET:  printf("\n%s:", vn);
            BCASE JMP:     printf("\n\tJMP  %s", vn);
            BCASE JMPZ:    printf("\n\tJZ   %s", vn);
            BCASE JMPNZ:   printf("\n\tJNZ  %s", vn);
            BCASE MOVAB:   printf("\n\tMOV  EBX, EAX");
            BCASE TESTA:   printf("\n\tTEST EAX, EAX");
        }
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
        printf("\n;=============================================");
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
        char *pv = asmName(findSymbol("pv", 'I'));
        printf("\nformat ELF executable");
        printf("\n;================== code =====================");
        printf("\nsegment readable executable");
        printf("\n;================== library ==================");
        printf("\nstart:\n\tCALL init");
        printf("\n\tCALL %s ; main", asmName(findSymbol("main", 'F')));
        printf("\n\n%s: ; bye", asmName(findSymbol("bye", 'F')));
        printf("\n\tMOV  EAX, 1");
        printf("\n\tXOR  EBX, EBX");
        printf("\n\tINT  0x80");

        printf("\n\n%s: ; puts", asmName(findSymbol("puts", 'F')));
        printf("\n\tCALL RETtoEBP");
        printf("\n\tMOV  ECX, EAX");
        printf("\n\tMOV  EDX, EAX");
        printf("\n.strlen:");
        printf("\n\tCMP  BYTE [EDX], 0");
        printf("\n\tJE   .done");
        printf("\n\tINC  EDX");
        printf("\n\tJMP  .strlen");
        printf("\n.done:");
        printf("\n\tSUB  EDX, ECX");
        printf("\n\tMOV  EAX, 4");
        printf("\n\tMOV  EBX, 1");
        printf("\n\tINT  0x80");
        printf("\n\tPOP  EAX");
        printf("\n\tJMP  RETfromEBP");
        
        printf("\n\n%s: ; emit", asmName(findSymbol("emit", 'F')));
        printf("\n\tCALL RETtoEBP");
        printf("\n\tMOV  [%s], EAX", pv);
        printf("\n\tMOV  EAX, 4");
        printf("\n\tMOV  EBX, 0");
        printf("\n\tLEA  ECX, [%s]", pv);
        printf("\n\tMOV  EDX, 1");
        printf("\n\tINT  0x80");
        printf("\n\tPOP  EAX");
        printf("\n\tJMP  RETfromEBP");
        
        printf("\n\n%s: ; .d", asmName(findSymbol(".d", 'F')));
        printf("\n\tCALL RETtoEBP");
        // Convert integer in EAX to string in [intbuf]");
        printf("\n\tMOV  [%s], 0", pv);
        printf("\n\tMOV  ECX, intbuf+11");
        printf("\n\tCMP  EAX, 0");
        printf("\n\tJGE  .convert");
        printf("\n\tNEG  EAX");
        printf("\n\tINC  [%s]", pv);
        printf("\n.convert:");
        printf("\n\tMOV  EBX, 10");
        printf("\n.repeat:");
        printf("\n\tMOV  EDX, 0");
        printf("\n\tDIV  EBX");
        printf("\n\tADD  DL, '0'");
        printf("\n\tDEC  ECX");
        printf("\n\tMOV  [ECX], DL");
        printf("\n\tTEST EAX, EAX");
        printf("\n\tJNZ  .repeat");
        // Print the string
        printf("\n\tMOV  EAX, [%s]", pv);
        printf("\n\tTEST EAX, EAX");
        printf("\n\tJZ   .pr");
        printf("\n\tDEC  ECX");
        printf("\n\tMOV  BYTE [ECX], '-'");
        printf("\n.pr:");
        printf("\n\tMOV  EAX, 4");
        printf("\n\tMOV  EBX, 1");
        printf("\n\tMOV  EDX, intbuf+11");
        printf("\n\tSUB  EDX, ECX");
        printf("\n\tINT  0x80");
        printf("\n\tPOP  EAX");
        printf("\n\tJMP  RETfromEBP");
        printf("\n;=============================================");
    }
    else if (seg == 'D') {
        printf("\n;================== data =====================");
        printf("\nsegment readable writeable");
        printf("\n;=============================================");
        printf("\nintbuf      rb 12 ; for .d");
    }
#endif
    if (seg == 'S') {
        addSymbol("bye", 'F');
        addSymbol("puts", 'F');
        addSymbol("emit", 'F');
        addSymbol(".d", 'F');
        addSymbol("pv", 'I');
    }
}

void stringStmt() {
    char tmpStr[256], i = 0;
    next_ch();
    while (ch != '"') {
        if (ch == EOF) { msg(1, "syntax error"); }
        tmpStr[i++] = ch;
        next_ch();
    }
    tmpStr[i] = 0;
    next_ch();
    gen(PUSHA);
    gen1(LOADSTR, addString(tmpStr));
}

void statement() {
    if (is_num) { gen(PUSHA); gen1(LIT, int_val); return; }
    int i = findSymbol(token, 'I');
    if (i) { gen(PUSHA); gen1(VARADDR, i); return; }
    i = findSymbol(token, 'F');
    if (i) { gen1(CALL, i); return; }
    
    if (accept("@"))          { gen(FETCH); }
    else if (accept("c@"))    { gen(CFETCH); }
    else if (accept("!"))     { gen(POPB); gen(STORE); gen(POPA); }
    else if (accept("c!"))    { gen(POPB); gen(CSTORE); gen(POPA); }
    else if (accept("1+"))    { gen(INCTOS); }
    else if (accept("1-"))    { gen(DECTOS); }
    else if (accept("if"))    { push(genTargetSymbol()); gen(TESTA); gen1(JMPZ, stk[sp]); }
    else if (accept("else"))  { printf("\n\t; WARNING - ELSE not yet implemented"); }
    else if (accept("then"))  { gen1(TARGET, pop()); }
    else if (accept("begin")) { push(genTargetSymbol()); gen1(TARGET, stk[sp]); }
    else if (accept("while")) { gen(TESTA); gen1(JMPNZ, pop()); }
    else if (accept("until")) { gen(TESTA); gen1(JMPZ, pop()); }
    else if (accept("again")) { gen1(JMP, pop()); }
    else if (accept("exit"))  { gen(RETURN); }
    else if (accept("dup"))   { gen(PUSHA); }
    else if (accept("drop"))  { gen(POPA); }
    else if (accept("swap"))  { gen(SWAP); }
    else if (accept("over"))  { gen(PUSHA); gen(SP4); }
    else if (accept(";"))     { gen(RETURN); }
    else if (accept("+!"))    { gen(POPB); gen(PLEQ); gen(POPA); }
    else if (accept("+"))     { gen(POPB); gen(ADD); }
    else if (accept("-"))     { gen(POPB); gen(SUB); }
    else if (accept("*"))     { gen(POPB); gen(MULT); }
    else if (accept("/mod"))  { gen(POPB); gen(DIVMOD); }
    else if (accept("/"))     { gen(POPB); gen(DIVIDE); }
    else if (accept("<"))     { gen(POPB); gen(LT); }
    else if (accept("="))     { gen(POPB); gen(EQ); }
    else if (accept("<>"))    { gen(POPB); gen(NEQ); }
    else if (accept(">"))     { gen(POPB); gen(GT); }
    else if (accept("AND"))   { gen(POPB); gen(AND); }
    else if (accept("OR"))    { gen(POPB); gen(OR); }
    else if (accept("XOR"))   { gen(POPB); gen(XOR); }
    else if (accept("\""))    { stringStmt(); }
    else if (accept("("))     { while (!accept(")")) { next_token(); } }
    else if (accept(""))      { return; }
    else { msg(1, "syntax error"); }
}

void funcDef() {
    next_token();
    gen1(DEF, addSymbol(token, 'F'));
    while (1) {
        next_token();
        statement();
        if (accept(";")) { return; }
    }
}

/*---------------------------------------------------------------------------*/
int main(int argc, char *argv[]) {
    char *fn = (argc > 1) ? argv[1] : NULL;
    input_fp = stdin;
    if (fn) {
        input_fp = fopen(fn, "rt");
        if (!input_fp) { msg(1, "cannot open source file!"); }
    }
    here = 0;
    winLin('S');
    while (ch != EOF) {
        next_token();
        if (accept("var")) { next_token(); addSymbol(token, 'I'); }
        else if (accept(":")) { funcDef(); }
        else if (token[0]) { msg(1, "syntax error"); }
    }
    if (input_fp) { fclose(input_fp); }
    optimizeIRL();
    winLin('C');
    genCode();
    winLin('D');
    printf("\n\n; symbols: %d entries, %d used\n", VARS_SZ, numVars);
    printf("; num type size name\n");
    printf("; --- ---- ---- -----------------\n");
    for (int i = 1; i <= numVars; i++) {
        if (vars[i].type == 'I') { printf("%-10s dd 0 ; %s\n", asmName(i), varName(i)); }
    }
    for (int i = 1; i <= numStrings; i++) {
        printf("%-10s db \"%s\", 0\n", strings[i].name, strings[i].val);
    }
    printf("rstk       rd 256\n");
    winLin('I');
    return 0;
}

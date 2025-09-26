/* Chris Curl, MIT license, (c) 2025. */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//---------------------------------------------------------------------------
extern char *asmName(int sym);
extern int findSymbol(char *name, char type);
extern int addSymbol(char *name, char type);
void genSysSpecific(int seg);

void genStartupCode() {
    printf("\nstart:\n\tLEA  EBP, [rstk]\n\tLEA  EDI, [locs]");
    printf("\n\tCALL %s", asmName(findSymbol("main", 'F')));
    printf("\n\tJMP  %s", asmName(findSymbol("bye", 'F')));
    printf("\n;---------------------------------------------");
    printf("\nRETtoEBP:    ; Move the return addr to the [EBP] stack");
    printf("\n\tPOP  EDX ; NB: EDX is destroyed");
    printf("\n\tADD  EBP, 4");
    printf("\n\tPOP  DWORD [EBP]");
    printf("\n\tPUSH EDX");
    printf("\n\tRET\n");
    printf("\n;---------------------------------------------");
    printf("\nRETfromEBP:  ; Perform a return from the [EBP] stack");
    printf("\n\tPUSH DWORD [EBP]");
    printf("\n\tSUB  EBP, 4");
    printf("\n\tRET");
    printf("\n;=============================================");
}

//---------------------------------------------------------------------------
void genSysSpecific(int seg) {
#ifdef _WIN32
    if (seg == 'S') {
        addSymbol("bye", 'F');
        addSymbol("emit", 'F');
    }
    if (seg == 'C') {
        printf("format PE console");
        printf("\ninclude 'win32ax.inc'\n");
        printf("\n;=============================================");
        printf("\nsection '.code' code readable executable");
    }
    else if (seg == 'L') {
        printf("\n;================== library (Windows) ==================");
        printf("\n%s: ; bye\n\tPUSH 0\n\tCALL [ExitProcess]\n", asmName(findSymbol("bye", 'F')));
        printf("\n;---------------------------------------------");
        char *s = asmName(addSymbol("pv", 'I'));
        printf("\n;---------------------------------------------");
        printf("\n%s: ; emit", asmName(findSymbol("emit", 'F')));
        printf("\n\tCALL RETtoEBP");
        printf("\n\tMOV [%s], EAX", s);
        printf("\n\tcinvoke printf, \"%s\", [%s]", "%c", s);
        printf("\n\tPOP EAX");
        printf("\n\tJMP RETfromEBP");
    }
    else if (seg == 'D') {
        printf("\n\n;================== data =====================");
        printf("\nsection '.data' data readable writeable");
        printf("\n;---------------------------------------------");
    }
    else if (seg == 'I') {
        printf("\n;====================================");
        printf("\nsection '.idata' import data readable");
        printf("\n; ====================================");
        printf("\nlibrary msvcrt, 'msvcrt.dll', kernel32, 'kernel32.dll'");
        printf("\nimport msvcrt, printf,'printf', getch,'_getch'");
        printf("\nimport kernel32, ExitProcess,'ExitProcess'\n");
    }
#else // Must be Linux
    if (seg == 'C') {
        printf("format ELF executable");
        printf("\n;================== code =====================");
        printf("\nsegment readable executable");
    }
    else if (seg == 'L') {
        printf("\n;================== library (Linux) ==================");
    }
    else if (seg == 'D') {
        printf("\n\n;================== data =====================");
        printf("\nsegment readable writeable");
    }
    else if (seg == 'I') {
    }
#endif
}

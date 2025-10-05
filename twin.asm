format PE console
include 'win32ax.inc'

;=============================================
section '.code' code readable executable
;=============================================
start:
	LEA  EBP, [rstk]
	LEA  EDI, [locs]
	CALL F62
	JMP  F1
;---------------------------------------------
RETtoEBP: ; Move the return addr to the [EBP] stack
	POP  ESI ; NB: ESI is destroyed
	ADD  EBP, 4
	POP  DWORD [EBP]
	PUSH ESI
	RET
;---------------------------------------------
RETfromEBP: ; Perform a return from the [EBP] stack
	PUSH DWORD [EBP]
	SUB  EBP, 4
	RET
;================== library (Windows) ==================
F1: ; bye
	PUSH 0
	CALL [ExitProcess]
;---------------------------------------------
F2: ; emit
	CALL RETtoEBP
	MOV [I64], EAX
	cinvoke printf, "%c", [I64]
	POP EAX
	JMP RETfromEBP
;=============================================

F4: ; @a
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [A]
	MOV  EAX, [EAX]
	JMP  RETfromEBP

F5: ; !a
	CALL RETtoEBP
	MOV  EBX, EAX
	MOV  EAX, [A]
	MOV  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F6: ; @a+
	CALL RETtoEBP
	CALL F4 ; @a
	PUSH EAX
	MOV  EAX, [A]
	ADD  EAX, 4
	MOV  [A], EAX
	POP  EAX
	JMP  RETfromEBP

F7: ; !a+
	CALL RETtoEBP
	CALL F5 ; !a
	PUSH EAX
	MOV  EAX, [A]
	ADD  EAX, 4
	MOV  [A], EAX
	POP  EAX
	JMP  RETfromEBP

F8: ; @a-
	CALL RETtoEBP
	CALL F4 ; @a
	PUSH EAX
	MOV  EAX, [A]
	SUB  EAX, 4
	MOV  [A], EAX
	POP  EAX
	JMP  RETfromEBP

F9: ; !a-
	CALL RETtoEBP
	CALL F5 ; !a
	PUSH EAX
	MOV  EAX, [A]
	SUB  EAX, 4
	MOV  [A], EAX
	POP  EAX
	JMP  RETfromEBP

F10: ; c@a
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [A]
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	JMP  RETfromEBP

F11: ; c!a
	CALL RETtoEBP
	MOV  EBX, EAX
	MOV  EAX, [A]
	MOV  [EAX], BL
	POP  EAX
	JMP  RETfromEBP

F12: ; c@a+
	CALL RETtoEBP
	CALL F10 ; c@a
	INC  [A]
	JMP  RETfromEBP

F13: ; c!a+
	CALL RETtoEBP
	CALL F11 ; c!a
	INC  [A]
	JMP  RETfromEBP

F14: ; c@a-
	CALL RETtoEBP
	CALL F10 ; c@a
	DEC  [A]
	JMP  RETfromEBP

F15: ; c!a-
	CALL RETtoEBP
	CALL F11 ; c!a
	DEC  [A]
	JMP  RETfromEBP

F16: ; +L
	CALL RETtoEBP
	ADD  EDI, 24
	PUSH EAX
	MOV  EAX, [A]
	MOV  EBX, EAX
	LEA  EAX, [EDI+0]
	MOV  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F17: ; -L
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [EDI+0]
	MOV  EAX, [EAX]
	MOV  [A], EAX
	POP  EAX
	SUB  EDI, 24
	JMP  RETfromEBP

F18: ; 0=
	CALL RETtoEBP
	MOV  EBX, EAX
	MOV  EAX, 0
	CMP  EBX, EAX
	MOV  EAX, 0
	JNZ  @F
	DEC  EAX
@@:
	JMP  RETfromEBP

F19: ; ztype
	CALL RETtoEBP
	CALL F16 ; +L
	MOV  [A], EAX
	POP  EAX
Tgt20:
	CALL F12 ; c@a+
	PUSH EAX
	CALL F18 ; 0=
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt21
	POP  EAX
	CALL F17 ; -L
	JMP  RETfromEBP
Tgt21:
	CALL F2 ; emit
	JMP  Tgt20
	JMP  RETfromEBP

F22: ; Mil
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1000
	MOV  EBX, EAX
	IMUL EAX, EBX
	POP  EBX
	IMUL EAX, EBX
	JMP  RETfromEBP

F23: ; cr
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F2 ; emit
	JMP  RETfromEBP

F24: ; space
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 32
	CALL F2 ; emit
	JMP  RETfromEBP

F25: ; negate
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 0
	XCHG EAX, [ESP]
	MOV  EBX, EAX
	POP  EAX
	SUB  EAX, EBX
	JMP  RETfromEBP

F28: ; (.)
	CALL RETtoEBP
	CALL F16 ; +L
	PUSH EAX
	LEA  EAX, [I27] ; #n
	MOV  [A], EAX
	MOV  EAX, 0
	PUSH EAX
	CALL F15 ; c!a-
	CALL F15 ; c!a-
	PUSH EAX
	MOV  EBX, EAX
	MOV  EAX, 0
	CMP  EBX, EAX
	MOV  EAX, 0
	JGE  @F
	DEC  EAX
@@:
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt29
	PUSH EAX
	MOV  EAX, 1
	MOV  EBX, EAX
	LEA  EAX, [I27] ; #n
	MOV  [EAX], BL
	POP  EAX
	CALL F25 ; negate
Tgt29:
Tgt30:
	MOV  EBX, EAX
	MOV  EAX, [I3]
	XCHG EAX, EBX
	CDQ
	IDIV EBX
	PUSH EDX
	XCHG EAX, [ESP]
	ADD  EAX, 48
	PUSH EAX
	MOV  EBX, EAX
	MOV  EAX, 57
	CMP  EBX, EAX
	MOV  EAX, 0
	JLE  @F
	DEC  EAX
@@:
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt31
	ADD  EAX, 7
Tgt31:
	CALL F15 ; c!a-
	TEST EAX, EAX
	JNZ  Tgt30
	POP  EAX
	PUSH EAX
	LEA  EAX, [I27] ; #n
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt32
	PUSH EAX
	MOV  EAX, 45
	CALL F15 ; c!a-
Tgt32:
	PUSH EAX
	MOV  EAX, [A]
	INC  EAX
	CALL F19 ; ztype
	CALL F17 ; -L
	JMP  RETfromEBP

F33: ; .
	CALL RETtoEBP
	CALL F28 ; (.)
	CALL F24 ; space
	JMP  RETfromEBP

F34: ; strlen
	CALL RETtoEBP
	ADD  EDI, 24
	PUSH EAX
	MOV  EAX, [A]
	MOV  EBX, EAX
	LEA  EAX, [EDI+0]
	MOV  [EAX], EBX
	POP  EAX
	MOV  [A], EAX
	MOV  EAX, 0
Tgt35:
	INC  EAX
	PUSH EAX
	MOV  EAX, [A]
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	INC  [A]
	TEST EAX, EAX
	POP  EAX
	JNZ  Tgt35
	DEC  EAX
	PUSH EAX
	LEA  EAX, [EDI+0]
	MOV  EAX, [EAX]
	MOV  [A], EAX
	POP  EAX
	SUB  EDI, 24
	JMP  RETfromEBP

F37: ; x++
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [I36]
	INC  EAX
	MOV  [I36], EAX
	POP  EAX
	JMP  RETfromEBP

F38: ; x--
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [I36]
	DEC  EAX
	MOV  [I36], EAX
	POP  EAX
	JMP  RETfromEBP

F39: ; x+4
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [I36]
	ADD  EAX, 4
	MOV  [I36], EAX
	POP  EAX
	JMP  RETfromEBP

F40: ; x-4
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [I36]
	SUB  EAX, 4
	MOV  [I36], EAX
	POP  EAX
	JMP  RETfromEBP

F41: ; t0
	CALL RETtoEBP
	CALL F23 ; cr
	PUSH EAX
	MOV  EAX, 116
	CALL F2 ; emit
	CALL F33 ; .
	JMP  RETfromEBP

F42: ; t1
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1
	CALL F41 ; t0
	PUSH EAX
	LEA  EAX, [S43]
	CALL F19 ; ztype
	JMP  RETfromEBP

F44: ; t2
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 2
	CALL F41 ; t0
	PUSH EAX
	MOV  EAX, 1234
	PUSH EAX
	LEA  EAX, [S45]
	CALL F34 ; strlen
	CALL F33 ; .
	CALL F33 ; .
	JMP  RETfromEBP

F46: ; t4
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 4
	CALL F41 ; t0
	CALL F18 ; 0=
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt47
	PUSH EAX
	MOV  EAX, 110
	CALL F2 ; emit
	JMP  RETfromEBP
Tgt47:
	PUSH EAX
	MOV  EAX, 121
	CALL F2 ; emit
	JMP  RETfromEBP

F48: ; t5
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 5
	CALL F41 ; t0
	PUSH EAX
	LEA  EAX, [I26] ; buf
	MOV  [A], EAX
	MOV  EAX, 104
	CALL F13 ; c!a+
	PUSH EAX
	MOV  EAX, 105
	CALL F13 ; c!a+
	PUSH EAX
	MOV  EAX, 0
	CALL F11 ; c!a
	PUSH EAX
	LEA  EAX, [I26] ; buf
	CALL F19 ; ztype
	CALL F24 ; space
	JMP  RETfromEBP

F49: ; t6
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 6
	CALL F41 ; t0
	PUSH EAX
	MOV  EAX, 666
	PUSH EAX
	MOV  EAX, 222
	MOV  EBX, EAX
	MOV  EAX, 333
	MOV  ECX, EAX
	MOV  EAX, 444
	MOV  EDX, EAX
	POP  EAX
	CALL F33 ; .
	PUSH EAX
	LEA  EAX, [S50]
	CALL F19 ; ztype
	JMP  RETfromEBP

F51: ; t7
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 7
	CALL F41 ; t0
	PUSH EAX
	LEA  EAX, [S52]
	CALL F19 ; ztype
	JMP  RETfromEBP

F53: ; t8
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 8
	CALL F41 ; t0
	PUSH EAX
	MOV  EAX, 3344
	CALL F33 ; .
	PUSH EAX
	MOV  EAX, -3344
	CALL F33 ; .
	PUSH EAX
	MOV  EAX, 4660
	CALL F33 ; .
	PUSH EAX
	MOV  EAX, 1234
	PUSH EAX
	MOV  EAX, 16
	MOV  [I3], EAX
	POP  EAX
	CALL F33 ; .
	PUSH EAX
	MOV  EAX, 10
	MOV  [I3], EAX
	POP  EAX
	JMP  RETfromEBP

F54: ; t9
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 9
	CALL F41 ; t0
	PUSH EAX
	MOV  EAX, 999
	PUSH EAX
	MOV  EAX, 123
	MOV  EBX, EAX
	MOV  EAX, 100
	XCHG EAX, EBX
	CDQ
	IDIV EBX
	PUSH EDX
	CALL F33 ; .
	CALL F33 ; .
	CALL F33 ; .
	JMP  RETfromEBP

F55: ; t10
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F41 ; t0
	PUSH EAX
	MOV  EAX, 103
	MOV  EBX, EAX
	LEA  EAX, [I36] ; x
	MOV  [EAX], BL
	POP  EAX
	PUSH EAX
	LEA  EAX, [I36] ; x
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	PUSH EAX
	CALL F33 ; .
	CALL F2 ; emit
	JMP  RETfromEBP

F56: ; t11
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 11
	CALL F41 ; t0
	PUSH EAX
	MOV  EAX, 115
	CALL F2 ; emit
	PUSH EAX
	MOV  EAX, 999
	CALL F22 ; Mil
	PUSH EAX
	CALL F28 ; (.)
Tgt57:
	DEC  EAX
	JNZ  Tgt57
	PUSH EAX
	MOV  EAX, 101
	CALL F2 ; emit
	JMP  RETfromEBP

F58: ; t12
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 12
	CALL F41 ; t0
	ADD  EDI, 24
	PUSH EAX
	LEA  EAX, [S59]
	MOV  EBX, EAX
	LEA  EAX, [EDI+12]
	MOV  [EAX], EBX
	POP  EAX
	ADD  EDI, 24
	PUSH EAX
	MOV  EAX, 17
	MOV  EBX, EAX
	LEA  EAX, [EDI+12]
	MOV  [EAX], EBX
	POP  EAX
	PUSH EAX
	LEA  EAX, [EDI+12]
	MOV  EAX, [EAX]
	CALL F33 ; .
	SUB  EDI, 24
	PUSH EAX
	LEA  EAX, [EDI+12]
	MOV  EAX, [EAX]
	CALL F19 ; ztype
	SUB  EDI, 24
	JMP  RETfromEBP

F60: ; t999
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [S61]
	CALL F19 ; ztype
	CALL F23 ; cr
	CALL F1 ; bye
	JMP  RETfromEBP

F62: ; main
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	MOV  [I3], EAX
	POP  EAX
	CALL F42 ; t1
	CALL F44 ; t2
	PUSH EAX
	MOV  EAX, 0
	CALL F46 ; t4
	PUSH EAX
	MOV  EAX, 1
	CALL F46 ; t4
	CALL F48 ; t5
	CALL F49 ; t6
	CALL F51 ; t7
	CALL F53 ; t8
	CALL F54 ; t9
	CALL F55 ; t10
	CALL F56 ; t11
	CALL F58 ; t12
	CALL F23 ; cr
	CALL F60 ; t999
	CALL F23 ; cr
	PUSH EAX
	LEA  EAX, [S63]
	CALL F19 ; ztype
	JMP  RETfromEBP

;================== data =====================
section '.data' data readable writeable
;---------------------------------------------

; code: 10000 entries, 485 used
; heap: 5000 bytes, 76 used
; symbols: 1000 entries, 64 used
S43      db "hello world!", 0
S45      db "hello", 0
S50      db "(should print 666)", 0
S52      db "test ztype ...", 0
S59      db "-L3-", 0
S61      db "bye", 0
S63      db "still here? s", 0
I3       rd   1 ; base
I26      rd   3 ; buf
I27      rd   1 ; #n
I36      rd   1 ; x
I64      rd   1 ; pv
A        rd   1
rstk     rd 256
locs     rd 500

;=============================================
section '.idata' import data readable
;---------------------------------------------
library msvcrt, 'msvcrt.dll', kernel32, 'kernel32.dll'
import msvcrt, printf,'printf', getch,'_getch'
import kernel32, ExitProcess,'ExitProcess'

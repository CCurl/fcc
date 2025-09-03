format PE console
include 'win32ax.inc'

; ======================================= 
section '.code' code readable executable
;=======================================*/
start:
	CALL init
	CALL F13

;================== library ==================
F1:
	PUSH 0
	CALL [ExitProcess]

;=============================================
F2: ; puts
	CALL RETtoEBP
	MOV [I5], EAX
	cinvoke printf, "%s", [I5]
	POP EAX
	JMP RETfromEBP

F3: ; emit
	CALL RETtoEBP
	MOV [I5], EAX
	cinvoke printf, "%c", [I5]
	POP EAX
	JMP RETfromEBP

F4: ; .d
	CALL RETtoEBP
	MOV [I5], EAX
	cinvoke printf, "%d", [I5]
	POP EAX
	JMP RETfromEBP
init:
	LEA EBP, [rstk]
	RET

RETtoEBP:    ; Move the return addr to the [EBP] stack
	POP  EDX ; NB: EDX is destroyed
	ADD  EBP, 4
	POP  DWORD [EBP]
	PUSH EDX
	RET

RETfromEBP:  ; Perform a return from the [EBP] stack
	PUSH DWORD [EBP]
	SUB  EBP, 4
	RET

F8: ; T4
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [I7] ; x
	MOV  EAX, [EAX]
	PUSH EAX
	LEA  EAX, [I6] ; num
	MOV  EAX, [EAX]
	POP  EBX
	CMP  EBX, EAX
	MOV  EAX, 0
	JLE  @F
	DEC  EAX
@@:
	TEST EAX, EAX
	JZ   Tgt1
	PUSH EAX
	MOV  EAX, 4
	PUSH EAX
	LEA  EAX, [I7] ; x
	POP  EBX
	ADD  [EAX], EBX
	POP  EAX
Tgt1:
	POP  EAX
	JMP  RETfromEBP

F11: ; Mil
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1000
	POP  EBX
	IMUL EAX, EBX
	PUSH EAX
	MOV  EAX, 1000
	POP  EBX
	IMUL EAX, EBX
	JMP  RETfromEBP

F12: ; CR
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F3 ; emit
	JMP  RETfromEBP

F13: ; main
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1000
	CALL F11 ; Mil
	PUSH EAX
	LEA  EAX, [I10] ; x
	POP  ECX
	MOV  [EAX], ECX
	POP  EAX
	PUSH EAX
	LEA  EAX, [I10] ; x
	MOV  EAX, [EAX]
	CALL F4 ; .d
	PUSH EAX
	MOV  EAX, 115
	PUSH EAX
	MOV  EAX, 101
	XCHG EAX, [ESP]
	CALL F3 ; emit
	PUSH EAX
	LEA  EAX, [I10] ; x
	MOV  EAX, [EAX]
Tgt2:
	DEC  EAX
	TEST EAX, EAX
	JNZ  Tgt2
	POP  EAX
	CALL F3 ; emit
	CALL F12 ; CR
	PUSH EAX
	LEA  EAX, [S1]
	CALL F2 ; puts
	JMP  RETfromEBP

;================== data =====================
section '.data' data readable writeable
;=============================================

; symbols: 100 entries, 14 used
; num type size name
; --- ---- ---- -----------------
I5         dd 0 ; pv
I6         dd 0 ; num
I7         dd 0 ; x
I10        dd 0 ; x
S1         db "- all done!", 0
rstk       rd 256

;====================================
section '.idata' import data readable
; ====================================
library msvcrt, 'msvcrt.dll', kernel32, 'kernel32.dll'
import msvcrt, printf,'printf', getch,'_getch'
import kernel32, ExitProcess,'ExitProcess'

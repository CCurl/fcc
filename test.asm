
format ELF executable
;================== code =====================
segment readable executable
;================== library ==================
start:
	CALL init
	CALL F18 ; main

F1: ; bye
	MOV  EAX, 1
	XOR  EBX, EBX
	INT  0x80

F2: ; puts
	CALL RETtoEBP
	MOV  ECX, EAX
	MOV  EDX, EAX
.strlen:
	CMP  BYTE [EDX], 0
	JE   .done
	INC  EDX
	JMP  .strlen
.done:
	SUB  EDX, ECX
	MOV  EAX, 4
	MOV  EBX, 1
	INT  0x80
	POP  EAX
	JMP  RETfromEBP

F3: ; emit
	CALL RETtoEBP
	MOV  [I5], EAX
	MOV  EAX, 4
	MOV  EBX, 0
	LEA  ECX, [I5]
	MOV  EDX, 1
	INT  0x80
	POP  EAX
	JMP  RETfromEBP

F4: ; .d
	CALL RETtoEBP
	MOV  [I5], EAX
	MOV  ECX, intbuf+11
	MOV  EBX, [I5]
	CMP  EBX, 0
	JGE  .convert
	NEG  EBX
	MOV  AL, '-'
	DEC  ECX
	MOV  [ECX], AL
.convert:
	MOV  EAX, EBX
.repeat:
	MOV  EDX, 0
	MOV  EBX, 10
	DIV  EBX
	ADD  DL, '0'
	DEC  ECX
	MOV  [ECX], DL
	TEST EAX, EAX
	JNZ  .repeat
	MOV  EAX, 4
	MOV  EBX, 1
	MOV  EDX, intbuf+11
	SUB  EDX, ECX
	INT  0x80
	POP  EAX
	JMP  RETfromEBP
;=============================================
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
;=============================================

F8: ; 0=
	CALL RETtoEBP
	MOV  EBX, EAX
	MOV  EAX, 0
	CMP  EBX, EAX
	MOV  EAX, 0
	JNZ  @F
	DEC  EAX
@@:
	JMP  RETfromEBP

F9: ; T4
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [I7] ; x
	MOV  EAX, [EAX]
	CALL F8 ; 0=
	TEST EAX, EAX
	JZ   Tgt1
	MOV  EAX, 121
	CALL F3 ; emit
	JMP  RETfromEBP
Tgt1:
	MOV  EAX, 110
	CALL F3 ; emit
	JMP  RETfromEBP

F12: ; Mil
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1000
	MOV  EBX, EAX
	IMUL EAX, EBX
	POP  EBX
	IMUL EAX, EBX
	JMP  RETfromEBP

F13: ; CR
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F3 ; emit
	JMP  RETfromEBP

F14: ; SPACE
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 32
	CALL F3 ; emit
	JMP  RETfromEBP

F15: ; (.)
	CALL RETtoEBP
	PUSH EAX
	MOV  EBX, EAX
	MOV  EAX, 0
	CMP  EBX, EAX
	MOV  EAX, 0
	JGE  @F
	DEC  EAX
@@:
	TEST EAX, EAX
	JZ   Tgt2
	PUSH EAX
	MOV  EAX, 45
	CALL F3 ; emit
	PUSH EAX
	MOV  EAX, 0
	XCHG EAX, [ESP]
	POP  EBX
	XCHG EAX, EBX
	SUB  EAX, EBX
Tgt2:
	PUSH EAX
	MOV  EBX, EAX
	MOV  EAX, 9
	CMP  EBX, EAX
	MOV  EAX, 0
	JLE  @F
	DEC  EAX
@@:
	TEST EAX, EAX
	JZ   Tgt3
	MOV  EBX, EAX
	MOV  EAX, 10
	XCHG EAX, EBX
	CDQ
	IDIV EBX
	PUSH EDX
	XCHG EAX, [ESP]
	CALL F15 ; (.)
Tgt3:
	MOV  EBX, EAX
	MOV  EAX, 48
	ADD  EAX, EBX
	CALL F3 ; emit
	JMP  RETfromEBP

F18: ; main
	CALL RETtoEBP
	CALL F9 ; T4
	PUSH EAX
	MOV  EAX, 1000
	CALL F12 ; Mil
	MOV  EBX, EAX
	LEA  EAX, [I11] ; x
	MOV  [EAX], EBX
	MOV  EAX, 123
	MOV  EBX, EAX
	MOV  EAX, 100
	XCHG EAX, EBX
	CDQ
	IDIV EBX
	PUSH EDX
	CALL F4 ; .d
	PUSH EAX
	MOV  EAX, 32
	CALL F3 ; emit
	CALL F4 ; .d
	CALL F13 ; CR
	PUSH EAX
	LEA  EAX, [I11] ; x
	MOV  EAX, [EAX]
	CALL F4 ; .d
	CALL F14 ; SPACE
	PUSH EAX
	MOV  EAX, 115
	PUSH EAX
	MOV  EAX, 101
	XCHG EAX, [ESP]
	CALL F3 ; emit
	PUSH EAX
	LEA  EAX, [I11] ; x
	MOV  EAX, [EAX]
Tgt4:
	DEC  EAX
	JNZ  Tgt4
	POP  EAX
	CALL F3 ; emit
	CALL F13 ; CR
	PUSH EAX
	LEA  EAX, [S1]
	CALL F2 ; puts
	CALL F13 ; CR
	JMP  RETfromEBP
;================== data =====================
segment readable writeable
;=============================================
intbuf      rb 12 ; for .d

; symbols: 500 entries, 19 used
; num type size name
; --- ---- ---- -----------------
I5         dd 0 ; pv
I6         dd 0 ; num
I7         dd 0 ; x
I11        dd 0 ; x
S1         db "- all done!", 0
rstk       rd 256

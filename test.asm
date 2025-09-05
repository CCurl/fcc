
format ELF executable
;================== code =====================
segment readable executable
;================== library ==================
start:
	CALL init
	CALL F45 ; main

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
	MOV  [I5], 0
	MOV  ECX, intbuf+11
	CMP  EAX, 0
	JGE  .convert
	NEG  EAX
	INC  [I5]
.convert:
	MOV  EBX, 10
.repeat:
	MOV  EDX, 0
	DIV  EBX
	ADD  DL, '0'
	DEC  ECX
	MOV  [ECX], DL
	TEST EAX, EAX
	JNZ  .repeat
	MOV  EAX, [I5]
	TEST EAX, EAX
	JZ   .pr
	DEC  ECX
	MOV  BYTE [ECX], '-'
.pr:
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

F11: ; Mil
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1000
	MOV  EBX, EAX
	IMUL EAX, EBX
	POP  EBX
	IMUL EAX, EBX
	JMP  RETfromEBP

F12: ; cr
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F3 ; emit
	JMP  RETfromEBP

F13: ; space
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 32
	CALL F3 ; emit
	JMP  RETfromEBP

F14: ; negate
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 0
	XCHG EAX, [ESP]
	POP  EBX
	XCHG EAX, EBX
	SUB  EAX, EBX
	JMP  RETfromEBP

F16: ; a@
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [I15] ; (a)
	MOV  EAX, [EAX]
	JMP  RETfromEBP

F17: ; a!
	CALL RETtoEBP
	MOV  EBX, EAX
	LEA  EAX, [I15] ; (a)
	MOV  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F18: ; @a
	CALL RETtoEBP
	CALL F16 ; a@
	MOV  EAX, [EAX]
	JMP  RETfromEBP

F19: ; c@a
	CALL RETtoEBP
	CALL F16 ; a@
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	JMP  RETfromEBP

F20: ; c@a+
	CALL RETtoEBP
	CALL F19 ; c@a
	PUSH EAX
	MOV  EAX, 1
	MOV  EBX, EAX
	LEA  EAX, [I15] ; (a)
	ADD  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F21: ; !a
	CALL RETtoEBP
	CALL F16 ; a@
	POP  EBX
	MOV  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F22: ; c!a
	CALL RETtoEBP
	CALL F16 ; a@
	POP  EBX
	MOV  [EAX], BL
	POP  EAX
	JMP  RETfromEBP

F23: ; c!a+
	CALL RETtoEBP
	CALL F22 ; c!a
	PUSH EAX
	MOV  EAX, 1
	MOV  EBX, EAX
	LEA  EAX, [I15] ; (a)
	ADD  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F24: ; c!a-
	CALL RETtoEBP
	CALL F22 ; c!a
	CALL F16 ; a@
	DEC  EAX
	CALL F17 ; a!
	JMP  RETfromEBP

F30: ; #c
	CALL RETtoEBP
	CALL F24 ; c!a-
	JMP  RETfromEBP

F31: ; #d
	CALL RETtoEBP
	MOV  EBX, EAX
	MOV  EAX, 48
	ADD  EAX, EBX
	CALL F30 ; #c
	JMP  RETfromEBP

F32: ; #neg?
	CALL RETtoEBP
	PUSH EAX
	MOV  EBX, EAX
	MOV  EAX, 0
	CMP  EBX, EAX
	MOV  EAX, 0
	JGE  @F
	DEC  EAX
@@:
	PUSH EAX
	MOV  EBX, EAX
	LEA  EAX, [I28] ; #n
	MOV  [EAX], EBX
	POP  EAX
	TEST EAX, EAX
	JZ   Tgt2
	XCHG EAX, [ESP]
	CALL F14 ; negate
Tgt2:
	POP  EAX
	JMP  RETfromEBP

F34: ; #
	CALL RETtoEBP
	MOV  EBX, EAX
	MOV  EAX, 10
	XCHG EAX, EBX
	CDQ
	IDIV EBX
	PUSH EDX
	XCHG EAX, [ESP]
	CALL F31 ; #d
	JMP  RETfromEBP

F35: ; #s
	CALL RETtoEBP
	CALL F34 ; #
	CALL F34 ; #
	CALL F34 ; #
	CALL F34 ; #
	CALL F34 ; #
	JMP  RETfromEBP

F36: ; #>
	CALL RETtoEBP
	POP  EAX
	CALL F16 ; a@
	INC  EAX
	JMP  RETfromEBP

F37: ; <#
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [I28] ; #n
	DEC  EAX
	PUSH EAX
	MOV  EAX, 0
	CALL F30 ; #c
	JMP  RETfromEBP

F38: ; (.)
	CALL RETtoEBP
	CALL F37 ; <#
	CALL F35 ; #s
	CALL F36 ; #>
	CALL F2 ; puts
	JMP  RETfromEBP

F39: ; (.)
	CALL RETtoEBP
	CALL F4 ; .d
	JMP  RETfromEBP

F40: ; .
	CALL RETtoEBP
	CALL F39 ; (.)
	CALL F13 ; space
	JMP  RETfromEBP

F41: ; t5
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [I25] ; x1
	CALL F17 ; a!
	PUSH EAX
	MOV  EAX, 104
	CALL F23 ; c!a+
	PUSH EAX
	MOV  EAX, 105
	CALL F23 ; c!a+
	PUSH EAX
	MOV  EAX, 0
	CALL F22 ; c!a
	PUSH EAX
	LEA  EAX, [I25] ; x1
	CALL F2 ; puts
	CALL F13 ; space
	JMP  RETfromEBP

F42: ; t6
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [I28] ; #n
	DEC  EAX
	CALL F17 ; a!
	PUSH EAX
	MOV  EAX, 0
	CALL F30 ; #c
	PUSH EAX
	MOV  EAX, 105
	CALL F30 ; #c
	PUSH EAX
	MOV  EAX, 104
	CALL F30 ; #c
	CALL F16 ; a@
	INC  EAX
	CALL F2 ; puts
	CALL F12 ; cr
	JMP  RETfromEBP

F43: ; t7
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [S1]
	CALL F2 ; puts
	PUSH EAX
	MOV  EAX, 123
	CALL F32 ; #neg?
	CALL F40 ; .
	PUSH EAX
	LEA  EAX, [I28] ; #n
	MOV  EAX, [EAX]
	CALL F40 ; .
	JMP  RETfromEBP

F44: ; t8
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [S2]
	CALL F2 ; puts
	PUSH EAX
	MOV  EAX, -123
	CALL F32 ; #neg?
	CALL F40 ; .
	PUSH EAX
	LEA  EAX, [I28] ; #n
	MOV  EAX, [EAX]
	CALL F40 ; .
	CALL F12 ; cr
	JMP  RETfromEBP

F45: ; main
	CALL RETtoEBP
	CALL F9 ; T4
	CALL F41 ; t5
	CALL F42 ; t6
	CALL F43 ; t7
	CALL F44 ; t8
	PUSH EAX
	MOV  EAX, 103
	MOV  EBX, EAX
	LEA  EAX, [I7] ; x
	MOV  [EAX], BL
	LEA  EAX, [I7] ; x
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	PUSH EAX
	CALL F40 ; .
	CALL F3 ; emit
	CALL F12 ; cr
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
	CALL F40 ; .
	CALL F40 ; .
	CALL F40 ; .
	CALL F12 ; cr
	PUSH EAX
	MOV  EAX, 1000
	CALL F11 ; Mil
	MOV  EBX, EAX
	LEA  EAX, [I7] ; x
	MOV  [EAX], EBX
	LEA  EAX, [I7] ; x
	MOV  EAX, [EAX]
	CALL F40 ; .
	CALL F13 ; space
	PUSH EAX
	MOV  EAX, 115
	PUSH EAX
	MOV  EAX, 101
	XCHG EAX, [ESP]
	CALL F3 ; emit
	PUSH EAX
	LEA  EAX, [I7] ; x
	MOV  EAX, [EAX]
Tgt3:
	DEC  EAX
	JNZ  Tgt3
	POP  EAX
	CALL F3 ; emit
	CALL F12 ; cr
	PUSH EAX
	LEA  EAX, [S3]
	CALL F2 ; puts
	CALL F12 ; cr
	JMP  RETfromEBP
;================== data =====================
segment readable writeable
;=============================================
intbuf      rb 12 ; for .d

; symbols: 500 entries, 46 used
; num type size name
; --- ---- ---- -----------------
I5         dd 0 ; pv
I6         dd 0 ; num
I7         dd 0 ; x
I15        dd 0 ; (a)
I25        dd 0 ; x1
I26        dd 0 ; x2
I27        dd 0 ; x3
I28        dd 0 ; #n
I29        dd 0 ; n
S1         db "n1", 0
S2         db "n2", 0
S3         db "- all done!", 0
rstk       rd 256

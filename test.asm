
format ELF executable
;================== code =====================
segment readable executable
;================== library ==================
start:
	LEA EBP, [rstk]
	CALL F48 ; main
	MOV  EAX, 1
	XOR  EBX, EBX
	INT  0x80
;=============================================
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

F3: ; a@
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [I2] ; (a)
	MOV  EAX, [EAX]
	JMP  RETfromEBP

F4: ; a!
	CALL RETtoEBP
	MOV  EBX, EAX
	LEA  EAX, [I2] ; (a)
	MOV  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F5: ; @a
	CALL RETtoEBP
	CALL F3 ; a@
	MOV  EAX, [EAX]
	JMP  RETfromEBP

F6: ; c@a
	CALL RETtoEBP
	CALL F3 ; a@
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	JMP  RETfromEBP

F7: ; c@a+
	CALL RETtoEBP
	CALL F6 ; c@a
	PUSH EAX
	MOV  EAX, 1
	MOV  EBX, EAX
	LEA  EAX, [I2] ; (a)
	ADD  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F8: ; !a
	CALL RETtoEBP
	CALL F3 ; a@
	POP  EBX
	MOV  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F9: ; c!a
	CALL RETtoEBP
	CALL F3 ; a@
	POP  EBX
	MOV  [EAX], BL
	POP  EAX
	JMP  RETfromEBP

F10: ; c!a+
	CALL RETtoEBP
	CALL F9 ; c!a
	PUSH EAX
	MOV  EAX, 1
	MOV  EBX, EAX
	LEA  EAX, [I2] ; (a)
	ADD  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F11: ; c!a-
	CALL RETtoEBP
	CALL F9 ; c!a
	CALL F3 ; a@
	DEC  EAX
	CALL F4 ; a!
	JMP  RETfromEBP

F13: ; emit
	CALL RETtoEBP
	MOV  EBX, EAX
	LEA  EAX, [I12] ; _em
	MOV  [EAX], BL
	MOV  EAX, 0
	MOV  EBX, EAX
	LEA  EAX, [I12] ; _em
	MOV  ECX, EAX
	MOV  EAX, 1
	MOV  EDX, EAX
	MOV  EAX, 4
	INT  0x80
	POP  EAX
	JMP  RETfromEBP

F14: ; bye
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 0
	MOV  EBX, EAX
	MOV  EAX, 1
	INT  0x80
	POP  EAX
	JMP  RETfromEBP

F16: ; ztype
	CALL RETtoEBP
	CALL F3 ; a@
	MOV  EBX, EAX
	LEA  EAX, [I15] ; _zt
	MOV  [EAX], EBX
	POP  EAX
	CALL F4 ; a!
Tgt1:
	CALL F7 ; c@a+
	PUSH EAX
	MOV  EBX, EAX
	MOV  EAX, 0
	CMP  EBX, EAX
	MOV  EAX, 0
	JNZ  @F
	DEC  EAX
@@:
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt2
	LEA  EAX, [I15] ; _zt
	MOV  EAX, [EAX]
	CALL F4 ; a!
	JMP  RETfromEBP
Tgt2:
	CALL F13 ; emit
	JMP  Tgt1
	JMP  RETfromEBP

F19: ; 0=
	CALL RETtoEBP
	MOV  EBX, EAX
	MOV  EAX, 0
	CMP  EBX, EAX
	MOV  EAX, 0
	JNZ  @F
	DEC  EAX
@@:
	JMP  RETfromEBP

F20: ; Mil
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1000
	MOV  EBX, EAX
	IMUL EAX, EBX
	POP  EBX
	IMUL EAX, EBX
	JMP  RETfromEBP

F21: ; cr
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F13 ; emit
	JMP  RETfromEBP

F22: ; space
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 32
	CALL F13 ; emit
	JMP  RETfromEBP

F23: ; negate
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 0
	XCHG EAX, [ESP]
	POP  EBX
	XCHG EAX, EBX
	SUB  EAX, EBX
	JMP  RETfromEBP

F29: ; (.)
	CALL RETtoEBP
	CALL F3 ; a@
	MOV  EBX, EAX
	LEA  EAX, [I28] ; _dot
	MOV  [EAX], EBX
	LEA  EAX, [I27] ; #n
	CALL F4 ; a!
	PUSH EAX
	MOV  EAX, 0
	PUSH EAX
	CALL F11 ; c!a-
	CALL F11 ; c!a-
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
	JZ   Tgt3
	PUSH EAX
	MOV  EAX, 1
	MOV  EBX, EAX
	LEA  EAX, [I27] ; #n
	MOV  [EAX], BL
	POP  EAX
	CALL F23 ; negate
Tgt3:
Tgt4:
	PUSH EAX
	LEA  EAX, [I1] ; base
	MOV  EAX, [EAX]
	POP  EBX
	XCHG EAX, EBX
	CDQ
	IDIV EBX
	PUSH EDX
	XCHG EAX, [ESP]
	MOV  EBX, EAX
	MOV  EAX, 48
	ADD  EAX, EBX
	CALL F11 ; c!a-
	TEST EAX, EAX
	JNZ  Tgt4
	LEA  EAX, [I27] ; #n
	MOV  EAX, [EAX]
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt5
	PUSH EAX
	MOV  EAX, 45
	CALL F11 ; c!a-
Tgt5:
	CALL F3 ; a@
	INC  EAX
	CALL F16 ; ztype
	PUSH EAX
	LEA  EAX, [I28] ; _dot
	MOV  EAX, [EAX]
	CALL F4 ; a!
	JMP  RETfromEBP

F33: ; .
	CALL RETtoEBP
	CALL F29 ; (.)
	CALL F22 ; space
	JMP  RETfromEBP

F35: ; t0
	CALL RETtoEBP
	CALL F21 ; cr
	PUSH EAX
	MOV  EAX, 116
	CALL F13 ; emit
	CALL F33 ; .
	JMP  RETfromEBP

F36: ; t1
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [S1]
	CALL F16 ; ztype
	JMP  RETfromEBP

F37: ; t4
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 4
	CALL F35 ; t0
	PUSH EAX
	CALL F19 ; 0=
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt6
	PUSH EAX
	MOV  EAX, 121
	CALL F13 ; emit
	JMP  RETfromEBP
Tgt6:
	PUSH EAX
	MOV  EAX, 110
	CALL F13 ; emit
	JMP  RETfromEBP

F39: ; t5
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 5
	CALL F35 ; t0
	PUSH EAX
	LEA  EAX, [I24] ; buf
	CALL F4 ; a!
	PUSH EAX
	MOV  EAX, 104
	CALL F10 ; c!a+
	PUSH EAX
	MOV  EAX, 105
	CALL F10 ; c!a+
	PUSH EAX
	MOV  EAX, 0
	CALL F9 ; c!a
	PUSH EAX
	LEA  EAX, [I24] ; buf
	CALL F16 ; ztype
	CALL F22 ; space
	JMP  RETfromEBP

F40: ; t6
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 6
	CALL F35 ; t0
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
	JMP  RETfromEBP

F41: ; t7
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 7
	CALL F35 ; t0
	PUSH EAX
	LEA  EAX, [S2]
	CALL F16 ; ztype
	JMP  RETfromEBP

F42: ; t8
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 8
	CALL F35 ; t0
	PUSH EAX
	MOV  EAX, 3344
	CALL F33 ; .
	PUSH EAX
	MOV  EAX, -3344
	CALL F33 ; .
	JMP  RETfromEBP

F43: ; t9
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 9
	CALL F35 ; t0
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

F44: ; t10
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F35 ; t0
	PUSH EAX
	MOV  EAX, 103
	MOV  EBX, EAX
	LEA  EAX, [I34] ; x
	MOV  [EAX], BL
	LEA  EAX, [I34] ; x
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	PUSH EAX
	CALL F33 ; .
	CALL F13 ; emit
	JMP  RETfromEBP

F45: ; t11
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 11
	CALL F35 ; t0
	PUSH EAX
	MOV  EAX, 115
	CALL F13 ; emit
	PUSH EAX
	MOV  EAX, 1000
	CALL F20 ; Mil
	PUSH EAX
	CALL F29 ; (.)
Tgt7:
	DEC  EAX
	JNZ  Tgt7
	MOV  EAX, 101
	CALL F13 ; emit
	JMP  RETfromEBP

F47: ; t999
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [S3]
	CALL F16 ; ztype
	CALL F21 ; cr
	CALL F14 ; bye
	JMP  RETfromEBP

F48: ; main
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	MOV  EBX, EAX
	LEA  EAX, [I1] ; base
	MOV  [EAX], EBX
	POP  EAX
	CALL F36 ; t1
	PUSH EAX
	MOV  EAX, 0
	CALL F37 ; t4
	PUSH EAX
	MOV  EAX, 1
	CALL F37 ; t4
	CALL F39 ; t5
	CALL F40 ; t6
	CALL F41 ; t7
	CALL F42 ; t8
	CALL F43 ; t9
	CALL F44 ; t10
	CALL F45 ; t11
	CALL F47 ; t999
	PUSH EAX
	LEA  EAX, [S4]
	CALL F16 ; ztype
	JMP  RETfromEBP
;================== data =====================
segment readable writeable
;=============================================
intbuf      rb 12 ; for .d

; symbols: 500 entries, 48 used
; num type size name
; --- ---- ---- -----------------
I1         dd 0 ; base
I2         dd 0 ; (a)
I12        dd 0 ; _em
I15        dd 0 ; _zt
I24        dd 0 ; buf
I25        dd 0 ; _b
I26        dd 0 ; _b
I27        dd 0 ; #n
I28        dd 0 ; _dot
I34        dd 0 ; x
S1         db "hello", 0
S2         db "test ztype ...", 0
S3         db " bye", 0
S4         db "still here? ", 0
rstk       rd 256

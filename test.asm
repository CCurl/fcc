
format ELF executable
;================== code =====================
segment readable executable
;================== library ==================
start:
	LEA EBP, [rstk]
	CALL F47 ; main
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

F5: ; c@a
	CALL RETtoEBP
	CALL F3 ; a@
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	JMP  RETfromEBP

F6: ; c!a
	CALL RETtoEBP
	CALL F3 ; a@
	POP  EBX
	MOV  [EAX], BL
	POP  EAX
	JMP  RETfromEBP

F7: ; c@a+
	CALL RETtoEBP
	CALL F5 ; c@a
	CALL F3 ; a@
	INC  EAX
	CALL F4 ; a!
	JMP  RETfromEBP

F8: ; c!a+
	CALL RETtoEBP
	CALL F6 ; c!a
	CALL F3 ; a@
	INC  EAX
	CALL F4 ; a!
	JMP  RETfromEBP

F9: ; c@a-
	CALL RETtoEBP
	CALL F5 ; c@a
	CALL F3 ; a@
	DEC  EAX
	CALL F4 ; a!
	JMP  RETfromEBP

F10: ; c!a-
	CALL RETtoEBP
	CALL F6 ; c!a
	CALL F3 ; a@
	DEC  EAX
	CALL F4 ; a!
	JMP  RETfromEBP

F12: ; emit
	CALL RETtoEBP
	MOV  EBX, EAX
	LEA  EAX, [I11] ; _em
	MOV  [EAX], BL
	MOV  EAX, 0
	MOV  EBX, EAX
	LEA  EAX, [I11] ; _em
	MOV  ECX, EAX
	MOV  EAX, 1
	MOV  EDX, EAX
	MOV  EAX, 4
	INT  0x80
	POP  EAX
	JMP  RETfromEBP

F13: ; bye
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 0
	MOV  EBX, EAX
	MOV  EAX, 1
	INT  0x80
	POP  EAX
	JMP  RETfromEBP

F15: ; ztype
	CALL RETtoEBP
	CALL F3 ; a@
	MOV  EBX, EAX
	LEA  EAX, [I14] ; _zt
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
	LEA  EAX, [I14] ; _zt
	MOV  EAX, [EAX]
	CALL F4 ; a!
	JMP  RETfromEBP
Tgt2:
	CALL F12 ; emit
	JMP  Tgt1
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

F19: ; Mil
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1000
	MOV  EBX, EAX
	IMUL EAX, EBX
	POP  EBX
	IMUL EAX, EBX
	JMP  RETfromEBP

F20: ; cr
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F12 ; emit
	JMP  RETfromEBP

F21: ; space
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 32
	CALL F12 ; emit
	JMP  RETfromEBP

F22: ; negate
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 0
	XCHG EAX, [ESP]
	POP  EBX
	XCHG EAX, EBX
	SUB  EAX, EBX
	JMP  RETfromEBP

F28: ; (.)
	CALL RETtoEBP
	CALL F3 ; a@
	MOV  EBX, EAX
	LEA  EAX, [I27] ; _dot
	MOV  [EAX], EBX
	LEA  EAX, [I26] ; #n
	CALL F4 ; a!
	PUSH EAX
	MOV  EAX, 0
	PUSH EAX
	CALL F10 ; c!a-
	CALL F10 ; c!a-
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
	LEA  EAX, [I26] ; #n
	MOV  [EAX], BL
	POP  EAX
	CALL F22 ; negate
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
	CALL F10 ; c!a-
	TEST EAX, EAX
	JNZ  Tgt4
	LEA  EAX, [I26] ; #n
	MOV  EAX, [EAX]
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt5
	PUSH EAX
	MOV  EAX, 45
	CALL F10 ; c!a-
Tgt5:
	CALL F3 ; a@
	INC  EAX
	CALL F15 ; ztype
	PUSH EAX
	LEA  EAX, [I27] ; _dot
	MOV  EAX, [EAX]
	CALL F4 ; a!
	JMP  RETfromEBP

F32: ; .
	CALL RETtoEBP
	CALL F28 ; (.)
	CALL F21 ; space
	JMP  RETfromEBP

F34: ; t0
	CALL RETtoEBP
	CALL F20 ; cr
	PUSH EAX
	MOV  EAX, 116
	CALL F12 ; emit
	CALL F32 ; .
	JMP  RETfromEBP

F35: ; t1
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [S1]
	CALL F15 ; ztype
	JMP  RETfromEBP

F36: ; t4
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 4
	CALL F34 ; t0
	PUSH EAX
	CALL F18 ; 0=
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt6
	PUSH EAX
	MOV  EAX, 121
	CALL F12 ; emit
	JMP  RETfromEBP
Tgt6:
	PUSH EAX
	MOV  EAX, 110
	CALL F12 ; emit
	JMP  RETfromEBP

F38: ; t5
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 5
	CALL F34 ; t0
	PUSH EAX
	LEA  EAX, [I23] ; buf
	CALL F4 ; a!
	PUSH EAX
	MOV  EAX, 104
	CALL F8 ; c!a+
	PUSH EAX
	MOV  EAX, 105
	CALL F8 ; c!a+
	PUSH EAX
	MOV  EAX, 0
	CALL F6 ; c!a
	PUSH EAX
	LEA  EAX, [I23] ; buf
	CALL F15 ; ztype
	CALL F21 ; space
	JMP  RETfromEBP

F39: ; t6
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 6
	CALL F34 ; t0
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
	CALL F32 ; .
	JMP  RETfromEBP

F40: ; t7
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 7
	CALL F34 ; t0
	PUSH EAX
	LEA  EAX, [S2]
	CALL F15 ; ztype
	JMP  RETfromEBP

F41: ; t8
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 8
	CALL F34 ; t0
	PUSH EAX
	MOV  EAX, 3344
	CALL F32 ; .
	PUSH EAX
	MOV  EAX, -3344
	CALL F32 ; .
	JMP  RETfromEBP

F42: ; t9
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 9
	CALL F34 ; t0
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
	CALL F32 ; .
	CALL F32 ; .
	CALL F32 ; .
	JMP  RETfromEBP

F43: ; t10
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F34 ; t0
	PUSH EAX
	MOV  EAX, 103
	MOV  EBX, EAX
	LEA  EAX, [I33] ; x
	MOV  [EAX], BL
	LEA  EAX, [I33] ; x
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	PUSH EAX
	CALL F32 ; .
	CALL F12 ; emit
	JMP  RETfromEBP

F44: ; t11
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 11
	CALL F34 ; t0
	PUSH EAX
	MOV  EAX, 115
	CALL F12 ; emit
	PUSH EAX
	MOV  EAX, 1000
	CALL F19 ; Mil
	PUSH EAX
	CALL F28 ; (.)
Tgt7:
	DEC  EAX
	JNZ  Tgt7
	MOV  EAX, 101
	CALL F12 ; emit
	JMP  RETfromEBP

F46: ; t999
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [S3]
	CALL F15 ; ztype
	CALL F20 ; cr
	CALL F13 ; bye
	JMP  RETfromEBP

F47: ; main
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	MOV  EBX, EAX
	LEA  EAX, [I1] ; base
	MOV  [EAX], EBX
	POP  EAX
	CALL F35 ; t1
	PUSH EAX
	MOV  EAX, 0
	CALL F36 ; t4
	PUSH EAX
	MOV  EAX, 1
	CALL F36 ; t4
	CALL F38 ; t5
	CALL F39 ; t6
	CALL F40 ; t7
	CALL F41 ; t8
	CALL F42 ; t9
	CALL F43 ; t10
	CALL F44 ; t11
	CALL F46 ; t999
	PUSH EAX
	LEA  EAX, [S4]
	CALL F15 ; ztype
	JMP  RETfromEBP
;================== data =====================
segment readable writeable
;=============================================
intbuf      rb 12 ; for .d

; symbols: 500 entries, 47 used
; num type size name
; --- ---- ---- -----------------
I1         dd 0 ; base
I2         dd 0 ; (a)
I11        dd 0 ; _em
I14        dd 0 ; _zt
I23        dd 0 ; buf
I24        dd 0 ; _b
I25        dd 0 ; _b
I26        dd 0 ; #n
I27        dd 0 ; _dot
I33        dd 0 ; x
S1         db "hello", 0
S2         db "test ztype ...", 0
S3         db " bye", 0
S4         db "still here? ", 0
rstk       rd 256

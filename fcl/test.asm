format ELF executable
;================== code =====================
segment readable executable
;================== library ==================
start:
	LEA EBP, [rstk]
	LEA EDI, [locs]
	CALL F57 ; main
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

F4: ; a@
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [I3] ; (a)
	MOV  EAX, [EAX]
	JMP  RETfromEBP

F5: ; a!
	CALL RETtoEBP
	MOV  EBX, EAX
	LEA  EAX, [I3] ; (a)
	MOV  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F6: ; @a
	CALL RETtoEBP
	CALL F4 ; a@
	MOV  EAX, [EAX]
	JMP  RETfromEBP

F7: ; !a
	CALL RETtoEBP
	CALL F4 ; a@
	POP  EBX
	MOV  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F8: ; @a+
	CALL RETtoEBP
	CALL F6 ; @a
	CALL F4 ; a@
	MOV  EBX, EAX
	MOV  EAX, 4
	ADD  EAX, EBX
	CALL F5 ; a!
	JMP  RETfromEBP

F9: ; !a+
	CALL RETtoEBP
	CALL F7 ; !a
	CALL F4 ; a@
	MOV  EBX, EAX
	MOV  EAX, 4
	ADD  EAX, EBX
	CALL F5 ; a!
	JMP  RETfromEBP

F10: ; @a-
	CALL RETtoEBP
	CALL F6 ; @a
	CALL F4 ; a@
	MOV  EBX, EAX
	MOV  EAX, 4
	XCHG EAX, EBX
	SUB  EAX, EBX
	CALL F5 ; a!
	JMP  RETfromEBP

F11: ; !a-
	CALL RETtoEBP
	CALL F7 ; !a
	CALL F4 ; a@
	MOV  EBX, EAX
	MOV  EAX, 4
	XCHG EAX, EBX
	SUB  EAX, EBX
	CALL F5 ; a!
	JMP  RETfromEBP

F12: ; c@a
	CALL RETtoEBP
	CALL F4 ; a@
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	JMP  RETfromEBP

F13: ; c!a
	CALL RETtoEBP
	CALL F4 ; a@
	POP  EBX
	MOV  [EAX], BL
	POP  EAX
	JMP  RETfromEBP

F14: ; c@a+
	CALL RETtoEBP
	CALL F12 ; c@a
	CALL F4 ; a@
	INC  EAX
	CALL F5 ; a!
	JMP  RETfromEBP

F15: ; c!a+
	CALL RETtoEBP
	CALL F13 ; c!a
	CALL F4 ; a@
	INC  EAX
	CALL F5 ; a!
	JMP  RETfromEBP

F16: ; c@a-
	CALL RETtoEBP
	CALL F12 ; c@a
	CALL F4 ; a@
	DEC  EAX
	CALL F5 ; a!
	JMP  RETfromEBP

F17: ; c!a-
	CALL RETtoEBP
	CALL F13 ; c!a
	CALL F4 ; a@
	DEC  EAX
	CALL F5 ; a!
	JMP  RETfromEBP

F19: ; emit
	CALL RETtoEBP
	MOV  EBX, EAX
	LEA  EAX, [I18] ; _em
	MOV  [EAX], BL
	LEA  EAX, [I18] ; _em
	MOV  ECX, EAX
	MOV  EAX, 0
	MOV  EBX, EAX
	MOV  EAX, 1
	MOV  EDX, EAX
	MOV  EAX, 4
	INT  0x80
	POP  EAX
	JMP  RETfromEBP

F20: ; bye
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 0
	MOV  EBX, EAX
	MOV  EAX, 1
	INT  0x80
	POP  EAX
	JMP  RETfromEBP

F22: ; ztype
	CALL RETtoEBP
	CALL F4 ; a@
	MOV  EBX, EAX
	LEA  EAX, [I21] ; _zt
	MOV  [EAX], EBX
	POP  EAX
	CALL F5 ; a!
Tgt1:
	CALL F14 ; c@a+
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
	LEA  EAX, [I21] ; _zt
	MOV  EAX, [EAX]
	CALL F5 ; a!
	JMP  RETfromEBP
Tgt2:
	CALL F19 ; emit
	JMP  Tgt1
	JMP  RETfromEBP

F25: ; 0=
	CALL RETtoEBP
	MOV  EBX, EAX
	MOV  EAX, 0
	CMP  EBX, EAX
	MOV  EAX, 0
	JNZ  @F
	DEC  EAX
@@:
	JMP  RETfromEBP

F26: ; Mil
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1000
	MOV  EBX, EAX
	IMUL EAX, EBX
	POP  EBX
	IMUL EAX, EBX
	JMP  RETfromEBP

F27: ; cr
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F19 ; emit
	JMP  RETfromEBP

F28: ; space
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 32
	CALL F19 ; emit
	JMP  RETfromEBP

F29: ; negate
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 0
	XCHG EAX, [ESP]
	POP  EBX
	XCHG EAX, EBX
	SUB  EAX, EBX
	JMP  RETfromEBP

F30: ; strlen
	CALL RETtoEBP
	PUSH EAX
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	CALL F25 ; 0=
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt3
	MOV  EAX, 0
	JMP  RETfromEBP
Tgt3:
	ADD  EDI, 20
	CALL F4 ; a@
	MOV  EBX, EAX
	LEA  EAX, [EDI+8]
	MOV  [EAX], EBX
	CALL F5 ; a!
	MOV  EBX, EAX
	LEA  EAX, [EDI+0]
	MOV  [EAX], EBX
	POP  EAX
Tgt4:
	CALL F14 ; c@a+
	TEST EAX, EAX
	POP  EAX
	JNZ  Tgt4
	CALL F4 ; a@
	MOV  EBX, EAX
	LEA  EAX, [EDI+0]
	XCHG EAX, EBX
	SUB  EAX, EBX
	INC  EAX
	PUSH EAX
	LEA  EAX, [EDI+8]
	MOV  EAX, [EAX]
	CALL F5 ; a!
	SUB  EDI, 20
	JMP  RETfromEBP

F36: ; (.)
	CALL RETtoEBP
	CALL F4 ; a@
	MOV  EBX, EAX
	LEA  EAX, [I35] ; _dot
	MOV  [EAX], EBX
	LEA  EAX, [I34] ; #n
	CALL F5 ; a!
	PUSH EAX
	MOV  EAX, 0
	PUSH EAX
	CALL F17 ; c!a-
	CALL F17 ; c!a-
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
	JZ   Tgt5
	PUSH EAX
	MOV  EAX, 1
	MOV  EBX, EAX
	LEA  EAX, [I34] ; #n
	MOV  [EAX], BL
	POP  EAX
	CALL F29 ; negate
Tgt5:
Tgt6:
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
	CALL F17 ; c!a-
	PUSH EAX
	TEST EAX, EAX
	POP  EAX
	JNZ  Tgt6
	LEA  EAX, [I34] ; #n
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt7
	PUSH EAX
	MOV  EAX, 45
	CALL F17 ; c!a-
Tgt7:
	CALL F4 ; a@
	INC  EAX
	CALL F22 ; ztype
	PUSH EAX
	LEA  EAX, [I35] ; _dot
	MOV  EAX, [EAX]
	CALL F5 ; a!
	JMP  RETfromEBP

F40: ; .
	CALL RETtoEBP
	CALL F36 ; (.)
	CALL F28 ; space
	JMP  RETfromEBP

F42: ; t0
	CALL RETtoEBP
	CALL F27 ; cr
	PUSH EAX
	MOV  EAX, 116
	CALL F19 ; emit
	CALL F40 ; .
	JMP  RETfromEBP

F43: ; t1
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1
	CALL F42 ; t0
	PUSH EAX
	LEA  EAX, [S1]
	CALL F22 ; ztype
	JMP  RETfromEBP

F44: ; t2
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 2
	CALL F42 ; t0
	PUSH EAX
	MOV  EAX, 1234
	PUSH EAX
	LEA  EAX, [S2]
	CALL F30 ; strlen
	CALL F40 ; .
	CALL F40 ; .
	JMP  RETfromEBP

F45: ; t4
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 4
	CALL F42 ; t0
	PUSH EAX
	CALL F25 ; 0=
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt8
	PUSH EAX
	MOV  EAX, 110
	CALL F19 ; emit
	JMP  RETfromEBP
Tgt8:
	PUSH EAX
	MOV  EAX, 121
	CALL F19 ; emit
	JMP  RETfromEBP

F47: ; t5
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 5
	CALL F42 ; t0
	PUSH EAX
	LEA  EAX, [I33] ; buf
	CALL F5 ; a!
	PUSH EAX
	MOV  EAX, 104
	CALL F15 ; c!a+
	PUSH EAX
	MOV  EAX, 105
	CALL F15 ; c!a+
	PUSH EAX
	MOV  EAX, 0
	CALL F13 ; c!a
	PUSH EAX
	LEA  EAX, [I33] ; buf
	CALL F22 ; ztype
	CALL F28 ; space
	JMP  RETfromEBP

F48: ; t6
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 6
	CALL F42 ; t0
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
	CALL F40 ; .
	PUSH EAX
	LEA  EAX, [S3]
	CALL F22 ; ztype
	JMP  RETfromEBP

F49: ; t7
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 7
	CALL F42 ; t0
	PUSH EAX
	LEA  EAX, [S4]
	CALL F22 ; ztype
	JMP  RETfromEBP

F50: ; t8
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 8
	CALL F42 ; t0
	PUSH EAX
	MOV  EAX, 3344
	CALL F40 ; .
	PUSH EAX
	MOV  EAX, -3344
	CALL F40 ; .
	JMP  RETfromEBP

F51: ; t9
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 9
	CALL F42 ; t0
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
	JMP  RETfromEBP

F52: ; t10
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F42 ; t0
	PUSH EAX
	MOV  EAX, 103
	MOV  EBX, EAX
	LEA  EAX, [I41] ; x
	MOV  [EAX], BL
	LEA  EAX, [I41] ; x
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	PUSH EAX
	CALL F40 ; .
	CALL F19 ; emit
	JMP  RETfromEBP

F53: ; t11
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 11
	CALL F42 ; t0
	PUSH EAX
	MOV  EAX, 115
	CALL F19 ; emit
	PUSH EAX
	MOV  EAX, 1000
	CALL F26 ; Mil
	PUSH EAX
	CALL F36 ; (.)
Tgt9:
	DEC  EAX
	PUSH EAX
	TEST EAX, EAX
	POP  EAX
	JNZ  Tgt9
	PUSH EAX
	MOV  EAX, 101
	CALL F19 ; emit
	JMP  RETfromEBP

F55: ; t12
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 12
	CALL F42 ; t0
	ADD  EDI, 20
	PUSH EAX
	LEA  EAX, [S5]
	MOV  EBX, EAX
	LEA  EAX, [EDI+8]
	MOV  [EAX], EBX
	POP  EAX
	ADD  EDI, 20
	PUSH EAX
	MOV  EAX, 17
	MOV  EBX, EAX
	LEA  EAX, [EDI+8]
	MOV  [EAX], EBX
	LEA  EAX, [EDI+8]
	MOV  EAX, [EAX]
	CALL F40 ; .
	SUB  EDI, 20
	PUSH EAX
	LEA  EAX, [EDI+8]
	MOV  EAX, [EAX]
	CALL F22 ; ztype
	SUB  EDI, 20
	JMP  RETfromEBP

F56: ; t999
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [S6]
	CALL F22 ; ztype
	CALL F27 ; cr
	CALL F20 ; bye
	JMP  RETfromEBP

F57: ; main
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	MOV  EBX, EAX
	LEA  EAX, [I1] ; base
	MOV  [EAX], EBX
	POP  EAX
	CALL F43 ; t1
	CALL F44 ; t2
	PUSH EAX
	MOV  EAX, 0
	CALL F45 ; t4
	PUSH EAX
	MOV  EAX, 1
	CALL F45 ; t4
	CALL F47 ; t5
	CALL F48 ; t6
	CALL F49 ; t7
	CALL F50 ; t8
	CALL F51 ; t9
	CALL F52 ; t10
	CALL F53 ; t11
	CALL F55 ; t12
	CALL F27 ; cr
	CALL F56 ; t999
	CALL F27 ; cr
	PUSH EAX
	LEA  EAX, [S7]
	CALL F22 ; ztype
	JMP  RETfromEBP
;================== data =====================
segment readable writeable
;=============================================
intbuf      rb 12 ; for .d

; code: 5000 entries, 532 used
; heap: 5000 bytes, 68 used
; symbols: 500 entries, 57 used; num type size name
; --- ---- ---- -----------------
I1         dd 1 dup(0) ; base
I2         dd 50 dup(0) ; stk
I3         dd 1 dup(0) ; (a)
I18        dd 1 dup(0) ; _em
I21        dd 1 dup(0) ; _zt
I33        dd 3 dup(0) ; buf
I34        dd 1 dup(0) ; #n
I35        dd 1 dup(0) ; _dot
I41        dd 1 dup(0) ; x
S1         db "hello", 0
S2         db "hello", 0
S3         db "(should print 666)", 0
S4         db "test ztype ...", 0
S5         db "-l3-", 0
S6         db "bye", 0
S7         db "still here? ", 0
locs       rd 500
rstk       rd 256

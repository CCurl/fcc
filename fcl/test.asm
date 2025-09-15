
format ELF executable
;================== code =====================
segment readable executable
;================== library ==================
start:
	LEA EBP, [rstk]
	LEA EDI, [locs]
	CALL F54 ; main
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

F6: ; !a
	CALL RETtoEBP
	CALL F3 ; a@
	POP  EBX
	MOV  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F7: ; @a+
	CALL RETtoEBP
	CALL F5 ; @a
	CALL F3 ; a@
	MOV  EBX, EAX
	MOV  EAX, 4
	ADD  EAX, EBX
	CALL F4 ; a!
	JMP  RETfromEBP

F8: ; !a+
	CALL RETtoEBP
	CALL F6 ; !a
	CALL F3 ; a@
	MOV  EBX, EAX
	MOV  EAX, 4
	ADD  EAX, EBX
	CALL F4 ; a!
	JMP  RETfromEBP

F9: ; @a-
	CALL RETtoEBP
	CALL F5 ; @a
	CALL F3 ; a@
	MOV  EBX, EAX
	MOV  EAX, 4
	XCHG EAX, EBX
	SUB  EAX, EBX
	CALL F4 ; a!
	JMP  RETfromEBP

F10: ; !a-
	CALL RETtoEBP
	CALL F6 ; !a
	CALL F3 ; a@
	MOV  EBX, EAX
	MOV  EAX, 4
	XCHG EAX, EBX
	SUB  EAX, EBX
	CALL F4 ; a!
	JMP  RETfromEBP

F11: ; c@a
	CALL RETtoEBP
	CALL F3 ; a@
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	JMP  RETfromEBP

F12: ; c!a
	CALL RETtoEBP
	CALL F3 ; a@
	POP  EBX
	MOV  [EAX], BL
	POP  EAX
	JMP  RETfromEBP

F13: ; c@a+
	CALL RETtoEBP
	CALL F11 ; c@a
	CALL F3 ; a@
	INC  EAX
	CALL F4 ; a!
	JMP  RETfromEBP

F14: ; c!a+
	CALL RETtoEBP
	CALL F12 ; c!a
	CALL F3 ; a@
	INC  EAX
	CALL F4 ; a!
	JMP  RETfromEBP

F15: ; c@a-
	CALL RETtoEBP
	CALL F11 ; c@a
	CALL F3 ; a@
	DEC  EAX
	CALL F4 ; a!
	JMP  RETfromEBP

F16: ; c!a-
	CALL RETtoEBP
	CALL F12 ; c!a
	CALL F3 ; a@
	DEC  EAX
	CALL F4 ; a!
	JMP  RETfromEBP

F18: ; emit
	CALL RETtoEBP
	MOV  EBX, EAX
	LEA  EAX, [I17] ; _em
	MOV  [EAX], BL
	LEA  EAX, [I17] ; _em
	MOV  ECX, EAX
	MOV  EAX, 0
	MOV  EBX, EAX
	MOV  EAX, 1
	MOV  EDX, EAX
	MOV  EAX, 4
	INT  0x80
	POP  EAX
	JMP  RETfromEBP

F19: ; bye
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 0
	MOV  EBX, EAX
	MOV  EAX, 1
	INT  0x80
	POP  EAX
	JMP  RETfromEBP

F21: ; ztype
	CALL RETtoEBP
	CALL F3 ; a@
	MOV  EBX, EAX
	LEA  EAX, [I20] ; _zt
	MOV  [EAX], EBX
	POP  EAX
	CALL F4 ; a!
Tgt1:
	CALL F13 ; c@a+
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
	LEA  EAX, [I20] ; _zt
	MOV  EAX, [EAX]
	CALL F4 ; a!
	JMP  RETfromEBP
Tgt2:
	CALL F18 ; emit
	JMP  Tgt1
	JMP  RETfromEBP

F24: ; 0=
	CALL RETtoEBP
	MOV  EBX, EAX
	MOV  EAX, 0
	CMP  EBX, EAX
	MOV  EAX, 0
	JNZ  @F
	DEC  EAX
@@:
	JMP  RETfromEBP

F25: ; Mil
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1000
	MOV  EBX, EAX
	IMUL EAX, EBX
	POP  EBX
	IMUL EAX, EBX
	JMP  RETfromEBP

F26: ; cr
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F18 ; emit
	JMP  RETfromEBP

F27: ; space
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 32
	CALL F18 ; emit
	JMP  RETfromEBP

F28: ; negate
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 0
	XCHG EAX, [ESP]
	POP  EBX
	XCHG EAX, EBX
	SUB  EAX, EBX
	JMP  RETfromEBP

F34: ; (.)
	CALL RETtoEBP
	CALL F3 ; a@
	MOV  EBX, EAX
	LEA  EAX, [I33] ; _dot
	MOV  [EAX], EBX
	LEA  EAX, [I32] ; #n
	CALL F4 ; a!
	PUSH EAX
	MOV  EAX, 0
	PUSH EAX
	CALL F16 ; c!a-
	CALL F16 ; c!a-
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
	LEA  EAX, [I32] ; #n
	MOV  [EAX], BL
	POP  EAX
	CALL F28 ; negate
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
	CALL F16 ; c!a-
	TEST EAX, EAX
	JNZ  Tgt4
	LEA  EAX, [I32] ; #n
	MOV  EAX, [EAX]
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt5
	PUSH EAX
	MOV  EAX, 45
	CALL F16 ; c!a-
Tgt5:
	CALL F3 ; a@
	INC  EAX
	CALL F21 ; ztype
	PUSH EAX
	LEA  EAX, [I33] ; _dot
	MOV  EAX, [EAX]
	CALL F4 ; a!
	JMP  RETfromEBP

F38: ; .
	CALL RETtoEBP
	CALL F34 ; (.)
	CALL F27 ; space
	JMP  RETfromEBP

F40: ; t0
	CALL RETtoEBP
	CALL F26 ; cr
	PUSH EAX
	MOV  EAX, 116
	CALL F18 ; emit
	CALL F38 ; .
	JMP  RETfromEBP

F41: ; t1
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [S1]
	CALL F21 ; ztype
	JMP  RETfromEBP

F42: ; t4
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 4
	CALL F40 ; t0
	PUSH EAX
	CALL F24 ; 0=
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt6
	PUSH EAX
	MOV  EAX, 121
	CALL F18 ; emit
	JMP  RETfromEBP
Tgt6:
	PUSH EAX
	MOV  EAX, 110
	CALL F18 ; emit
	JMP  RETfromEBP

F44: ; t5
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 5
	CALL F40 ; t0
	PUSH EAX
	LEA  EAX, [I29] ; buf
	CALL F4 ; a!
	PUSH EAX
	MOV  EAX, 104
	CALL F14 ; c!a+
	PUSH EAX
	MOV  EAX, 105
	CALL F14 ; c!a+
	PUSH EAX
	MOV  EAX, 0
	CALL F12 ; c!a
	PUSH EAX
	LEA  EAX, [I29] ; buf
	CALL F21 ; ztype
	CALL F27 ; space
	JMP  RETfromEBP

F45: ; t6
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 6
	CALL F40 ; t0
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
	CALL F38 ; .
	PUSH EAX
	LEA  EAX, [S2]
	CALL F21 ; ztype
	JMP  RETfromEBP

F46: ; t7
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 7
	CALL F40 ; t0
	PUSH EAX
	LEA  EAX, [S3]
	CALL F21 ; ztype
	JMP  RETfromEBP

F47: ; t8
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 8
	CALL F40 ; t0
	PUSH EAX
	MOV  EAX, 3344
	CALL F38 ; .
	PUSH EAX
	MOV  EAX, -3344
	CALL F38 ; .
	JMP  RETfromEBP

F48: ; t9
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 9
	CALL F40 ; t0
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
	CALL F38 ; .
	CALL F38 ; .
	CALL F38 ; .
	JMP  RETfromEBP

F49: ; t10
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F40 ; t0
	PUSH EAX
	MOV  EAX, 103
	MOV  EBX, EAX
	LEA  EAX, [I39] ; x
	MOV  [EAX], BL
	LEA  EAX, [I39] ; x
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	PUSH EAX
	CALL F38 ; .
	CALL F18 ; emit
	JMP  RETfromEBP

F50: ; t11
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 11
	CALL F40 ; t0
	PUSH EAX
	MOV  EAX, 115
	CALL F18 ; emit
	PUSH EAX
	MOV  EAX, 1000
	CALL F25 ; Mil
	PUSH EAX
	CALL F34 ; (.)
Tgt7:
	DEC  EAX
	JNZ  Tgt7
	MOV  EAX, 101
	CALL F18 ; emit
	JMP  RETfromEBP

F52: ; t12
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 12
	CALL F40 ; t0
	ADD  EDI, 20
	PUSH EAX
	LEA  EAX, [S4]
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
	CALL F38 ; .
	SUB  EDI, 20
	PUSH EAX
	LEA  EAX, [EDI+8]
	MOV  EAX, [EAX]
	CALL F21 ; ztype
	SUB  EDI, 20
	JMP  RETfromEBP

F53: ; t999
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [S5]
	CALL F21 ; ztype
	CALL F26 ; cr
	CALL F19 ; bye
	JMP  RETfromEBP

F54: ; main
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	MOV  EBX, EAX
	LEA  EAX, [I1] ; base
	MOV  [EAX], EBX
	POP  EAX
	CALL F41 ; t1
	PUSH EAX
	MOV  EAX, 0
	CALL F42 ; t4
	PUSH EAX
	MOV  EAX, 1
	CALL F42 ; t4
	CALL F44 ; t5
	CALL F45 ; t6
	CALL F46 ; t7
	CALL F47 ; t8
	CALL F48 ; t9
	CALL F49 ; t10
	CALL F50 ; t11
	CALL F52 ; t12
	CALL F26 ; cr
	CALL F53 ; t999
	CALL F26 ; cr
	PUSH EAX
	LEA  EAX, [S6]
	CALL F21 ; ztype
	JMP  RETfromEBP
;================== data =====================
segment readable writeable
;=============================================
intbuf      rb 12 ; for .d

; code: 5000 entries, 470 used
; heap: 5000 bytes, 62 used
; symbols: 500 entries, 54 used; num type size name
; --- ---- ---- -----------------
I1         dd 0 ; base
I2         dd 0 ; (a)
I17        dd 0 ; _em
I20        dd 0 ; _zt
I29        dd 0 ; buf
I30        dd 0 ; _b
I31        dd 0 ; _b
I32        dd 0 ; #n
I33        dd 0 ; _dot
I39        dd 0 ; x
S1         db "hello", 0
S2         db "(should print 666)", 0
S3         db "test ztype ...", 0
S4         db "-l3-", 0
S5         db "bye", 0
S6         db "still here? ", 0
locs       rd 500
rstk       rd 256

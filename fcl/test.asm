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

F2: ; @a
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [A]
	MOV  EAX, [EAX]
	JMP  RETfromEBP

F3: ; !a
	CALL RETtoEBP
	MOV  EBX, EAX
	MOV  EAX, [A]
	MOV  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F4: ; @a+
	CALL RETtoEBP
	CALL F2 ; @a
	PUSH EAX
	MOV  EAX, [A]
	MOV  EBX, EAX
	MOV  EAX, 4
	ADD  EAX, EBX
	MOV  [A], EAX
	POP  EAX
	JMP  RETfromEBP

F5: ; !a+
	CALL RETtoEBP
	CALL F3 ; !a
	PUSH EAX
	MOV  EAX, [A]
	MOV  EBX, EAX
	MOV  EAX, 4
	ADD  EAX, EBX
	MOV  [A], EAX
	POP  EAX
	JMP  RETfromEBP

F6: ; @a-
	CALL RETtoEBP
	CALL F2 ; @a
	PUSH EAX
	MOV  EAX, [A]
	MOV  EBX, EAX
	MOV  EAX, 4
	XCHG EAX, EBX
	SUB  EAX, EBX
	MOV  [A], EAX
	POP  EAX
	JMP  RETfromEBP

F7: ; !a-
	CALL RETtoEBP
	CALL F3 ; !a
	PUSH EAX
	MOV  EAX, [A]
	MOV  EBX, EAX
	MOV  EAX, 4
	XCHG EAX, EBX
	SUB  EAX, EBX
	MOV  [A], EAX
	POP  EAX
	JMP  RETfromEBP

F8: ; c@a
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [A]
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	JMP  RETfromEBP

F9: ; c!a
	CALL RETtoEBP
	MOV  EBX, EAX
	MOV  EAX, [A]
	MOV  [EAX], BL
	POP  EAX
	JMP  RETfromEBP

F10: ; c@a+
	CALL RETtoEBP
	CALL F8 ; c@a
	INC  [A]
	JMP  RETfromEBP

F11: ; c!a+
	CALL RETtoEBP
	CALL F9 ; c!a
	INC  [A]
	JMP  RETfromEBP

F12: ; c@a-
	CALL RETtoEBP
	CALL F8 ; c@a
	DEC  [A]
	JMP  RETfromEBP

F13: ; c!a-
	CALL RETtoEBP
	CALL F9 ; c!a
	DEC  [A]
	JMP  RETfromEBP

F14: ; +l
	CALL RETtoEBP
	ADD  EDI, 24
	PUSH EAX
	MOV  EAX, [A]
	MOV  EBX, EAX
	LEA  EAX, [EDI+0]
	MOV  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F15: ; -l
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [EDI+0]
	MOV  EAX, [EAX]
	MOV  [A], EAX
	POP  EAX
	SUB  EDI, 24
	JMP  RETfromEBP

F17: ; emit
	CALL RETtoEBP
	MOV  EBX, EAX
	LEA  EAX, [I16] ; _em
	MOV  [EAX], BL
	POP  EAX
	PUSH EAX
	LEA  EAX, [I16] ; _em
	MOV  ECX, EAX
	POP  EAX
	PUSH EAX
	MOV  EAX, 0
	MOV  EBX, EAX
	POP  EAX
	PUSH EAX
	MOV  EAX, 1
	MOV  EDX, EAX
	POP  EAX
	PUSH EAX
	MOV  EAX, 4
	INT  0x80
	POP  EAX
	JMP  RETfromEBP

F18: ; bye
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 0
	MOV  EBX, EAX
	POP  EAX
	PUSH EAX
	MOV  EAX, 1
	INT  0x80
	POP  EAX
	JMP  RETfromEBP

F19: ; ztype
	CALL RETtoEBP
	CALL F14 ; +l
	MOV  [A], EAX
	POP  EAX
Tgt1:
	CALL F10 ; c@a+
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
	POP  EAX
	CALL F15 ; -l
	JMP  RETfromEBP
Tgt2:
	CALL F17 ; emit
	JMP  Tgt1
	JMP  RETfromEBP

F22: ; 0=
	CALL RETtoEBP
	MOV  EBX, EAX
	MOV  EAX, 0
	CMP  EBX, EAX
	MOV  EAX, 0
	JNZ  @F
	DEC  EAX
@@:
	JMP  RETfromEBP

F23: ; Mil
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1000
	MOV  EBX, EAX
	IMUL EAX, EBX
	POP  EBX
	IMUL EAX, EBX
	JMP  RETfromEBP

F24: ; cr
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F17 ; emit
	JMP  RETfromEBP

F25: ; space
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 32
	CALL F17 ; emit
	JMP  RETfromEBP

F26: ; negate
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
	CALL F14 ; +l
	PUSH EAX
	LEA  EAX, [I28] ; #n
	MOV  [A], EAX
	POP  EAX
	PUSH EAX
	MOV  EAX, 0
	PUSH EAX
	CALL F13 ; c!a-
	CALL F13 ; c!a-
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
	LEA  EAX, [I28] ; #n
	MOV  [EAX], BL
	POP  EAX
	CALL F26 ; negate
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
	JZ   Tgt5
	MOV  EBX, EAX
	MOV  EAX, 7
	ADD  EAX, EBX
Tgt5:
	CALL F13 ; c!a-
	TEST EAX, EAX
	JNZ  Tgt4
	POP  EAX
	PUSH EAX
	LEA  EAX, [I28] ; #n
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt6
	PUSH EAX
	MOV  EAX, 45
	CALL F13 ; c!a-
Tgt6:
	PUSH EAX
	MOV  EAX, [A]
	INC  EAX
	CALL F19 ; ztype
	CALL F15 ; -l
	JMP  RETfromEBP

F34: ; .
	CALL RETtoEBP
	CALL F29 ; (.)
	CALL F25 ; space
	JMP  RETfromEBP

F35: ; strlen
	CALL RETtoEBP
	PUSH EAX
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	CALL F22 ; 0=
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt7
	POP  EAX
	PUSH EAX
	MOV  EAX, 0
	JMP  RETfromEBP
Tgt7:
	ADD  EDI, 24
	PUSH EAX
	MOV  EAX, [A]
	MOV  EBX, EAX
	LEA  EAX, [EDI+12]
	MOV  [EAX], EBX
	POP  EAX
	PUSH EAX
	MOV  [A], EAX
	POP  EAX
	MOV  EBX, EAX
	LEA  EAX, [EDI+4]
	MOV  [EAX], EBX
	POP  EAX
Tgt8:
	CALL F10 ; c@a+
	TEST EAX, EAX
	POP  EAX
	JNZ  Tgt8
	PUSH EAX
	MOV  EAX, [A]
	PUSH EAX
	LEA  EAX, [EDI+4]
	MOV  EAX, [EAX]
	POP  EBX
	XCHG EAX, EBX
	SUB  EAX, EBX
	DEC  EAX
	PUSH EAX
	LEA  EAX, [EDI+12]
	MOV  EAX, [EAX]
	MOV  [A], EAX
	POP  EAX
	SUB  EDI, 24
	JMP  RETfromEBP

F39: ; t0
	CALL RETtoEBP
	CALL F24 ; cr
	PUSH EAX
	MOV  EAX, 116
	CALL F17 ; emit
	CALL F34 ; .
	JMP  RETfromEBP

F40: ; t1
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1
	CALL F39 ; t0
	PUSH EAX
	LEA  EAX, [S1]
	CALL F19 ; ztype
	JMP  RETfromEBP

F41: ; t2
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 2
	CALL F39 ; t0
	PUSH EAX
	MOV  EAX, 1234
	PUSH EAX
	LEA  EAX, [S2]
	CALL F35 ; strlen
	CALL F34 ; .
	CALL F34 ; .
	JMP  RETfromEBP

F42: ; t4
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 4
	CALL F39 ; t0
	CALL F22 ; 0=
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt9
	PUSH EAX
	MOV  EAX, 110
	CALL F17 ; emit
	JMP  RETfromEBP
Tgt9:
	PUSH EAX
	MOV  EAX, 121
	CALL F17 ; emit
	JMP  RETfromEBP

F44: ; t5
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 5
	CALL F39 ; t0
	PUSH EAX
	LEA  EAX, [I27] ; buf
	MOV  [A], EAX
	POP  EAX
	PUSH EAX
	MOV  EAX, 104
	CALL F11 ; c!a+
	PUSH EAX
	MOV  EAX, 105
	CALL F11 ; c!a+
	PUSH EAX
	MOV  EAX, 0
	CALL F9 ; c!a
	PUSH EAX
	LEA  EAX, [I27] ; buf
	CALL F19 ; ztype
	CALL F25 ; space
	JMP  RETfromEBP

F45: ; t6
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 6
	CALL F39 ; t0
	PUSH EAX
	MOV  EAX, 666
	PUSH EAX
	MOV  EAX, 222
	MOV  EBX, EAX
	POP  EAX
	PUSH EAX
	MOV  EAX, 333
	MOV  ECX, EAX
	POP  EAX
	PUSH EAX
	MOV  EAX, 444
	MOV  EDX, EAX
	POP  EAX
	CALL F34 ; .
	PUSH EAX
	LEA  EAX, [S3]
	CALL F19 ; ztype
	JMP  RETfromEBP

F46: ; t7
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 7
	CALL F39 ; t0
	PUSH EAX
	LEA  EAX, [S4]
	CALL F19 ; ztype
	JMP  RETfromEBP

F47: ; t8
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 8
	CALL F39 ; t0
	PUSH EAX
	MOV  EAX, 3344
	CALL F34 ; .
	PUSH EAX
	MOV  EAX, -3344
	CALL F34 ; .
	PUSH EAX
	MOV  EAX, 4660
	CALL F34 ; .
	PUSH EAX
	MOV  EAX, 1234
	PUSH EAX
	MOV  EAX, 16
	MOV  EBX, EAX
	LEA  EAX, [I1] ; base
	MOV  [EAX], EBX
	POP  EAX
	CALL F34 ; .
	PUSH EAX
	MOV  EAX, 10
	MOV  EBX, EAX
	LEA  EAX, [I1] ; base
	MOV  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F48: ; t9
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 9
	CALL F39 ; t0
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
	CALL F34 ; .
	CALL F34 ; .
	CALL F34 ; .
	JMP  RETfromEBP

F49: ; t10
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F39 ; t0
	PUSH EAX
	MOV  EAX, 103
	MOV  EBX, EAX
	LEA  EAX, [I38] ; x
	MOV  [EAX], BL
	POP  EAX
	PUSH EAX
	LEA  EAX, [I38] ; x
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	PUSH EAX
	CALL F34 ; .
	CALL F17 ; emit
	JMP  RETfromEBP

F50: ; t11
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 11
	CALL F39 ; t0
	PUSH EAX
	MOV  EAX, 115
	CALL F17 ; emit
	PUSH EAX
	MOV  EAX, 1000
	CALL F23 ; Mil
	PUSH EAX
	CALL F29 ; (.)
Tgt10:
	DEC  EAX
	JNZ  Tgt10
	PUSH EAX
	MOV  EAX, 101
	CALL F17 ; emit
	JMP  RETfromEBP

F52: ; t12
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 12
	CALL F39 ; t0
	ADD  EDI, 24
	PUSH EAX
	LEA  EAX, [S5]
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
	CALL F34 ; .
	SUB  EDI, 24
	PUSH EAX
	LEA  EAX, [EDI+12]
	MOV  EAX, [EAX]
	CALL F19 ; ztype
	SUB  EDI, 24
	JMP  RETfromEBP

F53: ; t999
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [S6]
	CALL F19 ; ztype
	CALL F24 ; cr
	CALL F18 ; bye
	JMP  RETfromEBP

F54: ; main
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	MOV  EBX, EAX
	LEA  EAX, [I1] ; base
	MOV  [EAX], EBX
	POP  EAX
	CALL F40 ; t1
	CALL F41 ; t2
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
	CALL F24 ; cr
	CALL F53 ; t999
	CALL F24 ; cr
	PUSH EAX
	LEA  EAX, [S7]
	CALL F19 ; ztype
	JMP  RETfromEBP

;================== data =====================
segment readable writeable
;=============================================

; code: 5000 entries, 537 used
; heap: 5000 bytes, 76 used
; symbols: 500 entries, 54 used
S1         db "hello world!", 0
S2         db "hello", 0
S3         db "(should print 666)", 0
S4         db "test ztype ...", 0
S5         db "-l3-", 0
S6         db "bye", 0
S7         db "still here? s", 0
I1         rd   1 ; base
I16        rd   1 ; _em
I27        rd   3 ; buf
I28        rd   1 ; #n
I38        rd   1 ; x
A          rd   1
rstk       rd 256
locs       rd 500

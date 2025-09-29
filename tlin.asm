format ELF executable
;================== code =====================
segment readable executable
;=============================================
start:
	LEA  EBP, [rstk]
	LEA  EDI, [locs]
	CALL F64
	JMP  F4
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

F1: ; outc
	CALL RETtoEBP
; code
pop ebx
mov [eax], bl
mov edx, 1
mov ecx, eax
mov ebx, 1
mov eax, 4
int 0x80
pop eax
; end-code
	JMP  RETfromEBP

F3: ; emit
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [I2] ; _em
	CALL F1 ; outc
	JMP  RETfromEBP

F4: ; bye
	CALL RETtoEBP
; code
mov eax, 1
xor ebx, ebx
int 0x80
; end-code
	JMP  RETfromEBP

F5: ; @a
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [A]
	MOV  EAX, [EAX]
	JMP  RETfromEBP

F6: ; !a
	CALL RETtoEBP
	MOV  EBX, EAX
	MOV  EAX, [A]
	MOV  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F7: ; @a+
	CALL RETtoEBP
	CALL F5 ; @a
	PUSH EAX
	MOV  EAX, [A]
	ADD  EAX, 4
	MOV  [A], EAX
	POP  EAX
	JMP  RETfromEBP

F8: ; !a+
	CALL RETtoEBP
	CALL F6 ; !a
	PUSH EAX
	MOV  EAX, [A]
	ADD  EAX, 4
	MOV  [A], EAX
	POP  EAX
	JMP  RETfromEBP

F9: ; @a-
	CALL RETtoEBP
	CALL F5 ; @a
	PUSH EAX
	MOV  EAX, [A]
	MOV  EBX, EAX
	MOV  EAX, 4
	XCHG EAX, EBX
	SUB  EAX, EBX
	MOV  [A], EAX
	POP  EAX
	JMP  RETfromEBP

F10: ; !a-
	CALL RETtoEBP
	CALL F6 ; !a
	PUSH EAX
	MOV  EAX, [A]
	MOV  EBX, EAX
	MOV  EAX, 4
	XCHG EAX, EBX
	SUB  EAX, EBX
	MOV  [A], EAX
	POP  EAX
	JMP  RETfromEBP

F11: ; c@a
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [A]
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	JMP  RETfromEBP

F12: ; c!a
	CALL RETtoEBP
	MOV  EBX, EAX
	MOV  EAX, [A]
	MOV  [EAX], BL
	POP  EAX
	JMP  RETfromEBP

F13: ; c@a+
	CALL RETtoEBP
	CALL F11 ; c@a
	INC  [A]
	JMP  RETfromEBP

F14: ; c!a+
	CALL RETtoEBP
	CALL F12 ; c!a
	INC  [A]
	JMP  RETfromEBP

F15: ; c@a-
	CALL RETtoEBP
	CALL F11 ; c@a
	DEC  [A]
	JMP  RETfromEBP

F16: ; c!a-
	CALL RETtoEBP
	CALL F12 ; c!a
	DEC  [A]
	JMP  RETfromEBP

F17: ; +l
	CALL RETtoEBP
	ADD  EDI, 24
	PUSH EAX
	MOV  EAX, [A]
	MOV  EBX, EAX
	LEA  EAX, [EDI+0]
	MOV  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F18: ; -l
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [EDI+0]
	MOV  EAX, [EAX]
	MOV  [A], EAX
	POP  EAX
	SUB  EDI, 24
	JMP  RETfromEBP

F19: ; ztype
	CALL RETtoEBP
	CALL F17 ; +l
	MOV  [A], EAX
	POP  EAX
Tgt20:
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
	JZ   Tgt21
	POP  EAX
	CALL F18 ; -l
	JMP  RETfromEBP
Tgt21:
	CALL F3 ; emit
	JMP  Tgt20
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
	CALL F3 ; emit
	JMP  RETfromEBP

F25: ; space
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 32
	CALL F3 ; emit
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

F30: ; (.)
	CALL RETtoEBP
	CALL F17 ; +l
	PUSH EAX
	LEA  EAX, [I29] ; #n
	MOV  [A], EAX
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
	JZ   Tgt31
	PUSH EAX
	MOV  EAX, 1
	MOV  EBX, EAX
	LEA  EAX, [I29] ; #n
	MOV  [EAX], BL
	POP  EAX
	CALL F26 ; negate
Tgt31:
Tgt32:
	MOV  EBX, EAX
	MOV  EAX, [I27]
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
	JZ   Tgt33
	ADD  EAX, 7
Tgt33:
	CALL F16 ; c!a-
	TEST EAX, EAX
	JNZ  Tgt32
	POP  EAX
	PUSH EAX
	LEA  EAX, [I29] ; #n
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt34
	PUSH EAX
	MOV  EAX, 45
	CALL F16 ; c!a-
Tgt34:
	PUSH EAX
	MOV  EAX, [A]
	INC  EAX
	CALL F19 ; ztype
	CALL F18 ; -l
	JMP  RETfromEBP

F35: ; .
	CALL RETtoEBP
	CALL F30 ; (.)
	CALL F25 ; space
	JMP  RETfromEBP

F36: ; strlen
	CALL RETtoEBP
	PUSH EAX
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	CALL F22 ; 0=
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt37
	MOV  EAX, 0
	JMP  RETfromEBP
Tgt37:
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
Tgt38:
	CALL F13 ; c@a+
	TEST EAX, EAX
	POP  EAX
	JNZ  Tgt38
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

F40: ; x++
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [I39]
	INC  EAX
	MOV  [I39], EAX
	POP  EAX
	JMP  RETfromEBP

F41: ; x+4
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [I39]
	ADD  EAX, 4
	MOV  [I39], EAX
	POP  EAX
	JMP  RETfromEBP

F42: ; t0
	CALL RETtoEBP
	CALL F24 ; cr
	PUSH EAX
	MOV  EAX, 116
	CALL F3 ; emit
	CALL F35 ; .
	JMP  RETfromEBP

F43: ; t1
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1
	CALL F42 ; t0
	PUSH EAX
	LEA  EAX, [S44]
	CALL F19 ; ztype
	JMP  RETfromEBP

F45: ; t2
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 2
	CALL F42 ; t0
	PUSH EAX
	MOV  EAX, 1234
	PUSH EAX
	LEA  EAX, [S46]
	CALL F36 ; strlen
	CALL F35 ; .
	CALL F35 ; .
	JMP  RETfromEBP

F47: ; t3
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 3
	CALL F42 ; t0
	PUSH EAX
	MOV  EAX, 97
	PUSH EAX
	LEA  EAX, [I2] ; _em
	CALL F1 ; outc
	JMP  RETfromEBP

F48: ; t4
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 4
	CALL F42 ; t0
	CALL F22 ; 0=
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt49
	PUSH EAX
	MOV  EAX, 110
	CALL F3 ; emit
	JMP  RETfromEBP
Tgt49:
	PUSH EAX
	MOV  EAX, 121
	CALL F3 ; emit
	JMP  RETfromEBP

F50: ; t5
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 5
	CALL F42 ; t0
	PUSH EAX
	LEA  EAX, [I28] ; buf
	MOV  [A], EAX
	MOV  EAX, 104
	CALL F14 ; c!a+
	PUSH EAX
	MOV  EAX, 105
	CALL F14 ; c!a+
	PUSH EAX
	MOV  EAX, 0
	CALL F12 ; c!a
	PUSH EAX
	LEA  EAX, [I28] ; buf
	CALL F19 ; ztype
	CALL F25 ; space
	JMP  RETfromEBP

F51: ; t6
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
	CALL F35 ; .
	PUSH EAX
	LEA  EAX, [S52]
	CALL F19 ; ztype
	JMP  RETfromEBP

F53: ; t7
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 7
	CALL F42 ; t0
	PUSH EAX
	LEA  EAX, [S54]
	CALL F19 ; ztype
	JMP  RETfromEBP

F55: ; t8
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 8
	CALL F42 ; t0
	PUSH EAX
	MOV  EAX, 3344
	CALL F35 ; .
	PUSH EAX
	MOV  EAX, -3344
	CALL F35 ; .
	PUSH EAX
	MOV  EAX, 4660
	CALL F35 ; .
	PUSH EAX
	MOV  EAX, 1234
	PUSH EAX
	MOV  EAX, 16
	MOV  [I27], EAX
	POP  EAX
	CALL F35 ; .
	PUSH EAX
	MOV  EAX, 10
	MOV  [I27], EAX
	POP  EAX
	JMP  RETfromEBP

F56: ; t9
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
	CALL F35 ; .
	CALL F35 ; .
	CALL F35 ; .
	JMP  RETfromEBP

F57: ; t10
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F42 ; t0
	PUSH EAX
	MOV  EAX, 103
	MOV  EBX, EAX
	LEA  EAX, [I39] ; x
	MOV  [EAX], BL
	POP  EAX
	PUSH EAX
	LEA  EAX, [I39] ; x
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	PUSH EAX
	CALL F35 ; .
	CALL F3 ; emit
	JMP  RETfromEBP

F58: ; t11
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 11
	CALL F42 ; t0
	PUSH EAX
	MOV  EAX, 115
	CALL F3 ; emit
	PUSH EAX
	MOV  EAX, 1000
	CALL F23 ; Mil
	PUSH EAX
	CALL F30 ; (.)
Tgt59:
	DEC  EAX
	JNZ  Tgt59
	PUSH EAX
	MOV  EAX, 101
	CALL F3 ; emit
	JMP  RETfromEBP

F60: ; t12
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 12
	CALL F42 ; t0
	ADD  EDI, 24
	PUSH EAX
	LEA  EAX, [S61]
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
	CALL F35 ; .
	SUB  EDI, 24
	PUSH EAX
	LEA  EAX, [EDI+12]
	MOV  EAX, [EAX]
	CALL F19 ; ztype
	SUB  EDI, 24
	JMP  RETfromEBP

F62: ; t999
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [S63]
	CALL F19 ; ztype
	CALL F24 ; cr
	CALL F4 ; bye
	JMP  RETfromEBP

F64: ; main
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	MOV  [I27], EAX
	POP  EAX
	CALL F43 ; t1
	CALL F45 ; t2
	CALL F47 ; t3
	PUSH EAX
	MOV  EAX, 0
	CALL F48 ; t4
	PUSH EAX
	MOV  EAX, 1
	CALL F48 ; t4
	CALL F50 ; t5
	CALL F51 ; t6
	CALL F53 ; t7
	CALL F55 ; t8
	CALL F56 ; t9
	CALL F57 ; t10
	CALL F58 ; t11
	CALL F60 ; t12
	CALL F24 ; cr
	CALL F62 ; t999
	CALL F24 ; cr
	PUSH EAX
	LEA  EAX, [S65]
	CALL F19 ; ztype
	JMP  RETfromEBP

;================== data =====================
segment readable writeable

; code: 5000 entries, 515 used
; heap: 5000 bytes, 205 used
; symbols: 500 entries, 65 used
S44        db "hello world!", 0
S46        db "hello", 0
S52        db "(should print 666)", 0
S54        db "test ztype ...", 0
S61        db "-l3-", 0
S63        db "bye", 0
S65        db "still here? s", 0
I2         rd   1 ; _em
I27        rd   1 ; base
I28        rd   3 ; buf
I29        rd   1 ; #n
I39        rd   1 ; x
A          rd   1
rstk       rd 256
locs       rd 500
; final code size: 515 instructions

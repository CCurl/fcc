format ELF executable
;================== code =====================
segment readable executable
;=============================================
start:
	LEA  EBP, [rstk]
	LEA  EDI, [locs]
	CALL F68
	JMP  F7
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

F1: ; outChar
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
	CALL F1 ; outChar
	JMP  RETfromEBP

F4: ; inKey
	CALL RETtoEBP
; code
mov ebx, 0
mov ecx, eax
mov edx, 1
mov eax, 3
push ecx
int 0x80
pop ecx
movzx eax, byte [ecx]
; end-code
	JMP  RETfromEBP

F6: ; key
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [I5] ; _k
	CALL F4 ; inKey
	JMP  RETfromEBP

F7: ; bye
	CALL RETtoEBP
; code
mov eax, 1
xor ebx, ebx
int 0x80
; end-code
	JMP  RETfromEBP

F8: ; @a
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [A]
	MOV  EAX, [EAX]
	JMP  RETfromEBP

F9: ; !a
	CALL RETtoEBP
	MOV  EBX, EAX
	MOV  EAX, [A]
	MOV  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F10: ; @a+
	CALL RETtoEBP
	CALL F8 ; @a
	PUSH EAX
	MOV  EAX, [A]
	ADD  EAX, 4
	MOV  [A], EAX
	POP  EAX
	JMP  RETfromEBP

F11: ; !a+
	CALL RETtoEBP
	CALL F9 ; !a
	PUSH EAX
	MOV  EAX, [A]
	ADD  EAX, 4
	MOV  [A], EAX
	POP  EAX
	JMP  RETfromEBP

F12: ; @a-
	CALL RETtoEBP
	CALL F8 ; @a
	PUSH EAX
	MOV  EAX, [A]
	MOV  EBX, EAX
	MOV  EAX, 4
	XCHG EAX, EBX
	SUB  EAX, EBX
	MOV  [A], EAX
	POP  EAX
	JMP  RETfromEBP

F13: ; !a-
	CALL RETtoEBP
	CALL F9 ; !a
	PUSH EAX
	MOV  EAX, [A]
	MOV  EBX, EAX
	MOV  EAX, 4
	XCHG EAX, EBX
	SUB  EAX, EBX
	MOV  [A], EAX
	POP  EAX
	JMP  RETfromEBP

F14: ; c@a
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [A]
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	JMP  RETfromEBP

F15: ; c!a
	CALL RETtoEBP
	MOV  EBX, EAX
	MOV  EAX, [A]
	MOV  [EAX], BL
	POP  EAX
	JMP  RETfromEBP

F16: ; c@a+
	CALL RETtoEBP
	CALL F14 ; c@a
	INC  [A]
	JMP  RETfromEBP

F17: ; c!a+
	CALL RETtoEBP
	CALL F15 ; c!a
	INC  [A]
	JMP  RETfromEBP

F18: ; c@a-
	CALL RETtoEBP
	CALL F14 ; c@a
	DEC  [A]
	JMP  RETfromEBP

F19: ; c!a-
	CALL RETtoEBP
	CALL F15 ; c!a
	DEC  [A]
	JMP  RETfromEBP

F20: ; +L
	CALL RETtoEBP
	ADD  EDI, 24
	PUSH EAX
	MOV  EAX, [A]
	MOV  EBX, EAX
	LEA  EAX, [EDI+0]
	MOV  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F21: ; -L
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [EDI+0]
	MOV  EAX, [EAX]
	MOV  [A], EAX
	POP  EAX
	SUB  EDI, 24
	JMP  RETfromEBP

F22: ; 0=
	CALL RETtoEBP
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt23
	PUSH EAX
	MOV  EAX, 0
	JMP  RETfromEBP
Tgt23:
	PUSH EAX
	MOV  EAX, 1
	JMP  RETfromEBP

F24: ; ztype
	CALL RETtoEBP
	CALL F20 ; +L
	MOV  [A], EAX
	POP  EAX
Tgt25:
	CALL F16 ; c@a+
	PUSH EAX
	CALL F22 ; 0=
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt26
	POP  EAX
	CALL F21 ; -L
	JMP  RETfromEBP
Tgt26:
	CALL F3 ; emit
	JMP  Tgt25
	JMP  RETfromEBP

F27: ; Mil
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1000
	MOV  EBX, EAX
	IMUL EAX, EBX
	POP  EBX
	IMUL EAX, EBX
	JMP  RETfromEBP

F28: ; cr
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F3 ; emit
	JMP  RETfromEBP

F29: ; space
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 32
	CALL F3 ; emit
	JMP  RETfromEBP

F30: ; negate
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
	CALL F20 ; +L
	PUSH EAX
	LEA  EAX, [I33] ; #n
	MOV  [A], EAX
	MOV  EAX, 0
	PUSH EAX
	CALL F19 ; c!a-
	CALL F19 ; c!a-
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
	JZ   Tgt35
	PUSH EAX
	MOV  EAX, 1
	MOV  EBX, EAX
	LEA  EAX, [I33] ; #n
	MOV  [EAX], BL
	POP  EAX
	CALL F30 ; negate
Tgt35:
Tgt36:
	MOV  EBX, EAX
	MOV  EAX, [I31]
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
	JZ   Tgt37
	ADD  EAX, 7
Tgt37:
	CALL F19 ; c!a-
	TEST EAX, EAX
	JNZ  Tgt36
	POP  EAX
	PUSH EAX
	LEA  EAX, [I33] ; #n
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt38
	PUSH EAX
	MOV  EAX, 45
	CALL F19 ; c!a-
Tgt38:
	PUSH EAX
	MOV  EAX, [A]
	INC  EAX
	CALL F24 ; ztype
	CALL F21 ; -L
	JMP  RETfromEBP

F39: ; .
	CALL RETtoEBP
	CALL F34 ; (.)
	CALL F29 ; space
	JMP  RETfromEBP

F40: ; strlen
	CALL RETtoEBP
	PUSH EAX
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	CALL F22 ; 0=
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt41
	MOV  EAX, 0
	JMP  RETfromEBP
Tgt41:
	CALL F20 ; +L
	PUSH EAX
	MOV  [A], EAX
	POP  EAX
	MOV  EBX, EAX
	LEA  EAX, [EDI+4]
	MOV  [EAX], EBX
	POP  EAX
Tgt42:
	CALL F16 ; c@a+
	TEST EAX, EAX
	POP  EAX
	JNZ  Tgt42
	PUSH EAX
	MOV  EAX, [A]
	PUSH EAX
	LEA  EAX, [EDI+4]
	MOV  EAX, [EAX]
	POP  EBX
	XCHG EAX, EBX
	SUB  EAX, EBX
	DEC  EAX
	CALL F21 ; -L
	JMP  RETfromEBP

F44: ; x++
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [I43]
	INC  EAX
	MOV  [I43], EAX
	POP  EAX
	JMP  RETfromEBP

F45: ; x+4
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [I43]
	ADD  EAX, 4
	MOV  [I43], EAX
	POP  EAX
	JMP  RETfromEBP

F46: ; t0
	CALL RETtoEBP
	CALL F28 ; cr
	PUSH EAX
	MOV  EAX, 116
	CALL F3 ; emit
	CALL F39 ; .
	JMP  RETfromEBP

F47: ; t1
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1
	CALL F46 ; t0
	PUSH EAX
	LEA  EAX, [S48]
	CALL F24 ; ztype
	JMP  RETfromEBP

F49: ; t2
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 2
	CALL F46 ; t0
	PUSH EAX
	MOV  EAX, 1234
	PUSH EAX
	LEA  EAX, [S50]
	CALL F40 ; strlen
	CALL F39 ; .
	CALL F39 ; .
	JMP  RETfromEBP

F51: ; t3
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 3
	CALL F46 ; t0
	JMP  RETfromEBP

F52: ; t4
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 4
	CALL F46 ; t0
	CALL F22 ; 0=
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt53
	PUSH EAX
	MOV  EAX, 110
	CALL F3 ; emit
	JMP  RETfromEBP
Tgt53:
	PUSH EAX
	MOV  EAX, 121
	CALL F3 ; emit
	JMP  RETfromEBP

F54: ; t5
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 5
	CALL F46 ; t0
	PUSH EAX
	LEA  EAX, [I32] ; buf
	MOV  [A], EAX
	MOV  EAX, 104
	CALL F17 ; c!a+
	PUSH EAX
	MOV  EAX, 105
	CALL F17 ; c!a+
	PUSH EAX
	MOV  EAX, 0
	CALL F15 ; c!a
	PUSH EAX
	LEA  EAX, [I32] ; buf
	CALL F24 ; ztype
	CALL F29 ; space
	JMP  RETfromEBP

F55: ; t6
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 6
	CALL F46 ; t0
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
	CALL F39 ; .
	PUSH EAX
	LEA  EAX, [S56]
	CALL F24 ; ztype
	JMP  RETfromEBP

F57: ; t7
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 7
	CALL F46 ; t0
	PUSH EAX
	LEA  EAX, [S58]
	CALL F24 ; ztype
	JMP  RETfromEBP

F59: ; t8
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 8
	CALL F46 ; t0
	PUSH EAX
	MOV  EAX, 3344
	CALL F39 ; .
	PUSH EAX
	MOV  EAX, -3344
	CALL F39 ; .
	PUSH EAX
	MOV  EAX, 4660
	CALL F39 ; .
	PUSH EAX
	MOV  EAX, 1234
	PUSH EAX
	MOV  EAX, 16
	MOV  [I31], EAX
	POP  EAX
	CALL F39 ; .
	PUSH EAX
	MOV  EAX, 10
	MOV  [I31], EAX
	POP  EAX
	JMP  RETfromEBP

F60: ; t9
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 9
	CALL F46 ; t0
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
	CALL F39 ; .
	CALL F39 ; .
	CALL F39 ; .
	JMP  RETfromEBP

F61: ; t10
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F46 ; t0
	PUSH EAX
	MOV  EAX, 103
	MOV  EBX, EAX
	LEA  EAX, [I43] ; x
	MOV  [EAX], BL
	POP  EAX
	PUSH EAX
	LEA  EAX, [I43] ; x
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	PUSH EAX
	CALL F39 ; .
	CALL F3 ; emit
	JMP  RETfromEBP

F62: ; t11
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 11
	CALL F46 ; t0
	PUSH EAX
	MOV  EAX, 115
	CALL F3 ; emit
	PUSH EAX
	MOV  EAX, 1000
	CALL F27 ; Mil
	PUSH EAX
	CALL F34 ; (.)
Tgt63:
	DEC  EAX
	JNZ  Tgt63
	PUSH EAX
	MOV  EAX, 101
	CALL F3 ; emit
	JMP  RETfromEBP

F64: ; t12
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 12
	CALL F46 ; t0
	ADD  EDI, 24
	PUSH EAX
	LEA  EAX, [S65]
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
	CALL F39 ; .
	SUB  EDI, 24
	PUSH EAX
	LEA  EAX, [EDI+12]
	MOV  EAX, [EAX]
	CALL F24 ; ztype
	SUB  EDI, 24
	JMP  RETfromEBP

F66: ; t999
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [S67]
	CALL F24 ; ztype
	CALL F28 ; cr
	CALL F7 ; bye
	JMP  RETfromEBP

F68: ; main
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	MOV  [I31], EAX
	POP  EAX
	CALL F47 ; t1
	CALL F49 ; t2
	CALL F51 ; t3
	PUSH EAX
	MOV  EAX, 0
	CALL F52 ; t4
	PUSH EAX
	MOV  EAX, 1
	CALL F52 ; t4
	CALL F54 ; t5
	CALL F55 ; t6
	CALL F57 ; t7
	CALL F59 ; t8
	CALL F60 ; t9
	CALL F61 ; t10
	CALL F62 ; t11
	CALL F64 ; t12
	CALL F28 ; cr
	CALL F66 ; t999
	CALL F28 ; cr
	PUSH EAX
	LEA  EAX, [S69]
	CALL F24 ; ztype
	JMP  RETfromEBP

;================== data =====================
segment readable writeable

; code: 10000 entries, 511 used
; heap: 5000 bytes, 305 used
; symbols: 1000 entries, 69 used
S48      db "hello world!", 0
S50      db "hello", 0
S56      db "(should print 666)", 0
S58      db "test ztype ...", 0
S65      db "-l3-", 0
S67      db "bye", 0
S69      db "still here?", 0
I2       rd   1 ; _em
I5       rd   1 ; _k
I31      rd   1 ; base
I32      rd   3 ; buf
I33      rd   1 ; #n
I43      rd   1 ; x
A        rd   1
rstk     rd 256
locs     rd 500

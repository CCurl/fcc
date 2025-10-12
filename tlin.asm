format ELF executable
;================== code =====================
segment readable executable
;=============================================
start:
	LEA  EBP, [rstk]
	LEA  EDI, [locs]
	CALL F67
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
	SUB  EAX, 4
	MOV  [A], EAX
	POP  EAX
	JMP  RETfromEBP

F13: ; !a-
	CALL RETtoEBP
	CALL F9 ; !a
	PUSH EAX
	MOV  EAX, [A]
	SUB  EAX, 4
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
	MOV  EBX, EAX
	POP  EAX
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
	ADD  EDI, 24
	PUSH EAX
	MOV  EAX, [A]
	MOV  EBX, EAX
	LEA  EAX, [EDI+0]
	MOV  [EAX], EBX
	POP  EAX
	MOV  [A], EAX
	MOV  EAX, 0
Tgt41:
	INC  EAX
	PUSH EAX
	MOV  EAX, [A]
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	INC  [A]
	TEST EAX, EAX
	POP  EAX
	JNZ  Tgt41
	DEC  EAX
	PUSH EAX
	LEA  EAX, [EDI+0]
	MOV  EAX, [EAX]
	MOV  [A], EAX
	POP  EAX
	SUB  EDI, 24
	JMP  RETfromEBP

F43: ; x++
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [I42]
	INC  EAX
	MOV  [I42], EAX
	POP  EAX
	JMP  RETfromEBP

F44: ; x+4
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [I42]
	ADD  EAX, 4
	MOV  [I42], EAX
	POP  EAX
	JMP  RETfromEBP

F45: ; t0
	CALL RETtoEBP
	CALL F28 ; cr
	PUSH EAX
	MOV  EAX, 116
	CALL F3 ; emit
	CALL F39 ; .
	JMP  RETfromEBP

F46: ; t1
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1
	CALL F45 ; t0
	PUSH EAX
	LEA  EAX, [S47]
	CALL F24 ; ztype
	JMP  RETfromEBP

F48: ; t2
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 2
	CALL F45 ; t0
	PUSH EAX
	MOV  EAX, 1234
	PUSH EAX
	LEA  EAX, [S49]
	CALL F40 ; strlen
	CALL F39 ; .
	CALL F39 ; .
	JMP  RETfromEBP

F50: ; t3
	CALL RETtoEBP
	JMP  RETfromEBP

F51: ; t4
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 4
	CALL F45 ; t0
	CALL F22 ; 0=
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt52
	PUSH EAX
	MOV  EAX, 110
	CALL F3 ; emit
	JMP  RETfromEBP
Tgt52:
	PUSH EAX
	MOV  EAX, 121
	CALL F3 ; emit
	JMP  RETfromEBP

F53: ; t5
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 5
	CALL F45 ; t0
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

F54: ; t6
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 6
	CALL F45 ; t0
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
	LEA  EAX, [S55]
	CALL F24 ; ztype
	JMP  RETfromEBP

F56: ; t7
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 7
	CALL F45 ; t0
	PUSH EAX
	LEA  EAX, [S57]
	CALL F24 ; ztype
	JMP  RETfromEBP

F58: ; t8
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 8
	CALL F45 ; t0
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

F59: ; t9
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 9
	CALL F45 ; t0
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

F60: ; t10
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F45 ; t0
	PUSH EAX
	MOV  EAX, 103
	MOV  EBX, EAX
	LEA  EAX, [I42] ; x
	MOV  [EAX], BL
	POP  EAX
	PUSH EAX
	LEA  EAX, [I42] ; x
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	PUSH EAX
	CALL F39 ; .
	CALL F3 ; emit
	JMP  RETfromEBP

F61: ; t11
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 11
	CALL F45 ; t0
	PUSH EAX
	MOV  EAX, 115
	CALL F3 ; emit
	PUSH EAX
	MOV  EAX, 999
	CALL F27 ; Mil
	PUSH EAX
	CALL F34 ; (.)
Tgt62:
	DEC  EAX
	JNZ  Tgt62
	PUSH EAX
	MOV  EAX, 101
	CALL F3 ; emit
	JMP  RETfromEBP

F63: ; t12
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 12
	CALL F45 ; t0
	ADD  EDI, 24
	PUSH EAX
	LEA  EAX, [S64]
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

F65: ; t999
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [S66]
	CALL F24 ; ztype
	CALL F28 ; cr
	CALL F7 ; bye
	JMP  RETfromEBP

F67: ; main
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	MOV  [I31], EAX
	POP  EAX
	CALL F46 ; t1
	CALL F48 ; t2
	CALL F50 ; t3
	PUSH EAX
	MOV  EAX, 0
	CALL F51 ; t4
	PUSH EAX
	MOV  EAX, 1
	CALL F51 ; t4
	CALL F53 ; t5
	CALL F54 ; t6
	CALL F56 ; t7
	CALL F58 ; t8
	CALL F59 ; t9
	CALL F60 ; t10
	CALL F61 ; t11
	CALL F63 ; t12
	CALL F28 ; cr
	CALL F65 ; t999
	CALL F28 ; cr
	PUSH EAX
	LEA  EAX, [S68]
	CALL F24 ; ztype
	JMP  RETfromEBP

;================== data =====================
segment readable writeable

; code: 10000 entries, 499 used
; heap: 5000 bytes, 305 used
; symbols: 1000 entries, 68 used
S47      db "hello world!", 0
S49      db "hello", 0
S55      db "(should print 666)", 0
S57      db "test ztype ...", 0
S64      db "-l3-", 0
S66      db "bye", 0
S68      db "still here?", 0
I2       rd   1 ; _em
I5       rd   1 ; _k
I31      rd   1 ; base
I32      rd   3 ; buf
I33      rd   1 ; #n
I42      rd   1 ; x
A        rd   1
rstk     rd 256
locs     rd 500

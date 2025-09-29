format ELF executable
;================== code =====================
segment readable executable
;=============================================
start:
	LEA  EBP, [rstk]
	LEA  EDI, [locs]
	CALL F65
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

F17: ; +L
	CALL RETtoEBP
	ADD  EDI, 24
	PUSH EAX
	MOV  EAX, [A]
	MOV  EBX, EAX
	LEA  EAX, [EDI+0]
	MOV  [EAX], EBX
	POP  EAX
	JMP  RETfromEBP

F18: ; -L
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [EDI+0]
	MOV  EAX, [EAX]
	MOV  [A], EAX
	POP  EAX
	SUB  EDI, 24
	JMP  RETfromEBP

F19: ; 0=
	CALL RETtoEBP
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt20
	PUSH EAX
	MOV  EAX, 0
	JMP  RETfromEBP
Tgt20:
	PUSH EAX
	MOV  EAX, 1
	JMP  RETfromEBP

F21: ; ztype
	CALL RETtoEBP
	CALL F17 ; +L
	MOV  [A], EAX
	POP  EAX
Tgt22:
	CALL F13 ; c@a+
	PUSH EAX
	CALL F19 ; 0=
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt23
	POP  EAX
	CALL F18 ; -L
	JMP  RETfromEBP
Tgt23:
	CALL F3 ; emit
	JMP  Tgt22
	JMP  RETfromEBP

F24: ; Mil
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1000
	MOV  EBX, EAX
	IMUL EAX, EBX
	POP  EBX
	IMUL EAX, EBX
	JMP  RETfromEBP

F25: ; cr
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F3 ; emit
	JMP  RETfromEBP

F26: ; space
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 32
	CALL F3 ; emit
	JMP  RETfromEBP

F27: ; negate
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 0
	XCHG EAX, [ESP]
	POP  EBX
	XCHG EAX, EBX
	SUB  EAX, EBX
	JMP  RETfromEBP

F31: ; (.)
	CALL RETtoEBP
	CALL F17 ; +L
	PUSH EAX
	LEA  EAX, [I30] ; #n
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
	JZ   Tgt32
	PUSH EAX
	MOV  EAX, 1
	MOV  EBX, EAX
	LEA  EAX, [I30] ; #n
	MOV  [EAX], BL
	POP  EAX
	CALL F27 ; negate
Tgt32:
Tgt33:
	MOV  EBX, EAX
	MOV  EAX, [I28]
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
	JZ   Tgt34
	ADD  EAX, 7
Tgt34:
	CALL F16 ; c!a-
	TEST EAX, EAX
	JNZ  Tgt33
	POP  EAX
	PUSH EAX
	LEA  EAX, [I30] ; #n
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt35
	PUSH EAX
	MOV  EAX, 45
	CALL F16 ; c!a-
Tgt35:
	PUSH EAX
	MOV  EAX, [A]
	INC  EAX
	CALL F21 ; ztype
	CALL F18 ; -L
	JMP  RETfromEBP

F36: ; .
	CALL RETtoEBP
	CALL F31 ; (.)
	CALL F26 ; space
	JMP  RETfromEBP

F37: ; strlen
	CALL RETtoEBP
	PUSH EAX
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	CALL F19 ; 0=
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt38
	MOV  EAX, 0
	JMP  RETfromEBP
Tgt38:
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
Tgt39:
	CALL F13 ; c@a+
	TEST EAX, EAX
	POP  EAX
	JNZ  Tgt39
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

F41: ; x++
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [I40]
	INC  EAX
	MOV  [I40], EAX
	POP  EAX
	JMP  RETfromEBP

F42: ; x+4
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, [I40]
	ADD  EAX, 4
	MOV  [I40], EAX
	POP  EAX
	JMP  RETfromEBP

F43: ; t0
	CALL RETtoEBP
	CALL F25 ; cr
	PUSH EAX
	MOV  EAX, 116
	CALL F3 ; emit
	CALL F36 ; .
	JMP  RETfromEBP

F44: ; t1
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 1
	CALL F43 ; t0
	PUSH EAX
	LEA  EAX, [S45]
	CALL F21 ; ztype
	JMP  RETfromEBP

F46: ; t2
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 2
	CALL F43 ; t0
	PUSH EAX
	MOV  EAX, 1234
	PUSH EAX
	LEA  EAX, [S47]
	CALL F37 ; strlen
	CALL F36 ; .
	CALL F36 ; .
	JMP  RETfromEBP

F48: ; t3
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 3
	CALL F43 ; t0
	PUSH EAX
	MOV  EAX, 97
	PUSH EAX
	LEA  EAX, [I2] ; _em
	CALL F1 ; outc
	JMP  RETfromEBP

F49: ; t4
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 4
	CALL F43 ; t0
	CALL F19 ; 0=
	TEST EAX, EAX
	POP  EAX
	JZ   Tgt50
	PUSH EAX
	MOV  EAX, 110
	CALL F3 ; emit
	JMP  RETfromEBP
Tgt50:
	PUSH EAX
	MOV  EAX, 121
	CALL F3 ; emit
	JMP  RETfromEBP

F51: ; t5
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 5
	CALL F43 ; t0
	PUSH EAX
	LEA  EAX, [I29] ; buf
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
	LEA  EAX, [I29] ; buf
	CALL F21 ; ztype
	CALL F26 ; space
	JMP  RETfromEBP

F52: ; t6
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 6
	CALL F43 ; t0
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
	CALL F36 ; .
	PUSH EAX
	LEA  EAX, [S53]
	CALL F21 ; ztype
	JMP  RETfromEBP

F54: ; t7
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 7
	CALL F43 ; t0
	PUSH EAX
	LEA  EAX, [S55]
	CALL F21 ; ztype
	JMP  RETfromEBP

F56: ; t8
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 8
	CALL F43 ; t0
	PUSH EAX
	MOV  EAX, 3344
	CALL F36 ; .
	PUSH EAX
	MOV  EAX, -3344
	CALL F36 ; .
	PUSH EAX
	MOV  EAX, 4660
	CALL F36 ; .
	PUSH EAX
	MOV  EAX, 1234
	PUSH EAX
	MOV  EAX, 16
	MOV  [I28], EAX
	POP  EAX
	CALL F36 ; .
	PUSH EAX
	MOV  EAX, 10
	MOV  [I28], EAX
	POP  EAX
	JMP  RETfromEBP

F57: ; t9
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 9
	CALL F43 ; t0
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
	CALL F36 ; .
	CALL F36 ; .
	CALL F36 ; .
	JMP  RETfromEBP

F58: ; t10
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F43 ; t0
	PUSH EAX
	MOV  EAX, 103
	MOV  EBX, EAX
	LEA  EAX, [I40] ; x
	MOV  [EAX], BL
	POP  EAX
	PUSH EAX
	LEA  EAX, [I40] ; x
	MOV  AL, [EAX]
	AND  EAX, 0xFF
	PUSH EAX
	CALL F36 ; .
	CALL F3 ; emit
	JMP  RETfromEBP

F59: ; t11
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 11
	CALL F43 ; t0
	PUSH EAX
	MOV  EAX, 115
	CALL F3 ; emit
	PUSH EAX
	MOV  EAX, 1000
	CALL F24 ; Mil
	PUSH EAX
	CALL F31 ; (.)
Tgt60:
	DEC  EAX
	JNZ  Tgt60
	PUSH EAX
	MOV  EAX, 101
	CALL F3 ; emit
	JMP  RETfromEBP

F61: ; t12
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 12
	CALL F43 ; t0
	ADD  EDI, 24
	PUSH EAX
	LEA  EAX, [S62]
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
	CALL F36 ; .
	SUB  EDI, 24
	PUSH EAX
	LEA  EAX, [EDI+12]
	MOV  EAX, [EAX]
	CALL F21 ; ztype
	SUB  EDI, 24
	JMP  RETfromEBP

F63: ; t999
	CALL RETtoEBP
	PUSH EAX
	LEA  EAX, [S64]
	CALL F21 ; ztype
	CALL F25 ; cr
	CALL F4 ; bye
	JMP  RETfromEBP

F65: ; main
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	MOV  [I28], EAX
	POP  EAX
	CALL F44 ; t1
	CALL F46 ; t2
	CALL F48 ; t3
	PUSH EAX
	MOV  EAX, 0
	CALL F49 ; t4
	PUSH EAX
	MOV  EAX, 1
	CALL F49 ; t4
	CALL F51 ; t5
	CALL F52 ; t6
	CALL F54 ; t7
	CALL F56 ; t8
	CALL F57 ; t9
	CALL F58 ; t10
	CALL F59 ; t11
	CALL F61 ; t12
	CALL F25 ; cr
	CALL F63 ; t999
	CALL F25 ; cr
	PUSH EAX
	LEA  EAX, [S66]
	CALL F21 ; ztype
	JMP  RETfromEBP

;================== data =====================
segment readable writeable

; code: 10000 entries, 519 used
; heap: 5000 bytes, 205 used
; symbols: 1000 entries, 66 used
S45        db "hello world!", 0
S47        db "hello", 0
S53        db "(should print 666)", 0
S55        db "test ztype ...", 0
S62        db "-l3-", 0
S64        db "bye", 0
S66        db "still here? s", 0
I2         rd   1 ; _em
I28        rd   1 ; base
I29        rd   3 ; buf
I30        rd   1 ; #n
I40        rd   1 ; x
A          rd   1
rstk       rd 256
locs       rd 500

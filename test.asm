
format ELF executable
;================== code =====================
segment readable executable
;================== library ==================
start:
	CALL init
	CALL F14 ; main

F1: ; bye
	MOV  EAX, 1
	XOR  EBX, EBX
	INT  0x80

F2: ; puts
	; TODO: fill this in
	CALL RETtoEBP
	MOV  [I5], EAX
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
	; TODO: fill this in
	MOV  [I5], EAX
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

F12: ; Mil
	CALL RETtoEBP
	MOV  EBX, EAX
	MOV  EAX, 1000
	IMUL EAX, EBX
	MOV  EBX, EAX
	MOV  EAX, 1000
	IMUL EAX, EBX
	JMP  RETfromEBP

F13: ; CR
	CALL RETtoEBP
	PUSH EAX
	MOV  EAX, 10
	CALL F3 ; emit
	JMP  RETfromEBP

F14: ; main
	CALL RETtoEBP
	CALL F9 ; T4
	PUSH EAX
	MOV  EAX, 1000
	CALL F12 ; Mil
	MOV  EBX, EAX
	LEA  EAX, [I11] ; x
	MOV  [EAX], EBX
	LEA  EAX, [I11] ; x
	MOV  EAX, [EAX]
	CALL F4 ; .d
	PUSH EAX
	MOV  EAX, 115
	PUSH EAX
	MOV  EAX, 101
	XCHG EAX, [ESP]
	CALL F3 ; emit
	PUSH EAX
	LEA  EAX, [I11] ; x
	MOV  EAX, [EAX]
Tgt2:
	DEC  EAX
	TEST EAX, EAX
	JNZ  Tgt2
	POP  EAX
	CALL F3 ; emit
	CALL F13 ; CR
	PUSH EAX
	LEA  EAX, [S1]
	CALL F2 ; puts
	JMP  RETfromEBP
;================== data =====================
segment readable writeable
;=============================================

; symbols: 500 entries, 15 used
; num type size name
; --- ---- ---- -----------------
I5         dd 0 ; pv
I6         dd 0 ; num
I7         dd 0 ; x
I11        dd 0 ; x
S1         db "- all done!", 0
rstk       rd 256

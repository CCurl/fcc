// Test file for the Linux version
// NOTE: this is nearly identical to twin.fth except emit and bye are sys calls

// output a single character to stdout
// NOS: the char, TOS, addr to store the char
// This uses the Linux syscall #4 - write
// EAX = 4: syscall number
// EBX = 1: stdout
// ECX = address of buffer with chars to output
// EDX is the number of chars to write
: outc ( c a-- ) code
	pop ebx
	mov [eax], bl
	mov edx, 1
	mov ecx, eax
	mov ebx, 1
	mov eax, 4
	int 0x80
	pop eax
end-code
;

var _em
: emit  ( c-- ) _em outc ;

: bye code
	mov eax, 1
	xor ebx, ebx
	int 0x80
end-code
;

: @a  a@ @ ;				: !a  a@ ! ;
: @a+ @a  a@ 4 + a! ;		: !a+ !a  a@ 4 + a! ;
: @a- @a  a@ 4 - a! ;		: !a- !a  a@ 4 - a! ;

: c@a   a@ c@ ;				: c!a   a@ c! ;
: c@a+  c@a  a+ ;			: c!a+  c!a  a+ ;
: c@a-  c@a  a- ;			: c!a-  c!a  a- ;

: +L +locs a@ l0 ! ;
: -L l0 @  a! -locs ;

: 0= if 0 exit then 1 ;
: ztype ( a-- ) +L  a!
	begin
		c@a+ dup 0= 
		if drop -L exit then
		emit
	again ;


: Mil ( n--m ) 1000 dup * * ;
: cr 10 emit ;
: space 32 emit ;
: negate 0 swap - ;

var base
var buf 3 allot
var #n
: (.) ( n -- )
	+L #n a! 0 dup c!a- c!a-
	dup 0 < if 1 #n c! negate then
	begin
		base @ /mod swap '0' + 
		dup '9' > if 7 + then
		c!a- dup
	while drop
	#n c@ if '-' c!a- then
	a@ 1+ ztype -L ;
: . (.) space ;

: strlen ( a -- n )
	dup c@ 0= if drop 0 exit then
	+locs  a@ l3 !  dup a! l1 !
	begin c@a+ while
	a@ l1 @ - 1-  l3 @ a!  -locs ;

var x
: x++  x @ 1+ x ! ;
: x+4  x @ 4 + x ! ;

: t0 cr 't' emit . ;
: t1   1 t0 s" hello world!" ztype ;
: t2   2 t0 1234 s" hello" strlen . . ;
: t3   3 t0 'a' _em outc ;
: t4   4 t0 0= if 'n' emit exit then 'y' emit ;
: t5   5 t0 buf a! 'h' c!a+ 'i' c!a+ 0 c!a buf ztype space ;
: t6   6 t0 666 222 ->reg2  333 ->reg3  444 ->reg4 . s" (should print 666)" ztype ;
: t7   7 t0 s" test ztype ..." ztype ;
: t8   8 t0 3344 . -3344 . $1234 . 1234 #16 base ! . #10 base ! ;
: t9   9 t0 999 123 100 /mod . . . ;
: t10 10 t0 'g' x c! x c@ dup . emit ;
: t11 11 t0 's' emit 1000 Mil dup (.) begin 1- dup while 'e' emit ;
: t12 12 t0 +locs s" -l3-" l3 ! +locs 17 l3 ! l3 @ . -locs l3 @ ztype -locs ;
: t999 s" bye" ztype cr bye ;

: main
	10 base !
	t1 t2 t3 0 t4 1 t4 t5 t6 t7 t8 t9 t10 t11 t12
	cr t999 cr
	s" still here? s" ztype ;

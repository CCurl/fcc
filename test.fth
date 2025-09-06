var base

var (a)
: a@ (a) @ ;
: a! (a) ! ;

// : @a  a@ @ ;
// : !a  a@ ! ;
// : @a+ @a  a@ 4 + a! ;
// : !a+ !a  a@ 4 + a! ;
// : @a- @a  a@ 4 - a! ;
// : !a- !a  a@ 4 - a! ;

: c@a   a@ c@ ;
: c!a   a@ c! ;
: c@a+  c@a  a@ 1+ a! ;
: c!a+  c!a  a@ 1+ a! ;
: c@a-  c@a  a@ 1- a! ;
: c!a-  c!a  a@ 1- a! ;

var _em
: emit    _em c!  0 ->reg2  _em ->reg3  1 ->reg4  4 sys ;
: bye   0 ->reg2 1 sys ;

var _zt
: ztype ( a-- ) a@ _zt !  a!
	begin
		c@a+ dup 0 = 
		if drop _zt @ a! exit then
		emit
	again ;

: 0= 0 = ;

: Mil ( n--m ) 1000 dup * * ;
: cr 10 emit ;
: space 32 emit ;
: negate 0 swap - ;

var buf var _b var _b var #n var _dot
: (.) ( n -- )
	a@ _dot ! #n a! 0 dup c!a- c!a-
	dup 0 < if 1 #n c! negate then
	begin
		base @ /mod swap '0' + c!a-
	while drop
	#n @ if '-' c!a- then
	a@ 1+ ztype _dot @ a! ;
: . (.) space ;

var x
: t0 cr 't' emit . ;
: t1  " hello" ztype ;
: t4   4 t0 dup 0= if 'y' emit exit then 'n' emit ;
: t5   5 t0 buf a! 'h' c!a+ 'i' c!a+ 0 c!a buf ztype space ;
: t6   6 t0 666 222 ->reg2  333 ->reg3  444 ->reg4 . ;
: t7   7 t0 " test ztype ..." ztype ;
: t8   8 t0 3344 . -3344 . ;
: t9   9 t0 999 123 100 /mod . . . ;
: t10 10 t0 'g' x c! x c@ dup . emit ;
: t11 11 t0 's' emit 1000 Mil dup (.) begin 1- while drop 'e' emit ;
: t999 "  bye" ztype cr bye ;

: main
	10 base !
	t1 0 t4 1 t4 t5 t6 t7 t8 t9 t10 t11
	t999
	" still here? " ztype
;

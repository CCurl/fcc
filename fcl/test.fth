var base 

: @a  a@ @ ;				: !a  a@ ! ;
: @a+ @a  a@ 4 + a! ;		: !a+ !a  a@ 4 + a! ;
: @a- @a  a@ 4 - a! ;		: !a- !a  a@ 4 - a! ;

: c@a   a@ c@ ;				: c!a   a@ c! ;
: c@a+  c@a  a+ ;			: c!a+  c!a  a+ ;
: c@a-  c@a  a- ;			: c!a-  c!a  a- ;

: +l +locs a@ l0 ! ;
: -l l0 @  a! -locs ;

var _em
: emit  ( c-- ) _em c! _em ->reg3  0 ->reg2  1 ->reg4  4 sys ;
: bye   0 ->reg2 1 sys ;

: ztype ( a-- ) +l  a!
	begin
		c@a+ dup 0 = 
		if drop -l exit then
		emit
	again ;

: 0= 0 = ;

: Mil ( n--m ) 1000 dup * * ;
: cr 10 emit ;
: space 32 emit ;
: negate 0 swap - ;

var buf 3 allot
var #n
: (.) ( n -- )
	+l #n a! 0 dup c!a- c!a-
	dup 0 < if 1 #n c! negate then
	begin
		base @ /mod swap '0' + 
		dup '9' > if 7 + then
		c!a- dup
	while drop
	#n c@ if '-' c!a- then
	a@ 1+ ztype -l ;
: . (.) space ;

: strlen ( a -- n )
	dup c@ 0= if drop 0 exit then
	+locs  a@ l3 !  dup a! l1 !
	begin c@a+ while
	a@ l1 @ - 1-  l3 @ a!  -locs ;

var x
: t0 cr 't' emit . ;
: t1   1 t0 s" hello world!" ztype ;
: t2   2 t0 1234 s" hello" strlen . . ;
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
	t1 t2 0 t4 1 t4 t5 t6 t7 t8 t9 t10 t11 t12
	cr t999 cr
	s" still here? s" ztype ;

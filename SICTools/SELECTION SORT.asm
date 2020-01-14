.================================================================ 입력 부분.
.배열의 첫 주소를 저장하기 위해 사용한다.	
INSER	LDA	ARRAY .array의 첫 주소를 x에 넣어준다. 
	STA	INDEXI
	STA	FIRST .x값을 INDEX의 메모리에 넣어준다.
	STA	INDEX .x 의 첫번째 주소 값을 넣어준다. 
	STA	INDEX2.x 의 첫번쨰 주소 값을 넣어준다.
	
	LDX	FIRST .배열의 첫번째 주소값을 X register에 넣어준다.

	J	INPUT .INPUT으로 넘어간다

.입력받은 것이 EOF, space, 숫자인지를 확인한다.
 
INPUT	CLEAR	A .쌓이는 것을 방지하기 위해 사용한다.
	RD	STDIN .A register에 입력 받는다.

	COMP	CHE .'E'인지 확인을 한다.
	JEQ	CHEO .sorting으로 간다 입력이 끝이 날 경우 sorting을 위해 SERIN으로 간다.
	JGT	STOP
	COMP	UP
	JGT	STOP
	
	
	COMP	SPACE .'space' 인지를 확인한다. 
	JEQ	INSPC . input 값이 space인 경우 
	
	COMP	ZERO2
 	JGT	INNUM . input 값이 숫자 EOF도 아니고 빈칸도 아니기 때문에 INNUM으로 간다.
 
.숫자를 입력받았을 때 실행되는 함수.

CHEO	CLEAR	A
	RD	STDIN
	COMP	CHO
	JEQ	CHEF
	JGT	STOP
	JLT	STOP

CHEF	CLEAR	A
	RD	STDIN
	COMP	CHF
	JEQ	SERIN
	JGT	STOP
	JLT	STOP

INNUM	SUB	ZERO .입력 받은 것 -0를 해준다.
	STA	TEMP .입력받은 숫자를 temp에 저장해둔다.
  	
	LDA	ARRAY,X .10의 자리 이상의 숫자를 받을 때 사용. 
	MUL	TEN2 .원래 있던 배열에 *10을 해준다.
	ADD	TEMP .입력받은 숫자 + 배열의 숫자
	
	STA	ARRAY,X .x의 위치에 A register 값을 넣어준다.

	J	INPUT .다시 입력받는 곳으로 간다.
 
.space가 나올 경우 인덱스만 늘린다.

INSPC	LDX	INDEX
	LDA	ARRAY,X
	COMP	SIBMAN
	JGT	STOP
	
	LDA	INDEX .A레지스터에 index값을 넣어준다.
	ADD	THREE .3을 더해준다.
	
	SUB	FIRST
	COMP	NINE
	JEQ	STOP

	STA	INDEX .A 레지스터의 값을 다시 알파에 넣어준다.
	STA	INDEXI . INDEXI의 값을 계속 3 더해 준다.
	LDX	INDEX .X register의 값을 갱신해준다.

	J	INPUT .다시 입력받는 곳으로 돌아간다.

.================================================================ sorting.	

SERIN	LDA	FIRST
	STA	INTI
	STA	INTI2

	ADD	THREE
	STA	INTJ

	LDA	INDEXI
	SUB 	THREE
	STA	INDEXI

	LDX	INTI
	LDA	ARRAY,X
	STA	TEMP4 .제일 앞에 있는 것을 temp4에다 넣는다.

	LDA	INTJ

	J	LOOP


PLUS	LDA	INTI
	ADD	THREE	
	STA	INTI
	STA	INTI2

	LDX	INTI
	LDA	ARRAY,X
	STA	TEMP4

	LDA	INTI
	ADD	THREE
	STA	INTJ

	LDA	INTI
	COMP	INDEXI
	JGT	STOP	.범위를 벗어나면 종료.	

	J	LOOP

	
LOOP	COMP	INDEXI
	JGT	CHEFI . 끝까지 다 봤을 경우  

	LDX	INTJ . 그 init2의 인덱스 값을 넣어준다.
	LDA	ARRAY,X	.그 init2값을 넣는다.
	STA	TEMP5 . 

	COMP	TEMP4 . 다시 그 전의 것과 비교한다.
	JLT	SWAP
	
	J 	PPP

PPP	LDA	INTJ
	ADD	THREE
	STA	INTJ
	
	J	LOOP

. TEMP4의 값과 INIT2의 값을 갱신해준다.
SWAP	LDA	INTJ
	STA	INTI2

	LDA	TEMP5	
	STA	TEMP4
	
	LDA	INTJ
	ADD	THREE . 그 다음 것과 비교하기 위해 사용한다.
	STA	INTJ

	J	LOOP
	
.================================================== 최솟값을 찾아냈다.
.INTI2에 최소값 인덱스 TEMP에 최솟값이 들어있다.

CHEFI	LDA	INTI2	
	SUB	THREE
	COMP	FIRST
	JEQ	PLUS
	J	LOOP2

LOOP2	LDA	INTI2 . 
	SUB	THREE
	STA	INTJ

	LDA	INTJ
	COMP	FIRST
	JLT	SWAP2

	LDX	INTJ . 그 init2의 인덱스 값을 넣어준다.
	LDA	ARRAY,X	.그 init2값을 넣는다.
	STA	TEMP5 . 
	
	COMP	TEMP4 . 다시 그 전의 것과 비교한다.
	JGT	SWAP3
	J	SWAP2

SWAP3	LDA	TEMP5
	LDX	INTI2
	STA	ARRAY,X

	LDA	INTI2
	SUB	THREE
	STA	INTI2

	J	LOOP2
	

SWAP2	LDA	INTJ
	ADD	THREE
	STA	INTJ

	LDX	INTJ
	LDA	TEMP4
	STA	ARRAY,X
	
	J	OUTSTA

.================================================================ 출력 부분.

OUTSTA	LDX	FIRST .x에다 array 처음 넣어준다
	LDA	ENTER
	WD	STDOUT
	STX	INDEX2
	J 	OUTPUT

OUTPUT	LDX	INDEX2
	LDA	ARRAY,X .ARRAY의 X위치의 값을 A register에 넣어준다.
	COMP	NOTIN
	JEQ	PLUS
	J	OUTPUT1


OUTPUT1	COMP	MAN .10000보다 클 경우
	JGT	MAN1 .MAN1 에 들어가서 수행되고 다시 돌아온다.

	COMP	THOU .1000보다 클 경우
	JGT	THOU1 .THOW1 에 들어가서 수행되고 다시 돌아온다.

	COMP	HUN .100보다 클 경우
	JGT	HUN1 .HUN1 에 들어가서 수행되고 다시 돌아온다.

	COMP	TEN .10보다 클 경우
	JGT	TEN1 .TEN1 에 들어가서 수행되고 다시 돌아온다.

	ADD	ZERO
	WD	STDOUT

	LDA	SPACE
	WD	STDOUT .공백까지 출력하고 
	
	LDA	INDEX2
	ADD	THREE
	STA	INDEX2
	
	J	OUTPUT

MAN1	STA	TEMP2 .A register에 있는 값을 temp2에다 넣어준다.
	DIV	MAN2 .만의 자리만 남겨둔다.
	ADD	ZERO
	WD	STDOUT .만의 자리 출력.
	SUB	ZERO

	MUL	MAN2 .
	STA	TEMP3	

	LDA	TEMP2
	SUB	TEMP3

	
	J	THOU1
	
THOU1 	STA	TEMP2 .A register에 있는 값을 temp2에다 넣어준다.
	DIV	THOU2 .천의 자리만 남겨둔다.
	ADD	ZERO
	WD	STDOUT .천의 자리 출력
	SUB	ZERO

	MUL	THOU2 .
	STA	TEMP3

	LDA	TEMP2
	SUB	TEMP3
	
	J	HUN1

HUN1	STA	TEMP2 .A register에 있는 값을 temp2에다 넣어준다.
	DIV	HUN2 .만의 자리만 남겨둔.
	ADD	ZERO
	WD	STDOUT .백의 자리 
	SUB	ZERO

	MUL	HUN2 .
	STA	TEMP3

	LDA	TEMP2
	SUB	TEMP3
	
	J	TEN1

TEN1	STA	TEMP2 .A register에 있는 값을 temp2에다 넣어준다.
	DIV	TEN2 .만의 자리만 남겨둔다.
	ADD	ZERO
	WD	STDOUT .만의 자리 출력.
	SUB	ZERO

	MUL	TEN2 
	STA	TEMP3

	LDA	TEMP2
	SUB	TEMP3
	
	J	OUTPUT1
	
STOP	J	STOP .프로그램을 종료하는데 사용한다.




ARRAY	RESW	9 .배열 크기.
	
STDIN	BYTE 	0 .입력 받을 때 사용 
STDOUT	BYTE	1 .출력할 때 사용.

FIRST	RESW	1 .배열의 첫 주소를 가지고 있다.


TEMP	RESW	1 . 입력에 사용하는 임시 변수.
 
TEMP2	RESW	1 . 출력에 사용하는 임시 변수
TEMP3	RESW	1 . 출력에 사용하는 임시 변수

TEMP4 	RESW	1
TEMP5 	RESW	1

INDEXI	RESW	1
INDEXJ  RESW	1

INTI 	RESW	1 .i번째 인덱스를 나타낸다. 처음 포문
INTI2 	RESW	1
INTJ	RESW	1 .j 인덱스를 나타낸다. 두번째 포문



INDEX	RESW	1 .배열에 값을 넣을 때 사용하는 index

INDEX2	RESW	1 .출력에 사용하는 index

NOTIN	WORD	0
ENTER	WORD	10

SPACE	WORD	0x20

UP	WORD	0x3A
ZERO2	WORD	0x2F
ZERO	WORD	0x30

CHE	WORD	0x45
CHO	WORD	0x4F
CHF	WORD	0x46


MAN	WORD	9999 .10000을 의미
THOU	WORD	999 .1000을 의미
HUN	WORD	99 .100을 의미
TEN	WORD	9 .원래 있던 수에 10을 곱할 때 사용한다.

NINE	WORD	27
SIBMAN	WORD	99999
MAN2	WORD	10000
THOU2	WORD	1000
HUN2	WORD	100
TEN2	WORD 	10

THREE	WORD	3 .다음 index에 접근할 때 사용한다.


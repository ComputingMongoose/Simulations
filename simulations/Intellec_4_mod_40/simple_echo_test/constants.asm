; useful Intel 4004 4040 equates for instruction mnemonics HRJ Jul 26 2020
; thanks also to Dwight Elvey in 2019 and 2020

;register pairs - A04 assembler assumes 0-7 values to designate pairs
; In the A04 assembler, instructions SRC JIN FIN FIM, assume a value 
; only 0 through 7 inclusive; otherwise it's an error. That value if acceptable,
; becomes three bits, which are inserted into the appropriate three bits
; of one of those instructions, to complete the instruction code value. 

R01	EQU	00
R23	EQU	01
R45	EQU	02
R67	EQU	03
R89	EQU	04
RAB	EQU	05
RCD	EQU	06
REF	EQU	07

R0R1	EQU	00
R2R3	EQU	01
R4R5	EQU	02
R6R7	EQU	03
R8R9	EQU	04
RARB	EQU	05
RCRD	EQU	06
RERF	EQU	07

r0r1	EQU	00
r2r3	EQU	01
r4r5	EQU	02
r6r7	EQU	03
r8r9	EQU	04
rarb	EQU	05
rcrd	EQU	06
rerf	EQU	07

; The Intel MCS-04 manual says its assembler supports the following symbols
; but wants EVEN values 0 2 4 6 .. 14 for these register pairs symbols.
; I've assigned them values consistent with A04 as noted above.

P0	EQU	00
P1	EQU	01
P2	EQU	02
P3	EQU	03
P4	EQU	04
P5	EQU	05
P6	EQU	06
P7	EQU	07

;single resister symbols. A04 only accepts 0-15 for a single register value.

R0	EQU	0
R1	EQU	1
R2	EQU	2
R3	EQU	3
R4	EQU	4
R5	EQU	5
R6	EQU	6
R7	EQU	7
R8	EQU	8
R9	EQU	9
RA	EQU	10
RB	EQU	11
RC	EQU	12
RD	EQU	13
RE	EQU	14
RF	EQU	15

r0	EQU	0
r1	EQU	1
r2	EQU	2
r3	EQU	3
r4	EQU	4
r5	EQU	5
r6	EQU	6
r7	EQU	7
r8	EQU	8
r9	EQU	9
ra	EQU	10
rb	EQU	11
rc	EQU	12
rd	EQU	13
re	EQU	14
rf	EQU	15

;JCN condition codes (JCN NC addr, etc.) A04 accepts a value 0-15.
;these symbols courtesy Dwight Elvey

T0	EQU	$1 ;test = 0
C	EQU	$2 ;carry = 1
CT0	equ	$3 ; carry = 1 or test = 0
Z	EQU	$4 ; acc = 0
ZT0	EQU	$5 ; acc=0 or test = 0
ZC	EQU	$6 ; acc= 0 or carry = 1
ZCT0	EQU	$7 ; acc=0 or carry = 1 or test = 0
NT0	EQU	$9 ; Test = 1
NC	EQU	$A ; carry = 0
NCT0	EQU	$B ; not  ( carry = 1 or is test = 0 )
NZ	EQU	$C ; acc <> 0
NZT0	EQU	$D ; not ( acc = 0 or test = 0 )
NZC	EQU	$E ; not ( acc=0 or carry = 1 )
NZCT0	EQU	$F ; not ( acc=0 or carry=1 or test=0 )
; JCN 0 -> jump never, JCN 8 -> jump always

t0	EQU	$1 ;test = 0
c	EQU	$2 ;carry = 1
ct0	equ	$3 ; carry = 1 or test = 0
z	EQU	$4 ; acc = 0
zt0	EQU	$5 ; acc=0 or test = 0
zc	EQU	$6 ; acc= 0 or carry = 1
zct0	EQU	$7 ; acc=0 or carry = 1 or test = 0
nt0	EQU	$9 ; Test = 1
nc	EQU	$A ; carry = 0
nct0	EQU	$B ; not  ( carry = 1 or is test = 0 )
nz	EQU	$C ; acc <> 0
nzt0	EQU	$D ; not ( acc = 0 or test = 0 )
nzc	EQU	$E ; not ( acc=0 or carry = 1 )
nzct0	EQU	$F ; not ( acc=0 or carry=1 or test=0 )


;alternative JCN condition codes

ZAC  EQU $4  ;jump on zero accum  
NZAC EQU $C  ;jump on not zero accum
ZCY  EQU $A  ;jump on zero carry 
NZCY EQU $2  ;jump on not zero carry
ZTS  EQU $1  ;jump on zero test   
NZTS EQU $9  ;jump on not zero test



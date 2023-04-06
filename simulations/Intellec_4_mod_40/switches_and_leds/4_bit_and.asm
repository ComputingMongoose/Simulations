; From SIM4-02 Hardware Simulator
; http://bitsavers.informatik.uni-stuttgart.de/components/intel/MCS4/SIM4-02_Hardware_Simulator_Dec72.pdf

	RPAIRS    "ZERO7"
	ORG     0h

; FOUR BIT "AND" ROUTINE
START	FIM	4,0		; LOAD ROM PORT 0 ADDRESS
	SRC	4		; SEND ROM PORT ADDRESS
	RDR			; READ INPUT A
	XCH	0		; A TO REGISTER 0
	INC	8		; LOAD ROM PORT 1 ADDRESS
	SRC	4		; SEND ROM PORT ADDRESS
	RDR			; READ INPUT B
	XCH	1		; B TO REGISTER
	JMS	ANDSUB		; EXECUTE "AND"
	XCH	2		; LOAD RESULT C
	WMP			; STORE AT MEMORY PORT 0
	JUN	START		; RESTART
	NOP

ANDSUB	CLB			; CLEAR ACCUMULATOR AND CARRY
	XCH	2		; CLEAR REGISTER 2
	LDM	4		; LOAD LOOP COUNT (LC)
	XCH	0		; LOAD A, LC TO REGISTER 0
	RAR			; ROTATE LEAST SIGNIfICANT BIT TO CARRY
	XCH	0		; RETURN ROTATED A TO REG 0# LC TO ACC.
	JNC	ROTR1	; JUMP TO ROTR1 If CARRY ZERO
	XCH	1		; LOAD B. LC TO ACCUMULATOR
	RAR			; ROTATE LEAST SIGNIfICANT BIT TO CARRY
	XCH	1		; RETURN ROTATED B TO REG. 1. LC TO ACC.
ROTR2	XCH	2		; LOAD PARTIAL RESULT C. LC TO REGISTER 2
	RAR			; ROTATE CARRY INTO PARTIAL RESULT MSB
	XCH	2		; LOAD LC. RETURN C TO REGISTER 2
	DAC			; DECREMENT THE ACCUMULATOR (LC)
	JNZ	ANDSUB+3	; LOOP IF LC NON ZERO
	BBL	0		; RETURN
ROTR1	XCH	1		; LOAD B. LC TO REGISTER 1
	RAR			; ROTATE B
	XCH	1		; RETURN ROTATED B TO REG. 1 LC TO ACC.
	CLC			; CLEAR CARRY
	JUN	ROTR2		; RETURN TO LOOP

	END	START
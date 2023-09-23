; Changes for assembling with MacroAssembler AS 1.42Beta
; - remove "$" before TITLE
; - change NOT with ~
; - replace OR with |
; - replace NOT INT7 with NOTINT7 and manually create the symbol
;
; change MONCHK to 2B instead of 1E
; change BOOSUM to 32 instead of A3
;
		;$       TITLE    ('INTELLEC SERIES II IPB DIAGNOSTIC')
		       TITLE    "INTELLEC SERIES II IPB DIAGNOSTIC"
		
		;       EQUATES
		
		;       CHECKSUM DEFINITIONS
		
MONORG  EQU     0F800H          ;MONITOR ROM ORIGIN
MONLEN  EQU     0800H           ;MONITOR ROM LENGTH
MONCHK  EQU     02BH            ;MONITOR ROM CHECKSUM
		
BOOORG  EQU     0E800H          ;BOOT ROM ORIGIN     
BOOLEN  EQU     0800H           ;BOOT ROM LENGTH    
BOOCHK  EQU     055H            ;BOOT ROM CHECKSUM     
BOOSUM  EQU     088H            ;BOOT ROM CHECKSUM BYTE CONTENTS (TO MAKE 55H)
		
		;       GENERAL DEFINITIONS
		
CR      EQU     0DH             ;CARRIAGE RETURN CHARACTER
LF      EQU     0AH             ;LINE FEED CHARACTER
INT7V   EQU     038H            ;INTERRUPT 7 VECTOR LOCATION
		
		;       PIC DEFINITIONS
		
SPICMR  EQU     0FCH            ;SYSTEM PIC MASK REGISTER
IPICMR  EQU     0FAH            ;IO PIC MASK REGISTER
SPICCR  EQU     0FDH            ;SYSTEM PIC COMMAND REGISTER
IPICCR  EQU     0FBH            ;IO PIC COMMAND REGISTER
EOI     EQU     20H             ;END OF INTERRUPT COMMAND
POLL    EQU     0CH             ;POLL COMMAND
		
		;       IOC AND PIO COMMAND DEFFINITIONS
		
CSMEM   EQU     01000B          ;CHECKSUM MEMORY COMMAND
DECHO   EQU     00111B          ;DATA ECHO COMMAND
SRQ     EQU     00110B          ;GENERATE INTERRUPT COMMAND
SRQACK  EQU     00101B          ;INTERRUPT ACKNOWLEDGE COMMAND
TRAM    EQU     01001B          ;TEST RAM COMMAND
		
		;       THINGS ALREADY DEFINED IN THE MONITOR
		
OBF     EQU     00000001B       ;SLAVE OUTPUT BUFFER IS FULL
IBF     EQU     00000010B       ;SLAVE INPUT BUFFER IS FULL
F0      EQU     00000100B       ;FLAG 0 - SAVE BUSY, MASTER LOCKED OUT
		
IOCI    EQU     0C0H            ;IOC INPUT DATA (FROM DBB) PORT
IOCO    EQU     0C0H            ;IOC OUTPUT DATA (TO DBB) PORT
IOCS    EQU     0C1H            ;IOC STATUS PORT
IOCC    EQU     0C1H            ;IOC COMMAND PORT
		
PIOI    EQU     0F8H            ;PIO INPUT DATA (FROM DBB) PORT
PIOO    EQU     0F8H            ;PIO OUTPUT DATA (TO DBB) PORT
PIOS    EQU     0F9H            ;PIO STATUS PORT
PIOC    EQU     0F9H            ;PIO COMMAND PORT
		
INT5    EQU     00100000B       ;INTERRUPT LEVEL 5
INT6    EQU     01000000B       ;INTERRUPT LEVEL 6
INT7    EQU     10000000B       ;INTERRUPT LEVEL 7
NOTINT7    EQU     01111111B       ;INTERRUPT LEVEL 7
		
CO      EQU     0F809H          ;CO MONITOR FUNCTION
MEMCHK  EQU     0F81BH          ;MEMCHK MONITOR FUNCTION
		
		;       GLOBALS
		
FFLAG   EQU     010H            ;MAJOR TEST FAILURE FLAG
		                                ;   0 = NO FAILURES IN TEST
		                                ;   0FFH = TEST HAS FAILED
TOFLAG  EQU     011H            ;TIMEOUT FLAG
		                                ;   0 = NO TIMEOUT
		                                ;   0FFH = TIMEOUT HAS OCCURRED
		
		;       ENTRY POINTS
		
        ORG     0EB00H          ;BEGINNING OF DIAGNOSTIC
        JMP     MIMODE          ;MONITOR'S ENTRY POINT
        JMP     BIMODE          ;BOOT ENTRY POINT
		
		;$ EJECT
		;;;     BIMODE - BOOT INVOKED MODE CONTROL ROUTINE
		
BIMODE: CALL    INIT            ;SAVE ENVIRONMENT
        CALL    CHKSUM          ;CHECKSUM ROMS
		
        MVI     C,55H           ;CHECK FOR IOC PRESENCE
        CALL    IOCDRA
        LXI     H,TOFLAG        ;TEST TIME OUT FLAG
	        ORA     M               ;AND RESULT FLAG
        CZ      IOCTST          ;RUN THE IOC TEST IF IOC PRESENT
        MVI     A,0             ;RESET TIMEOUT FLAG
        STA     TOFLAG
		
        CALL    PIOTST          ;RUN THE PIO TEST
		
        CALL    RESTOR          ;RESTORE THE ENVIRONMENT
	        RET                     ;RETURN TO THE BOOT
		
		;;;     MIMODE - MONITOR INVOKED MODE CONTROL ROUTINE
		
MIMODE: CALL    INIT            ;SAVE ENVIRONMENT
        LXI     B,SIGNON        ;PRINT SIGN ON MESSAGE
        CALL    PRINTL
		
		;       CHECKSUM ROMS
		
        LXI     B,MIMI          ;'CHECKSUM TEST' MESSAGE
        CALL    SETUP           ;PRINT MESSAGE AND INITIALIZE FFLAG
        CALL    CHKSUM          ;CHECKSUM ROMS
        CALL    FINISH          ;CHECK FFLAG
		
		;       TEST IOC
		
        LXI     B,MIM2          ;'IOC TEST' MESSAGE
        CALL    SETUP           ;PRINT MESSAGE AND INITIALIZE FFLAG
        CALL    IOCTST          ;TEST IOC
        CALL    FINISH          ;CHECK FFLAG
		
		;       TEST PIO
		
        LXI     B,MIM3          ;'PIO TEST' MESSAGE
        CALL    SETUP           ;PRINT MESSAGE AND INITIALIZE FFLAG
        CALL    PIOTST          ;TEST PIO
        CALL    FINISH          ;CHECK FFLAG
		
		;       TEST RAM
		
        LXI     B,MIM4          ;'RAM TEST' MESSAGE
        CALL    SETUP           ;PRINT MESSAGE AND INITIALIZE FFLAG
        CALL    RAMTST          ;TEST RAM
        CALL    FINISH          ;CHECK FFLAG
		
		;       RETURN TO MONITOR
		
        LXI     B,SGNOFF        ;SIGNOFF MESSAGE
        CALL    PRINTL
        CALL    RESTOR          ;RESTORE ENVIRONMENT
	        RET                     ;RETURN TO MONITOR
		
		;$       TITLE   ('CHKSUM - CHECKSUM TEST')
		        TITLE   "CHKSUM - CHECKSUM TEST"
		;$       EJECT
		;;;     CHKSUM - CHECKSUM ROMS
		
		CHKSUM:
        LXI     H,MONORG        ;SET UP TO CHECKSUM MONITOR
        LXI     D,MONLEN
        MVI     A,MONCHK
        CALL    SUM             ;CHECKSUM MONITOR
        LXI     B,CHKM1         ;'MONITOR CHECKSUM' MESSAGE
        CALL    TEST
		
        LXI     H,BOOORG        ;SET UP TO CHECKSUM BOOT
        LXI     D,BOOLEN
        MVI     A,BOOCHK
        CALL    SUM             ;CHECKSUM BOOT
        LXI     B,CHKM2         ;'BOOT CHECKSUM' MESSAGE
        CALL    TEST
	        RET
		
		;;;     SUM - CHECKSUM MEMORY
		;
		;       PARAMETERS:
		;           HL = ORIGIN OF ROM TO BE CHECKSUMMED
		;           DE = LENGTH OF ROM
		;           A = EXPECTED CHECKSUM
		;
		;       RETURNS:
		;           A = SUCCESS FLAG
		;               0 = CHECKSUM OK
		;               0FFH = CHECKSUM FAILED
		
	SUM:    CMA                     ;TAKE TWO'S COMPLEMENT OF EXPECTED CHECKSUM, SO
	        INR     A               ;WHEN ADDED TO CHECKSUM THE TOTAL WILL BE ZERO
		
	SUM1:   MOV     B,A             ;SAVE SUM DURING TEST
	        MOV     A,E             ;TEST FOR NONE LEFT
	        ORA     D
        JZ      SUM2            ;IF NONE LEFT
	        MOV     A,B             ;PUT COUNT BACK
	        ADD     M               ;ACCUMULATE SUM
	        INX     H               ;STEP TO NEXT WORD
	        DCX     D               ;DECREMENT COUNT
        JMP     SUM1            ;LOOP
		SUM2:
	        MOV     A,B             ;GET SUM
	        ORA     A               ;TEST FOR ZERO SUM
	        RZ                      ;IF ZERO, RETURN SUCCESS
		
        MVI     A,0FFH          ;RETURN FAILURE
	        RET
		
		;$       TITLE   ('IOCTST - IOC TEST')
		       TITLE   "IOCTST - IOC TEST"
		;$       EJECT
		;;;     IOCTST - IOC TEST
		
		IOCTST:
		
		;       ECHO TEST
		
        MVI     C,55H           ;TRY TO ECHO A 55H
        CALL    IOCDRA
        LXI     H,TOFLAG        ;TEST THE RESULT AND TIME-OUT FLAGS
	        ORA     M
        JZ      IOC1            ;JUMP IF OK
        LXI     B,IOCM1         ;FAILURE MESSAGE
        CALL    TEST
	        RET                     ;DO NOT DO OTHER TESTS IF NOT PRESENT
		
		;       IOC CHECKSUM TEST
		
IOC1:   MVI     B,CSMEM         ;CHECKSUM COMMAND
        CALL    IOCDRB
        LXI     B,IOCM2
        CALL    TEST
		
		;       IOC RAM TEST
		
        MVI     B,TRAM          ;TEST RAM COMMAND
        CALL    IOCDRB
        LXI     B,IOCM3
        CALL    TEST
		
		;       IOC INTERRUPT TEST
		
        MVI     C,~ INT6      ;SET UP MASKS
        CALL    SETINT
        MVI     B,SRQ           ;TURN ON IOC INTERRUPT
        CALL    IOCDRC
        CALL    CHKINT          ;CHECK INTERRUPTS
	        PUSH    PSW             ;SAVE RESULT
        MVI     B,SRQACK        ;RESET IOC INTERRUPT
        CALL    IOCDRC
        CALL    RESET           ;RESTORE INTERRRUPTS TO NORMAL
		
	        POP     PSW             ;GET RESULT FLAG
        LXI     B,IOCM4         ;LOAD MESSAGE POINTER
        CALL    TEST
	        RET
		
		;;;     IOCDRA - ECHO TEST DRIVER
		;
		;       IOCDRA RUNS AN ECHO TEST WITH THE VALUE SUPPLIED, AND RETURNS THE
		;       SUCCESS FLAG IN A.
		;
		;       PARAMETER:
		;           C = DATA TO BE ECHOED
		;
		;       RETURNS:
		;           A = SUCCESS FLAG
		;               0 = PASSED
		;               0FFH - FAILED
		;
		;       CALLS:
		;           IOCCOD
		;           IOCDID
		;           IOCDOD
		
IOCDRA: MVI     B,DECHO         ;PUT OUT DATA ECHO COMMAND
        CALL    IOCCOD
        CALL    IOCDOD
        CALL    IOCDID          ;READ BACK DATA
	        CMA                     ;RETURNS COMPLEMENT
	        SUB     C               ;CHECK IF ECHO EQUALS ORIGINAL
	        RZ                      ;RETURN IF OK
        MVI     A,0FFH          ;OTHERWISE, RETURN FAILURE
	        RET
		
		;;;     IOCDRB - ISSUE COMMAND AND READ DATA
		;
		;       PARAMETER:
		;           B = COMMAND
		;
		;       RETURNS:
		;           A = DATA
		;
		;       CALLS:
		;           IOCCOD
		;           IOCDID
		
IOCDRB: CALL    IOCCOD          ;PUT OUT COMMAND
        CALL    IOCDID          ;READ DATA
	        RET
		
		;;;     IOCDRC - ISSUE COMMAND
		;
		;       PARAMETER:
		;           B = COMMAND
		;
		;       CALLS:
		;           IOCCOD
		
		;IOCDRC  EQU     IOCCOD          ;THIS IS JUST THE COMMAND OUT DRIVER
		                                ;NOTE: ACTUAL DEFINITION FOLLOWS IOCCOD
		
		;;;     IOCCOD - IOC COMMAND OUT DRIVER
		;
		;       PARAMETER:
		;           B = COMMAND
		;
		;       MODIFIES A,B,E,HL
		
IOCCOD: MVI     E,0             ;TEST FOR ZERO STATUS
        CALL    IOCWT           ;WAIT FOR STATUS OR TIMEOUT
	        MOV     A,B             ;OUTPUT COMMAND
        OUT     IOCC
	        RET
		
IOCDRC  EQU     IOCCOD          ;DEFINITION HERE DUE TO FORWARD REFERENCE
		
		;;;     IOCDID - IOC DATA IN DRIVER
		;
		;       RETURNS:
		;           A = DATA
		;
		;       MODIFIES A,E,HL
		
IOCDID: MVI     E,OBF           ;TEST FOR OBF STATUS
        CALL    IOCWT
        IN      IOCI            ;READ DATA
	        RET
		
		;;;     IOCDOD - IOC DATA OUT DRIVER
		;
		;       PARAMETER:
		;           C = DATA
		;
		;       MODIFIES A,E,HL
		
IOCDOD: MVI     E,0             ;TEST FOR ZERO STATUS
        CALL    IOCWT           ;WAIT FOR READY STATUS
	        MOV     A,C             ;WRITE DATA
        OUT     IOCO
	        RET
		
		;;;     IOCWT - IOC WAIT
		;           IOCWT WILL WAIT FOR THE IOC STATUS TO BE EQUAL TO REG. E,
		;       OR TO TIMEOUT
		;
		;       PARAMETERS:
		;           E = STATUS DESIRED
		;
		;       RETURNS:
		;           TOFLAG UPDATED TO 0FFH IF TIMEOUT HAS OCCURED
		
IOCWT:  LXI     H,01000H        ;WAIT COUNT
IOCWT1: IN      IOCS            ;CHECK STATUS
        ANI     F0 | IBF | OBF
	        XRA     E               ;CHECK FOR DESIRED STATUS
	        RZ                      ;RETURN IF OK
	        DCX     H               ;DECREMENT TIMEOUT
	        MOV     A,L             ;TEST FOR TIMED OUT
	        ORA     H
        JNZ     IOCWT1          ;IF NOT TIMED OUT
        MVI     A,0FFH          ;;UPDATE TOFLAG TO FAILURE STATUS
        STA     TOFLAG
	        RET                     ;RETURN
		
		;$       TITLE   ('PIOTST - PIO TEST')
		        TITLE   "PIOTST - PIO TEST"
		;$       EJECT
		
		;;;     PIOTST - PIO TEST
		
		PIOTST:
		
		;       ECHO TEST
		
        MVI     C,55H           ;TRY TO ECHO A 55H
        CALL    PIODRA
        LXI     H,TOFLAG        ;TEST TIME-OUT AND RESULT FLAGS
	        ORA     M
        JZ      PI01            ;IF RESULT OK
        LXI     B,PIOM1         ;FAILURE MESSAGE
        CALL    TEST
	        RET                     ;DO NOT DO OTHER TESTS IF NOT PRESENT
		
		;       PIO CHECKSUM TEST
		
PI01:   MVI     B,CSMEM         ;CHECKSUM COMMAND
        CALL    PIODRB
        LXI     B,PIOM2
        CALL    TEST
		
		;       PIO RAM TEST
		
        MVI     B,TRAM          ;TEST RAM COMMAND
        CALL    PIODRB
        LXI     B,PIOM3
        CALL    TEST
		
		;       PIO INTERRUPT TEST
		
        MVI     C,~ INT5      ;SET UP MASKS
        CALL    SETINT
        MVI     B,SRQ           ;TURN ON PIO INTERRUPT
        CALL    PIODRC
        CALL    CHKINT          ;CHECK INTERRUPTS
	        PUSH    PSW             ;SAVE RESULT FLAG
        MVI     B,SRQACK        ;RESET PIO INTERRUPT
        CALL    PIODRC
        CALL    RESET           ;RESTORE INTERRRUPTS TO NORMAL
		
	        POP     PSW             ;GET RESULT FLAG
        LXI     B,PIOM4         ;LOAD MESSAGE POINTER
        CALL    TEST
		
	        RET
		
		;;;     PIODRA - ECHO TEST DRIVER
		;
		;           PIODRA RUNS AN ECHO TEST WITH THE VALUE SUPPLIED, AND RETURNS THE
		;       SUCCESS FLAG IN A.
		;
		;       PARAMETER:
		;           C = DATA TO BE ECHOED
		;
		;       RETURNS:
		;           A = SUCCESS FLAG
		;               0 = PASSED
		;               0FFH - FAILED
		;
		;       CALLS:
		;           PIOCOD
		;           PIODID
		;           PIODOD
		
PIODRA: MVI     B,DECHO         ;PUT OUT DATA ECHO COMMAND
        CALL    PIOCOD
        CALL    PIODOD
        CALL    PIODID          ;READ BACK DATA
	        CMA                     ;PIO RETURNS COMPLEMENTED DATA
	        SUB     C               ;CHECK IF ECHO EQUALS ORIGINAL
	        RZ                      ;RETURN IF OK
        MVI     A,0FFH          ;OTHERWISE,RETURN FAILURE
	        RET
		
		;;;     PIODRB - ISSUE COMMAND AND READ DATA
		;
		;       PARAMETER:
		;           B = COMMAND
		;
		;       RETURNS:
		;           A = DATA
		;
		;       CALLS:
		;           PIOCOD
		;           PIODID
		
PIODRB: CALL    PIOCOD          ;PUT OUT COMMAND
        CALL    PIODID          ;READ DATA
	        RET
		
		;;;     PIODRC - ISSUE COMMAND
		;
		;       PARAMETER:
		;           B = COMMAND
		;
		;       CALLS:
		;           PIOCOD
		;PIODRC EQU     PIOCOD          ;THIS IS JUST THE COMMAND OUT DRIVER
		                                ;ACTUAL DEFINITION FOLLOWS PIOCOD
		
		;;;     PIOCOD - PIO COMMAND OUT DRIVER
		;
		;       PARAMETER:
		;          B = COMMAND
		;
		;       MODIFIES A,B,E,HL
		
PIOCOD: MVI     E,0             ;WAIT FOR 0 STATUS
        CALL    PIOWT           ;CALL WAIT ROUTINE
	        MOV     A,B             ;OUTPUT COMMAND
        OUT     PIOC
	        RET
		
PIODRC  EQU     PIOCOD          ;DEFINITION HERE DUE TO FORWARD REFERENCE
		
		;;;     PIODID - PIO DATA IN DRIVER
		;
		;       RETURNS:
		;       A = DATA
		;
		;       MODIFIES A,E,HL
		
PIODID: MVI     E,OBF           ;WAIT FOR OBF STATUS
        CALL    PIOWT           ;WAIT
        IN      PIOI            ;READ DATA
	        RET
		
		;;;     PIODOD - PIO DATA OUT DRIVER
		;
		;       PARAMETER:
		;           C = DATA
		;
		;       MODIFIES A,E,HL
		
PIODOD: MVI     E,0             ;WAIT FOR 0 STATUS
        CALL    PIOWT
	        MOV     A,C             ;WRITE DATA
        OUT     PIOO
	        RET
		
		;;;     PIOWT - PIO WAIT
		;           PIOWT WAITS FOR THE PIO STATUS TO BE EQUAL TO E, OR A TIMEOUT.
		;
		;       PARAMETER:
		;           E = STATUS TO WAIT FOR
		;
		;       RETURNS:
		;           TOFLAG UPDATED TO 0FFH IF A TIMEOUT OCCURS
		;
		;       MODIFIES:
		;           TOFLAG,HL
		
PIOWT:  LXI     H,01000H        ;WAIT COUNT
PIOWT1: IN      PIOS            ;CHECK STATUS
        ANI     F0 | IBF | OBF
	        XRA     E               ;CHECK IF EQUAL TO DESIRED
	        RZ                      ;IF OK
	        DCX     H               ;DECREMENT TIMER
	        MOV     A,L             ;TEST FOR TIMED OUT
	        ORA     H
        JNZ     PIOWT1          ;IF NOT TIMED OUT
        MVI     A,0FFH          ;TIMED OUT; UPDATE TOFLAG
        STA     TOFLAG
	        RET
		
		;$       TITLE   ('RAMTST - RAM TEST')
		        TITLE   "RAMTST - RAM TEST"
		;$       EJECT
		
		;;;     RAMTST - RAM TEST
		
		RAMTST:
		
        LXI     H,012H          ;FIRST WORD TO FILL
        LXI     D,0E7FFH        ;BOTTOM OF BOOT ROM
        CALL    FILL
        LXI     H,0F000H        ;TOP OF BOOT/DIAGNOSTIC ROM
        LXI     D,0F7FFH        ;BOTTOM OF MONITOR ROM
        CALL    FILL
		
		;       TEST BANK 0-32K
		
        LXI     H,012H          ;FIRST WORD TO TEST
        LXI     D,07FFFH        ;LAST WORD TO TEST
        CALL    CHECK
        LXI     B,RAMM1         ;'BANK 0-23K FAILURE' MESSAGE
        CALL    TEST
		
		;       TEST BANK 32-48K
		
        LXI     H,08000H        ;FIRST WORD TO TEST
        LXI     D,0BFFFH        ;LAST WORD TO TEST
        CALL    CHECK
        LXI     B,RAMM2         ;'BANK 32-48K FAILURE' MESSAGE
        CALL    TEST
		
		;       TEST BANK 48-62K
		
        LXI     H,0C000H        ;FIRST WORD TO TEST
        LXI     D,0E7FFH        ;BOTTOM OF BOOT/DIAGNOSTIC ROM
        CALL    CHECK
	        ORA     A               ;TEST FOR FAILURE
        JNZ     RAM1            ;IF A FAILURE
        LXI     H,0F000H        ;TOP OF BOOT/DIAGNOSTIC ROM
        LXI     D,0F7FFH        ;BOTTOM OF MONITOR ROM
        CALL    CHECK
RAM1:   LXI     B,RAMM3         ;'BANK 48-62K FAILURE' MESSAGE
        CALL    TEST
	        RET
		
		;;;     CHECK - CHECK SECTION OF MEMORY
		;
		;       PARAMETERS:
		;           DC = FIRST WORD ADDRESS OF BLOCK TO TEST
		;           HL = LAST WORD ADDRESS OF BLOCK TO TEST
		;
		;       RETURNS:
		;           A = 0 IF TEST SUCCESSFUL
		;           A = 0FFH AT FIRST FAILURE
		;
		;       CALLS:
		;           SETLIM
		
CHECK:  CALL    SETLIM          ;SET UP LIMITS TO TAKE MEMCHK INTO ACCOUNT
		
	CHECK1: MOV     A,D             ;CHECK IF ALREADY DONE
	        ORA     E
        JZ      CHECK2          ;IF ALREADY DONE
		
	        MOV     A,H             ;GENERATE PATTERN
	        XRA     L
	        CMP     M               ;CHECK IF PATTERN STILL IN MEMORY
        JNZ     CHECK3
		
	        CMA                     ;STORE AND VERIFY COMPLEMENT
	        MOV     M,A
	        CMP     M               ;VERIFY 0FFH IS THERE
        JNZ     CHECK3
		
	        CMA                     ;PUT PATTERN BACK
	        MOV     M,A
	        CMP     M               ;VERIFY PATTERN
        JNZ     CHECK3
		
	        INX     H               ;ADVANCE ADDRESS
	        DCX     D               ;DECREMENT COUNT
        JMP     CHECK1          ;LOOP
		
CHECK2: MVI     A,0             ;RETURN SUCCESS
	        RET
		
CHECK3: MVI     A,0FFH          ;RETURN FAILURE
	        RET
		
		;;;     FILL - FILL MEMORY WITH BACKGROUND, TAKING MEMCHK INTO ACCOUNT.
		;
		;           FILL WILL PUT BACKGROUND INTO MEMORY STARTING AT FIRST WORD ADDRESS
		;       AND ENDING AT MEMCHK OR LAST MEMORY ADDRESS, WHICHEVER IS ENCOUNTERED
		;       FIRST
		;
		;       PARAMETERS:
		;           HL FIRST WORD ADDRESS
		;           DE = LAST WORD ADDRESS
		;
		;       CALLS:
		;           SETLIM
		
FILL:   CALL    SETLIM
		
	FILL1:  MOV     A,D             ;CHECK IF COUNT=0
	        ORA     E
	        RZ
	        MOV     A,H             ;GENERATE PATTERN
	        XRA     L
	        MOV     M,A             ;STORE PATTERN
	        INX     H               ;INCREMENT POINTER TO NEXT LOCATION
	        DCX     D               ;DECREMENT COUNTER
        JMP     FILL1           ;LOOP
		
		;;;     SETLIM - SET LIMITS
		;
		;           SETLIM PERFORMS THE PLM FUNCTION:
		;
		;       IF FWA <= MEMCHK AND MEMCHK <= LWA
		;       THEN COUNT = MEMCHK - FWA + 1;
		;       ELSE COUNT = LWA - FWA + 1;
		;
		;       PARAMETERS:
		;           HL = FIRST WORD ADDRESS (FWA)
		;           E = LAST WORD ADDRESS (LWA)
		;
		;       RETURNS:
		;           HL = FIRST WORD ADDRESS
		;           DE = COUNT
		;
		;       CALLS:
		;           MEMCHK
		
	SETLIM: PUSH    H               ;SAVE HL AND DE DURING CALL TO MEMCHK
	        PUSH    D
		
        CALL    MEMCHK
	        MOV     C,A             ;BC=MEMCHK
		
	        POP     D               ;RESTORE HL AND DE
	        POP     H
		
	        SUB     L               ;SUBTRACT FWA FROM MEMCHK
	        MOV     A,B
	        SBB     H
        JC      SETLM1          ;JUMP IF MEMCHK < FWA
		
	        MOV     A,E             ;SUBTRACT MEMCHK FROM LWA
	        SUB     C
	        MOV     A,D
	        SBB     B
        JC      SETLM1          ;JUMP IF LWA < MEMCHK
		
	        MOV     D,B             ;MEMCHK IS WITHIN RANGE; USE IT AS LWA
	        MOV     E,C
		
	SETLM1: MOV     A,E             ;SUBTRACT FWA FROM MEMCHK OR LWA,
	        SUB     L               ;   AS THE CASE MAY BE
	        MOV     E,A
	        MOV     A,D
	        SBB     H
	        MOV     D,A
		
	        INX     D               ;ADD 1
		
	        RET
		
		;$       TITLE   ('UTILITY ROUTINES')
		       TITLE    "UTILITY ROUTINES"
		;$       EJECT
		
		;;;     FINISH - PRINT ' -- PASSED' IF FFLAG 0
		;
		;       ACCESSES:
		;           FFLAG
		;
		;       CALLS:
		;           PRINT
		
FINISH: LDA     FFLAG           ;TEST FFLAG
	        ORA     A
	        RNZ                     ;RETURN IF TEST FAILED
        LXI     B,FINA          ;PRINT ' -- PASSED' MESSAGE
        CALL    PRINTL
	        RET
		
		;FINA:   DB      ' -- PASSED',0
FINA:   DB      " -- PASSED",0
		
		;;;     INIT - SAVE INVIRONMENT ON STACK
		;           INIT SAVES THE INTERRUPT MASKS OF SOTH 8257'S AND THE
		;       CONTENTS OF FFLAG. IT IS INTENDED TO BE USED WITH RESTOR,
		;       AND MUST BE CALLED AT THE SAME NEST LEVEL AS RESTOR
		
	INIT:   POP     D               ;SAVE RETURN SINCE STACK TO BE MODIFIED
	        PUSH    PSW             ;SAVE A AND FLAGS
        LHLD    INT7V           ;SAVE INTERRUPT 7 VECTOR
	        PUSH    H
        LHLD    INT7V+2         ;SAVE REST OF VECTOR
	        PUSH    H
        LHLD    010H            ;SAVE TOFLAG AND FFLAG
	        PUSH    H
        IN      IPICMR          ;READ IO PIO MASK REGISTER
	        MOV     B,A
        IN      SPICMR          ;READ SYSTEM PIO MASK REGISTER
	        MOV     C,A
	        PUSH    B               ;SAVE THE MASKS IN THE STACK
        MVI     A,0             ;INITIALIZE FFLAG AND TOFLAG
        STA     FFLAG
        STA     TOFLAG
	        PUSH    D               ;RETURN
	        RET                     
		
		;;;     PRINT - PRINT STRING
		;
		;       PARAMETER:
		;           BC = POINTER TO STRING TERMINATED WITH A NULL.
		;
		;       CALLS:
		;           CO
		
	PRINT:  PUSH    B               ;SAVE POINTER ON THE STACK
		
	PRINT1: POP     H               ;LOAD POINTER INTO HL
	        MOV     C,M             ;READ NEXT CHARACTER
	        MOV     A,C             ;PREPARE FOR TERMINATOR CHECK
	        ORA     A               ;CHECK FOR STRING TERMINATOR
	        RZ                      ;RETURN IF NULL
	        INX     H               ;INCREMENT POINTER
	        PUSH    H               ;RESTORE ON STACK
        CALL    CO              ;PRINT CHARACTER
        JMP     PRINT1          ;LOOP UNTIL DONE
		
		;;;     PRINTL - PRINT MESSAGE WITH A CR-LF ADDED AT THE END
		;
		;       PARAMETER:
		;           BC = POINTER TO STRING TERMINATED WITH A NULL
		;
		;       CALLS:
		;           PRINT
		
PRINTL: CALL    PRINT           ;PRINT ORIGINAL STRING
        LXI     B,CRLF          ;PRINT CR-LF
        CALL    PRINT
	        RET
		
		;;;     RESTOR - RESTOR ENVIRONMENT
		;           RESTOR IS THE COMPLEMENT OF INIT
		
	RESTOR: POP     D               ;SAVE RETURN ADDR WHILE PLAYING WITH STACK
	        POP     B               ;READ INTERRUPT MASKS
	        MOV     A,C             ;RESTORE SYSTEM INTERRUPT MASK
        OUT     SPICMR
	        MOV     A,B             ;RESTORE 10 INTERRUPT MASK
        OUT     IPICMR
	        POP     H               ;RESTORE TOFLAG AND FFLAG
        SHLD    010H
	        POP     H               ;RESTORE INTERRUPT VECTOR
        SHLD    INT7V+2
	        POP     H
        SHLD    INT7V
	        POP     PSW             ;RESTORE A AND FLAGS
	        PUSH    D               ;RETURN
	        RET
		
		;;;     SETUP - SET UP FOR TEST
		;           SETUP PRINTS OUT THE START MESSAGE FOR A TEST AND INITIALIZES
		;       FFLAG TO 0.
		;
		;       PARAMETER:
		;       BC = POINTER TO START MESSAGE
		;
		;       MODIFIES:
		;           FFLAG
		;
		;       CALLS:
		;           PRINT
		
	SETUP:  PUSH    B               ;SAVE MESSAGE POINTER
        LXI     B,SETA          ;PRINT 'TESTING '
        CALL    PRINT
	        POP     B               ;PRINT MESSAGE
        CALL    PRINT
        MVI     A,0             ;ZERO OUT FFLAG
        STA     FFLAG
	        RET
		
		;SETA:   DB      '  TESTING ',0
SETA:   DB      "  TESTING ",0
		
		;;;     TEST - TEST RESULT FLAG OF A TEST
		;           THIS ROUTINE TESTS THE RESULT OF A TEST AND PRINTS A
		;       FAILURE MESSAGE IF JUSTIFIED. THE FLAG 'FFLAG' ARE TESTED,
		;       AND IF THERE HAVE BEEN NO FAILURES IN THE TEST TO THAT POINT,
		;       A CR-LF PAIR IS OUTPUT. FFLAG IS UPDATED TO TO REFLECT THE
		;       FAILURE. TOFLAG IS RESET TO 0.
		;
		;       PARAMETERS:
		;           A = RESULT FLAG
		;               0 => TEST PASSED
		;               0FFH => TEST FAILED
		;           BC = MESSAGE ADDRESS
		;
		;       MODIFIES:
		;           FFLAG
		;           TOFLAG
		;
		;       CALLS:
		;           PRINT
		
TEST:   LXI     H,TOFLAG        ;CHECK TIMEOUT AND RESULT FLAGS
	        ORA     M               ;CHECK FLAGS
	        RZ                      ;RETURN IF PASSED
	        PUSH    B               ;SAVE MESSAGE POINTER
        LDA     FFLAG           ;CHECK FAILURE FLAG
	        ORA     A
        JNZ     TEST1           ;IF THERE HAS ALREADY BEEN A FAILURE
		
        LXI     B,CRLF          ;CR-LF MESSAGE
        CALL    PRINT
        MVI     A,0FFH          ;SET FFLAG TO FAILED
        STA     FFLAG
		
TEST1:  LXI     B,TESTA         ;'FAILURE -- ' MESSAGE
        CALL    PRINT
		
	        POP     B               ;POP ERROR MESSAGE POINTER
        CALL    PRINTL          ;PRINT ERROR MESSAGE
		
        MVI     A,0             ;RESET TOFLAG
        STA     TOFLAG
	        RET
		
		;TESTA:  DB      '    FAILURE -- ',0
TESTA:  DB      "    FAILURE -- ",0
		
		;$       TITLE   (' INTERRUPT UTILITIES')
		        TITLE   "INTERRUPT UTILITIES"
		;$       EJECT
		
		;;;     CHKINT - CHECK INTERRUPTS
		;
		;       ENTRY CONDITIONS:
		;           ALL UNDESIRED INTERRUPTS MASKED OUT
		;           DESIRED INTERRUPT LINE ON
		;           8080 INTERRUPTS DISABLED
		;
		;       RETURNS:
		;           A = SUCCCESS FLAG
		;               0 = TEST PASSED
		;               0FFH = TEST FAILED
		;           8080 INTERRUPTS TURNED OFF
		
CHKINT: MVI     A,0C3H          ;STORE A JUMP TO CHK2
        STA     INT7V           ;   INTO INT7V
        LXI     H,CHK2
        SHLD    INT7V+1
		
	        EI                      ;TURN THE INTERRUPTS ON
        MVI     B,255           ;WAIT A WHILE
	CHK1:   DCR     B               ;DECREMENT THE COUNTER
        JNZ     CHK1            ;IF NOT COUNTED OUT YET
	        DI                      ;TEST DONE; FAILED
        MVI     A,0FFH          ;RETURN FAILURE
	        RET
		
	CHK2:   DI                      ;TURN OFF INTERRUPTS
	        POP     H               ;GET RID OF EXTRA RETURN ADDRESS
        MVI     A,0             ;RETURN SUCCESS
	        RET
		
		;;;     RESET - TRANSMIT EOI'S TO INTERRUPT CONTROLLERS
		;
		;       ENTRY CONDITIONS:
		;           INTERRUPTS TURNED OFF
		;
		;       EXIT CONDITIONS:
		;           INTERRUPTS TURNED ON
		
RESET:  MVI     A,POLL          ;SEND A POLL TO PICS             
        OUT     SPICCR
        OUT     IPICCR
        IN      SPICCR          ;READ AND IGNORE POLL DATA
        IN      IPICCR
        MVI     A,EOI
        OUT     IPICCR          ;OUTPUT EOI TO I0 PIC COMMAND REGISTER
        OUT     SPICCR          ;OUTPUT EOI TO SYSTEM PIC COMMAND REGISTER
	        EI
	        RET
		
		;;;     SETINT - SET UP FOR INTERRUPT TEST
		;
		;       PARAMETER:
		;           C = MASK FOR 10 PIC
		;
		;       EXIT CONDITIONS:
		;           PIC'S SET UP SO THIS IS THE ONLY INTERRUPT ENABLEABLE
		
	SETINT: DI
        MVI     A,NOTINT7      ;INITIALIZE SYSTEM PIC FOR ONLY 10 INTERRUPTS
        OUT     SPICMR
	        MOV     A,C             ;SET UP 10 PIC
        OUT     IPICMR
	        RET
		
		;$       TITLE   ('MESSAGES')
		        TITLE   "MESSAGES"
		;$       EJECT
		
	        IF      0
	CRLF:   DB      CR,LF,0
	SIGNON: DB      CR,LF,'INTELLEC SERIES II DIAGNOSTIC V1.0',0
	SGNOFF: DB      'END DIAGNOSTIC',0
	MIMI:   DB      'CHECKSUMS',0
	MIM2:   DB      'IOC',0
	MIM3:   DB      'PIO',0
	MIM4:   DB      'RAM' ,0
	CHKM1:  DB      'MONITOR CHECKSUM',0
	CHKM2:  DB      'BOOT CHECKSUM',0
	IOCM1:  DB      'IOC NOT RESPONDING (N/A 210)',0
	IOCM2:  DB      'IOC CHECKSUM', 0
	IOCM3:  DB      'IOC RAM',0
	IOCM4:  DB      'IOC INTERRUPTS',0
	PIOM1:  DB      'PIO NOT RESPONOING',0
	PIOM2:  DB      'PIO CHECKSUM',0
	PIOM3:  DB      'PIO RAM',0
	PIOM4:  DB      'PIO INTERRUPTS',0
	RAMM1:  DB      'RAM BANK 0-32K',0
	RAMM2:  DB      'RAM BANK 32-48K',0
	RAMM3:  DB      'RAM BANK 48-62K',0
		        ENDIF
		
CRLF:   DB      CR,LF,0
SIGNON: DB      CR,LF,"INTELLEC SERIES II DIAGNOSTIC V1.0",0
SGNOFF: DB      "END DIAGNOSTIC",0
MIMI:   DB      "CHECKSUMS",0
MIM2:   DB      "IOC",0
MIM3:   DB      "PIO",0
MIM4:   DB      "RAM" ,0
CHKM1:  DB      "MONITOR CHECKSUM",0
CHKM2:  DB      "BOOT CHECKSUM",0
IOCM1:  DB      "IOC NOT RESPONDING (N/A 210)",0
IOCM2:  DB      "IOC CHECKSUM", 0
IOCM3:  DB      "IOC RAM",0
IOCM4:  DB      "IOC INTERRUPTS",0
PIOM1:  DB      "PIO NOT RESPONOING",0
PIOM2:  DB      "PIO CHECKSUM",0
PIOM3:  DB      "PIO RAM",0
PIOM4:  DB      "PIO INTERRUPTS",0
RAMM1:  DB      "RAM BANK 0-32K",0
RAMM2:  DB      "RAM BANK 32-48K",0
RAMM3:  DB      "RAM BANK 48-62K",0
		
	        DB      BOOSUM          ;NUMBER TO MAKE CHECKSUM COME OUT TO 055H
		
	        END

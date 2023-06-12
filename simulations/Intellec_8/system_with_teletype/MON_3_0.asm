; Original source from: https://mark-ogden.uk/files/intel/publications/98-022B%20intellec%208-MOD%208%20MONITOR%20V3.0-Apr75.pdf
; (Intellec 8/MOD 8 Monitor, version 3.0, 14 april 1975)
;
; Changed for compilation with Macro Assembler v 1.42 Beta
; - changed NOT with ~
; - changed NOT CMSK with 00000011B, NOT PMSK with 00110000B, NOT RMSK with 00001100B 
; - changed OR with |
; - removed definitions of TRUE/FALSE
; - changed MVI M,(JMP 0) with MVI M,44H
; - changed LVER EQU 8 (for length of VERS)
; - added IOMOD     LABEL     $
;
;
; -----------------------------------------------------------------------
;
;         INTELLEC 8/MOD 8 MONITOR
;
;           FAST PROM PROGRAMMING ALGORITHM ADDED, 21 JUN 1974
;
;           COPYRIGHT (C) 1975
;           INTEL CORPORATION
;           3065 BOWERS AVENUE
;           SANTA CLARA, CALIFORNIA 95051
;
;
; <LEGAL COMMAND>  ::= <ASSIGN I/O COMMAND>
;                      <BNPF PUNCH COMMAND>
;                      <COMPARE COMMAND>
;                      <DISPLAY MEMORY COMMAND>
;                      <ENDFILE COMMAND>
;                      <FILL MEMORY COMMAND>
;                      <PROGRAM EXECUTE COMMAND>
;                      <HEXADECIMAL ARITHMETIC COMMAND>
;                      <LOAD BNPF COMMAND>
;                      <MOVE MEMORY COMMAND>
;                      <LEADER COMMAND>
;                      <PROGRAM COMMAND>
;                      <READ HEXADECIMAL FILE COMMAND>
;                      <SUBSTITUTE MEMORY COMMAND>
;                      <TRANSFER COMMAND>
;                      <WRITE HEXADECIMAL RECORD COMMAND>
;                      <REGISTER MODIFY COMMAND>
;
; <ASSIGN I/O COMMAND> ::= A<LOGICAL DEVICE>=<PHYSICAL DEVICE>
; <BNPF PUNCH COMMAND> ::= B<NUMBER,NUMBER>
; <COMPARE COMMAND> ::= C<NUMBER>
; <DISPLAY MEMORY COMMAND> ::= D<NUMBER,NUMBER>
; <ENDFILE COMMAND> ::= E<NUMBER>
; <FILL MEMORY COMMAND> ::= F<NUMBER>,<NUMBER>,<NUMBER>
; <PROGRAM EXECUTE COMMAND> ::= G<NUMBER>
; <HEXADECIMAL ARITHMETIC COMMAND> ::= H<NUMBER>,<NUMBER>
; <LOAD BNPF COMMAND> ::= L<NUMBER>,<NUMBER>
; <MOVE MEMORY COMMAND> ::= M<NUMBER>,<NUMBER>,<NUMBER>
; <LEADER COMMAND> ::= N
; <PROGRAM COMMAND> ::= P<NUMBER>,<NUMBER>,<NUMBER>
; <READ HEXADECIMAL COMMAND> ::= R<NUMBER>
; <SUBSTITUTE MEMORY COMMAND> ::= S<NUMBER>
; <TRANSFER COMMAND> ::= T<NUMBER>
; <WRITE HEXADECIMAL RECORD COMMAND> ::= W<NUMBER>,<NUMBER>
;
; <LOGICAL DEVICE> ::= CONSOLE!READER!LIST!PUNCH
;
; <PHYSICAL DEVICE> ::= CRT!TTY!PTR!PTP!BATCH!1!2
;
; <NUMBER> ::=         <HEX DIGIT>
;              <NUMBER><HEX DIGIT>
; 
; <HEX DIGIT> ::= 0!1!2!3!4!5!6!7!8!9!A!B!C!D!E!F
;
; SYSTEM SIGNS ON WITH <CR><LF><.>
;
VER       EQU       30        ; VERSION 3.0
          TITLE       ' INTELLEC 8/MOD 8 MONITOR, VERSION 3.0, 14 APRIL 1975'
;
; CONDITIONAL ASSEMBLY SWITCHES
;
;FALSE     EQU       0                  ; ALREADY AVAILABLE IN AS
;TRUE      EQU       NOT FALSE
DEBUG     EQU       FALSE               ; DEBUG MODE -
                                        ; MODIFY CERTAIN CODE SECTIONS
                                        ; SO THAT THE 8008 VERSION 2.0
                                        ; MONITOR MAY BE ASSEMBLED BY
                                        ; MAC80 AND DEBUGGED BY THE 8080
                                        ; VERSION 1.0 MONITOR 

          IF        DEBUG
BIAS      EQU       0
          ENDIF

          IF        ~DEBUG
BIAS      EQU       8                   ; ASSIGN PROPER NUMERIC VALUES TO
                                        ; OUTPUT PORTS FOR THE 8080
          ENDIF
;
; I/O DEVICE OUTPUT COMMAND PORT 1 (TTC) BIT VALUES
; 
; BIT     REST      MNEMONIC            DESCRIPTION
;
; 0       0         RBIT                TTY READER GO/NO GO
; 1       0         PCMD                PTP GO/NO GO
; 2       0         RCMD                PTR GO/NO GO
; 3       1         DSB                 PROM ENABLE/DISABLE, DSB=1
; 4       0                             DATA IN T/C
; 5       0                             DATA OUT T/C
; 6       0         PBIT                1702 PROM PROG. GO/NO GO
; 7       0         PBITA               1702A PROM PROG. GO/NO GO
;
; I/O DEVICE INPUT STATUS PORT 1 (TTS) BIT VALUES
;
; BIT     REST      MNEMONIC            DESCRIPTION
;
; 0       1         TTYDA               IF TTYDA = 0, INPUT IS READY
; 1       1                             OVERRUN ERROR
; 2       0         TTYBE               IF TTYBE = 0, OUTPUT IS READY
; 3       1                             FRAMING ERROR
; 4       1                             PARITY ERROR
; 5       0         PTRDA               IF PTRDA = 1, PTR HAS CHAR
; 6       1         PRDY                IF PRDY = 1, PTP IS READY
; 7                                     UNASSIGNED
;
; I/O DEVICE INPUT STATUS PORT 5 (CRTS) BIT VALUES
; 
; BIT     REST      MNEMONIC            DESCRIPTION
;
; 0       1         CRTDA               IF CRTDA = 0, INPUT IS READY
; 1       1                             OVERRUN ERROR
; 2       0         CRTBE               IF CRTBE = 0, OUTPUT IS READY
; 3       1                             FRAMING ERROR
; 4       1                             PARITY ERROR
; 5                                     UNASSIGNED
; 6                                     UNASSIGNED
; 7                                     UNASSIGNED
;
; I/O COMMAND CONSTANTS
;
RBIT      EQU       1
PCMD      EQU       2
RCMD      EQU       4
DSB       EQU       8
PBITA     EQU       80H
;
; TTY I/O CONSTANTS
;
TTI       EQU       0                   ; TTY INPUT DATA PORT
TTO       EQU       BIAS+0              ; TTY OUTPUT DATA PORT
TTS       EQU       1                   ; TTY INPUT STATUS PORT
TTC       EQU       BIAS+1              ; TTY OUTPUT COMMAND PORT
TTYGO     EQU       RBIT | DSB          ; START TTY READER
TTYNO     EQU       DSB                 ; STOP TTY READER
TTYDA     EQU       1                   ; DATA AVAILABLE
TTYBE     EQU       4                   ; TRANSMIT BUFFER EMPTY
;
; CRT I/O CONSTANTS
;
CRTI      EQU       4                   ; CRT INPUT DATA PORT
CRTS      EQU       5                   ; CRT INPUT STATUS PORT
CRTO      EQU       BIAS+4              ; CRT OUTPUT DATA PORT
CRTDA     EQU       1                   ; DATA AVAILABLE
CRTBE     EQU       4                   ; TRANSMIT BUFFER EMPTY
;
; PTR I/O CONSTANTS
;
PTRI      EQU       3                   ; PTR INPUT DATA PORT (NOT INVERTED)
PTRS      EQU       TTS                 ; PTR INPUT STATUS PORT
PTRC      EQU       TTC                 ; PTR OUTPUT COMMAND PORT
PTRGO     EQU       RCMD | DSB          ; START PTR
PTRNO     EQU       TTYNO               ; STOP PTR
PTRDA     EQU       20H                 ; PTR DATA AVAILABLE
;
; PTP I/O CONSTANTS
;
PTPO      EQU       BIAS+3              ; PTP OUTPUT DATA PORT
PTPS      EQU       TTS                 ; PTP INPUT STATUS PORT
PTPC      EQU       TTC                 ; PTP OUTPUT COMMNAND PORT
PRDY      EQU       40H                 ; PUNCH READY STATUS
PTPGO     EQU       PCMD | DSB          ; START PUNCH
PTPNO     EQU       TTYNO               ; STOP PUNCH
;
; PROM PROGRAMMER I/O CONSTANTS
;
PAD       EQU       BIAS+2              ; PROM ADDRESS OUTPUT PORT
PDO       EQU       PTPO                ; PROM DATA OUTPUT PORT
PDI       EQU       2                   ; PROM DATA INPUT PORT
PROMC     EQU       TTC                 ; PROGRAMMING PULSE OUTPUT PORT
PROGO     EQU       PBITA               ; START PROGRAMMING
PRONO     EQU       0                   ; STOP PROGRAMMING
ENB       EQU       0
;
; GLOBAL CONSTANTS
;
TOUT      EQU       250                 ; 250 MS COUNTER FOR READER TIMEOUT
LDLY      EQU       20                  ; COUNTER FOR 20 MS DELAY
          IF        DEBUG
DLY       EQU       111                 ; 1 MS DELAY FOR 8080 DEBUG
          ENDIF
          IF        ~DEBUG
DLY       EQU       23                  ; COUNTER FOR 1 MS DELAY
          ENDIF
CR        EQU       0DH                 ; ASCII VALUE OF CARRIAGE RETURN
LF        EQU       0AH                 ; ASCII VALUE OF LINE FEED
;
; MACRO DEFINITIONS
;
FIRST     SET       TRUE
MODIO     MACRO     TABLE,MASK
          LXI       D,TABLE             ; ADDRESS OF PHYSICAL UNIT TABLE
          MVI       C,MASK              ; C = SELECT BIT MASK
          IF        FIRST               ; EMITS THIS CODE ONCE,
                                        ;  BRANCH TO IT THEREAFTER
IOMOD:
IOMOD     LABEL     $                   ; added for AS
FIRST     SET       FALSE
          CALL      NOISE               ; SCAN INPUT AND ECHO UNTIL
                                        ; PHYSICAL DEVICE CHAR IS ENCOUNTERED
          MVI       B,4                 ; SET TABLE LENGTH
          MOV       H,D
          MOV       L,E
          CALL      TEST                ; COMPARE PHYSICAL DEVICE AGAINST
          CALL      INCHL
          MOV       E,M                 ; TABLE, RETURN HL -> BIT PATTERN
SCANOUT:
          CALL      TI
          CPI       CR
          JNZ       SCANOUT             ; SCAN PAST CR
          LXI       H,IOBYT             ; GET I/O STATUS
          MOV       A,M
          ANA       C                   ; CLEAR FIELD
          ORA       E                   ; SET NEW STATUS
          MOV       M,A                 ; RETURN TO MEMORY
          JMP       START
TEST:                                   ; INDEX THROUGH PHYSICAL UNIT TABLE
          CMP       M                   ; COMPARE DEVICE CHAR WITH LEGAL VALUES
          RZ                            ; RETURN WITH HL -> DEVICE SELECT BITS
          CALL      INCHL
          CALL      INCHL
          DCR       B
          JNZ       TEST                ; CONTINUE LOOKUP
          JMP       LER                 ; ERROR RETURN
          ENDIF
          IF        ~FIRST
          JMP       IOMOD
          ENDIF
          ENDM
;
; I/O STATUS BYTE MASKS AND VALUES
;
CMSK      EQU       11111100B           ; MASK FOR CONSOLE I/O
RMSK      EQU       11110011B           ; MASK FOR READER INPUT
PMSK      EQU       11001111B           ; MASK FOR PUNCH OUTPUT
LMSK      EQU       00111111B           ; MASK FOR LIST OUTPUT
;
CTTY      EQU       00000000B           ; CONSOLE I/O = TTY
CCRT      EQU       00000001B           ; CONSOLE I/O = CRT
BATCH     EQU       00000010B           ; BATCH MODE
                                        ; INPUT = READER, OUTPUT = LIST
CUSE      EQU       00000011B           ; USER DEFINED CONSOLE I/O
RTTY      EQU       00000000B           ; READER = TTY
RPTR      EQU       00000100B           ; READER = PTR
RUSE1     EQU       00001000B           ; USER DEFINED READER (1)
RUSE2     EQU       00001100B           ; USER DEFINED READER (2)
PTTY      EQU       00000000B           ; PUNCH = TTY
PPTP      EQU       00010000B           ; PUNCH = PTP
PUSE1     EQU       00100000B           ; USER DEFINED PUNCH (1)
PUSE2     EQU       00110000B           ; USER DEFINED PUNCH (2)
LTTY      EQU       00000000B           ; LIST = TTY
LCRT      EQU       01000000B           ; LIST = CRT
LUSE1     EQU       10000000B           ; LIST = LPT
LUSE2     EQU       11000000B           ; USER DEFINED LIST
;
; USER DEFINED DEVICE ENTRY POINTS
;
CILOC     EQU       3700H               ; USER CONSOLE INPUT
COLOC     EQU       3703H               ; USER CONSOLE OUTPUT
R1LOC     EQU       3706H               ; USER READER 1
R2LOC     EQU       3709H               ; USER READER 2
P1LOC     EQU       370CH               ; USER PUNCH 1
P2LOC     EQU       370FH               ; USER PUNCH 2
L1LOC     EQU       3712H               ; USER LIST 1
L2LOC     EQU       3715H               ; USER LIST 2
CSLOC     EQU       3718H               ; USER CONSOLE STATUS
;
; POINTERS TO RAM
;
          IF        ~DEBUG
          ORG       3                   ; LOCATION OF RAM STORAGE AREA
          ENDIF
          
          IF        DEBUG
          ORG       100H
          ENDIF
          
IOBYT:
          DS        1                   ; I/O STATUS BYTE
HPRIME:
          DS        2                   ; TEMP FOR HL
CBRCH:
          DS        2                   ; CASE BRANCH LOCATION
ADR1:
          DS        2                   ; FIRST PARAMETER
ADR2:
          DS        2                   ; SECOND PARAMETER
ADR3:
          DS        2                   ; THIRD PARAMETER
          
          IF        DEBUG
          ORG       800H                ; LOCATE IN RAM FOR DEBUG
          ENDIF
          
          IF        ~DEBUG
          ORG       3800H               ; LOCATE IN TOP 8 ROMS IN 16K
          ENDIF
          
;
; BRANCH TABLE FOR I/O SYSTEM
;
          JMP       BEGIN               ; RESET ENTRY POINT
          JMP       CI                  ; CONSOLE INPUT
          JMP       RI                  ; READER INPUT
          JMP       CO                  ; CONSOLE OUTPUT
          JMP       PO                  ; PUNCH OUTPUT
          JMP       LO                  ; LIST OUTPUT
          JMP       CSTS                ; CONSOLE INPUT STATUS
          JMP       IOCHK               ; I/O SYSTEM STATUS
          JMP       IOSET               ; SET I/O CONFIGURATION
          JMP       MEMCK               ; COMPUTE SIZE OF MEMORY
;
; INITIAL CONDITIONS FOR I/O SYSTEM
;
INIT      EQU       0                   ; INITIALLY,
                                        ; CONSOLE = TTY,
                                        ; READER = TTY,
                                        ; PUNCH = TTY,
                                        ; LIST = TTY
VERS:     DB        CR,LF,'8008 V'
          
          IF        ~DEBUG
          DB        VER/10+'0','.',(VER # 10)+'0'
          ENDIF
          
          IF        DEBUG
          DB        'X.X'
          ENDIF
          
LVER      EQU       11                   ; LENGTH(VERS) 
;
; PROGRAM ENTRY POINT
;
; LOCATE THE STACK IN THE TOP OF AVAILABLE RAM
;
BEGIN:
          LXI       H,IOBYT             ; POINT HL AT IOBYT
          MVI       M,INIT              ; INITIAL VALUE OF I/O
;
; TYPE SIGN-ON
;
          LXI       H,VERS              ; ADDRESS OF MESSAGE
          MVI       C,LVER              ; LENGTH OF MESSAGE
VERO:
          MOV       B,M
          CALL      INCHL
          MOV       D,H
          MOV       E,L
          CALL      CO
          MOV       H,D
          MOV       L,E
          DCR       C
          JNZ       VERO
;
; MAIN COMMAND LOOP
;
; THIS LOOP IS THE STARTING POINT OF ALL COMMAND SEQUENCES.
; IN THIS CODE ALL I/O DEVICES ARE INITIALIZED, A CARRIAGE
; RETURN AND LINE FEED ARE TYPED, ALONG WITH THE PROMPT
; CHARACTER '.'. WHEN A CHARACTER IS ENTERED FROM THE
; CONSOLE KEYBOARD, IT IS CHECKED FOR VALIDITY, THEN A
; BRANCH TO THE PROPER PROCESSING ROUTINE IS COMPUTED.
;
START:
          MVI       A,TTYNO             ; RESET TTY,PTR,PTP
          OUT       TTC                 ; RESET READER
          CALL      CRLF                ; TYPE <CR>,<LF>
          MVI       B,'.'               
          CALL      CO                  ; OUTPUT A PERIOD
          CALL      TI                  ; GET A CHARACTER
          SUI       'A'                 ; TEST FOR A-W
          JM        START               ; LT A, ERROR
          CPI       'W'-'A'+1
          JP        LER                 ; GT W, ERROR
          ADD       A                   ; *2
          LXI       H,TBL               ; ADDRESS OF TABLE
          ADD       L                   ; ADD BIAS
          MOV       L,A
          MOV       E,M                 ; GET ADDRESS IN D,E
          INR       L
          MOV       D,M
GO:
          LXI       H,CBRCH             ; ADDRESS OF JMP INSTRUCTION
          MVI       M,44H ;(JMP 0)           ; STUFF OPCODE
          INR       L
          MOV       M,E                 ; STUFF 8 LSB
          INR       L
          MOV       M,D                 ; STUFF 8 MSB
          MVI       C,2                 ; SETUP C FOR TWO PARAMETER COMMANDS
          JMP       CBRCH               ; GO DO IT
;
; COMMAND BRANCH TABLE
;
; THIS TABLE CONTAINS THE ADDRESSES OF THE ENTRY POINTS OF 
; ALL THE COMMAND PROCESSING ROUTINES. NOTE THAT AN ENTRY TO 'LER'
; IS AN ERROR CONDITION, I.E., NO COMMAND CORRESPONDING TO THAT 
; CHARACTER EXISTS.
;
TBL:
          DW        ASSIGN              ; A = ASSIGN I/O UNITS
          DW        BNPF                ; B = PUNCH BNPF
          DW        COMP                ; C = COMPARE PROM WITH MEMORY
          DW        DISP                ; D = DISPLAY RAM MEMORY
          DW        EOF                 ; E = ENDFILE A HEXADECIMAL FILE
          DW        FILL                ; F = FILL MEMORY
          DW        GOTO                ; G = GOTO MEMORY ADDRESS
          DW        HEXN                ; H = HEXADECIMAL SUM AND DIFFERENCE
          DW        LER                 ; I =
          DW        LER                 ; J =
          DW        LER                 ; K =
          DW        LOAD                ; L = LOAD BNPF TAPE
          DW        MOVE                ; M = MOVE MEMORY
          DW        NULL                ; N = PUNCH NULLS FOR LEADER
          DW        LER                 ; O =
          DW        PROG                ; P = PROGRAM A 1702A PROM
          DW        LER                 ; Q =
          DW        READ                ; R = READ HEXADECIMAL FILE
          DW        SUBS                ; S = SUBSTITUTE MEMORY
          DW        TRAN                ; T = TRANSFER A PROM TO MEMORY
          DW        LER                 ; U =
          DW        LER                 ; V = 
          DW        WRITE               ; W = WRITE HEX TAPE
;
; PROCESS I/O DEVICE ASSIGNMENT COMMANDS
;
; THIS ROUTINE MAPS SYMBOLIC DEVICE IDENTIFIERS TO BITS
; IN THE I/O STATUS BYTE (IOBYT) TO ALLOW FOR CONSOLE 
; MODIFICATION OF SYSTEM I/O CONFIGURATION
;
ASSIGN:
          CALL      TI                  ; GET LOGICAL DEVICE CHARACTER
          CPI       'C'                 ; CONSOLE?
          JNZ       AS0                 ; TEST FOR READER
          MODIO     ICT,CMSK            ; MODIFY CONSOLE DEVICE
AS0:
          CPI       'R'                 ; READER ?
          JNZ       AS1                 ; TEST FOR PUNCH
          MODIO     IRT,RMSK            ; MODIFY READER DEVICE
AS1:
          CPI       'P'                 ; PUNCH ?
          JNZ       AS2                 ; TEST FOR LIST
          MODIO     OPT,PMSK            ; MODIFY PUNCH DEVICE
AS2:
          CPI       'L'                 ; LIST ?
          JNZ       LER                 ; ERROR
          MODIO     OLT,LMSK            ; MODIFY LIST DEVICE
;
; PUNCH A BNPF TAPE
;
; THIS ROUTINE EXPECTS TWO HEXADECIMAL PARAMETERS TO BE
; ENTERED FROM THE KEYBOARD AND INTERPRETS THEM AS 
; THE BOUNDS OF MEMORY AREA TO BE PUNCHED ON THE
; ASIGNED PUNCH DEVICE IN BNPF FORMAT. THE TAPE 
; PRODUCED IS FORMATTED WITH 4 BNPF 8-BIT WORDS PER
; LINE, WITH A REFERENCE ADDRESS IN DECIMAL PRECEEDING
; EACH LINE.
;
BNPF:
          CALL      EXPR                ; GET TWO ADDRESSES
          CALL      CRLF
          CALL      LEAD
BN0:
          CALL      PEOL                ; PUNCH CR,LF
          CALL      GETAD               ; GET HL AND DE
          MVI       C,' '               ; ZERO SUPPRESSION CHARACTER
          LXI       D,10000             ; PUNCH ADDRESS IN DECIMAL
          CALL      DIGIT
          LXI       D,1000
          CALL      DIGIT
          LXI       D,100
          CALL      DIGIT
          LXI       D,10
          CALL      DIGIT
          LXI       D,1
          MVI       C,'0'               ; FORCE AT LEAST 1 ZERO
          CALL      DIGIT
          MVI       B,' '
          CALL      PO
          CALL      GETAD               ; GET HL AND DE
BN1:
          CALL      ENCODE              ; ENCODE A MEMORY BYTE INTO BNPF
          CALL      GETAD               ; GET HL AND DE
          CALL      HILO
          JC        NULL                ; ALL DONE, PUNCH TRAILER AND RETURN
          CALL      SAVIT
          CALL      GETAD               ; GET HL AND DE
          MOV       A,L
          ANI       03H                 ; PUNCH CR,LF,ADDRESS ON MULTIPLE OF 4
          JNZ       BN1
          JMP       BN0
;
; COMPARE PROM WITH MEMORY
;
; THIS ROUTINE EXPECTS ONE HEXADECIMAL PARAMETER WHICH 
; IT INTERPRETS AS A MEMORY ADDRESS. THE ROUTINE
; COMPARES THE PROM IN THE FRONT PANEL SOCKET WITH A
; 256 BYTE AREA OF MEMORY POINTED TO BY THE INPUT PARAMETER.
; ALL DIFFERENCES BETWEEN THE PROM AND THE MEMORY AREA 
; ARE DISPLAYED IN THE FOLLOWING FORMAT:
;
; <MEM ADDRESS> <MEM CONTENTS> <CORRESPONDING PROM CONTENTS>
;
COMP:
          DCR       C
          CALL      EXPR                ; GET ONE ADDRESS
          CALL      CRLF                ; OUTPUT CR AND LF
          CALL      GETAD               ; GET HL AND DE
          MVI       C,0                 ; COUNT/PROM ADDRESS
          MVI       A,ENB               ; ENABLE PROM PROGRAMMER
          OUT       PROMC
CM0:
          MOV       A,C                 ; SET PROM ADDRESS
          XRI       0FFH                ; INVERT ADDRESS
          OUT       PAD
          CALL      DELAY               ; WAIT FOR 6-76 BOARD TO LATCH DATA
          IN        PDI                 ; GET PROM DATA
          XRI       0FFH
          CMP       M                   ; COMPARE WITH MEMORY
          JZ        CM1                 ; COMPARE
          MOV       E,C
          CALL      SAVIT
          CALL      GETAD
          CALL      LADR                ; PRINT MEMORY ADDRESS
          MOV       A,M
          CALL      LBYTE               ; PRINT RAM DATA
          CALL      BLK
          IN        PDI                 ; GET PROM DATA
          XRI       0FFH
          CALL      LBYTE               ; PRINT PROM DATA
          CALL      CRLF
          CALL      GETAD
          MOV       C,E
CM1:
          CALL      INCHL
          INR       C                   ; ADJUST PROM ADDRESS
          JNZ       CM0
          JMP       START
;
; DISPLAY MEMORY IN HEX TO CONSOLE DEVICE
;
; THIS ROUTINE EXPECTS TWO HEXADECIMAL PARAMETERS SPECIFYING
; THE BOUNDS OF A MEMORY AREA TO BE DISPLAYED ON THE
; CONSOLE DEVICE. THE MEMORY AREA IS DISPLAYED 16 BYTES
; PER LINE, WITH THE MEMORY ADDRESS OF THE FIRST BYTE 
; PRINTED FOR REFERENCE. ALL LINES ARE BLOCKED INTO INTEGRAL
; MULTIPLES OF 16 FOR CLARITY, SO THAT THE FIRST AND LAST
; LINES MAY BE LESS THAN 16 BYTES IN ORDER TO SYNCHRONIZE THE
; DISPLAY.
;
DISP:
          CALL      EXPR                ; GET TWO ADDRESSES
DI0:
          CALL      CRLF
          CALL      GETAD               ; GET HL AND DE
          CALL      LADR                ; PRINT MEMORY ADDRESS
DI1:
          MOV       A,M
          CALL      LBYTE               ; PRINT DATA
          CALL      BLK                 ; PRINT SPACE
          CALL      GETAD               ; GET HL AND DE
          CALL      HILO                ; TEST FOR COMPLETION
          JC        START
          CALL      SAVIT               ; STORE HL,DE
          CALL      GETAD               ; GET HL AND DE
          MOV       A,L
          ANI       0FH                 ; PRINT CR,LF,ADDRESS ON MULTIPLE OF 16
          JNZ       DI1
          JMP       DI0
;
; END OF FILE COMMAND
;
; THIS ROUTINE PRODUCES A TERMINATION RECORD WHICH PROPERLY
; COMPLETES A HEXADECIMAL FILE CREATED BY 'W' COMMANDS. IT
; EXPECTS ONE HEXADECIMAL PARAMETER WHICH IS ENCODED IN THE
; TERMINATION RECORD IN THE LOAD ADDRESS FIELD AND SPECIFIES
; THE ENTRY POINT OF THE FILE CREATED. A SUBSEQUENT 'R' COMMAND
; WILL LOAD THE FILE CREATED AND TRANSFER CONTROL TO THE 
; ENTRY POINT SPECIFIED IF IT IS NON-ZERO.
;
EOF:
          DCR       C                   ; GET ONE PARAMETER
          CALL      EXPR
          CALL      PEOL                ; PUNCH CR,LF
          MVI       B,':'
          CALL      PO
          XRA       A                   ; CLEAR CHECKSUM
          MOV       D,A
          CALL      PBYTE               ; OUTPUT RECORD LENGTH
          MOV       A,D
          CALL      GETAD
          MOV       D,A
          MOV       E,L
          MOV       A,H
          CALL      PBYTE
          MOV       A,E
          CALL      PBYTE
          MVI       A,1                 ; RECORD TYPE 1
          CALL      PBYTE
          XRA       A
          SUB       D
          CALL      PBYTE               ; OUTPUT CHECKSUM
          JMP       NULL                ; PUNCH TRAILER AND RETURN
;
; FILL RAM MEMORY BLOCK WITH CONSTANT
;
; THIS ROUTINE EXPECTS THREE HEXADECIMAL PARAMETERS, THE
; FIRST AND SECOND (16 BITS) ARE INTERPRETED AS THE BOUNDS
; OF A MEMORY AREA TO BE INITIALIZED TO A CONSTANT VALUE,
; THE THIRD PARAMETER (B BITS) IS THAT VALUE.
;
FILL:
          INR       C                   ; GET 3 PARAMETERS
          CALL      EXPR                
          MOV       A,E                 ; GET DATA IN A
          CALL      GETAD               ; GET HL AND DE
          MOV       B,A
FI0:
          MOV       M,B                 ; STORE CONSTANT IN MEMORY
          CALL      HILO                ; TEST FOR COMPLETION
          JNC       FI0                 ; CONTINUE LOOPING
          JMP       START
;
; GO TO <ADDRESS>
;
; THE G COMMAND IS USED FOR TRANSFERRING CONTROL FROM THE
; MONITOR TO A USER PROGRAM.
;
GOTO:
          DCR       C
          CALL      EXPR
          JMP       GO
;
; COMPUTE HEXADECIMAL SUM AND DIFFERENCE
;
; THIS ROUTINE EXPECTS TWO HEXADECIMAL PARAMETERS.
; IT COMPUTES THE SUM AND THE DIFFERENCE OF THE TWO VALUES
; AND DISPLAYS THEM ON THE CONSOLE DEVICE AS FOLLOWS:
;
; <P1+P2> <P1-P2>
;
HEXN:
          CALL      EXPR                ; GET TWO NUMBERS
          CALL      CRLF
          CALL      GETAD               ; GET HL AND DE
          MOV       A,L                 ; COMPUTE HL+DE
          ADD       E
          MOV       E,A                 ; SAVE LSB IN E
          MOV       A,H
          ADC       D
          CALL      LBYTE               ; DISPLAY MSB OF SUM
          MOV       A,E                 ; RETRIEVE LSB
          CALL      LBYTE               ; DISPLAY IT
          CALL      BLK                 ; TYPE A SPACE
          CALL      GETAD               ; GET HL AND DE
          MOV       A,L                 ; COMPUTE HL-DE
          SUB       E
          MOV       E,A                 ; SAVE LSB OF DIFFERENCE
          MOV       A,H
          SBB       D
          MOV       H,A
          CALL      LBYTE               ; DISPLAY MSB OF DIFFERENCE
          MOV       A,E                 ; RETRIEVE LSB
          CALL      LBYTE               ; DISPLAY LSB OF DIFFERENCE
          JMP       START
;
; LOAD A BNPF TAPE INTO RAM MEMORY.
; 
; THIS ROUTINE EXPECTS TWO HEXADECIMAL PARAMETERS AND
; INTERPRETS THEM AS BOUNDS OF A MEMORY AREA TO BE 
; LOADED BY BNPF DATA TO BE READ FROM THE READER.
; IT IS ASSUMED THAT ENOUGH DATA IS AVAILABLE IN THE
; TAPE TO BE READ TO SATISFY THE MEMORY BOUNDS ENTERED.
; IF END OF TAPE IS ENCOUNTERED BEFORE THE MEMORY BOUNDS
; ARE SATISFIED, THIS ROUTINE WILL TERMINATE ON AN ERROR
; CONDITION (SEE RIX), BUT ALL DATA READ BEFORE THE END 
; OF TAPE WAS ENCOUNTERED WILL BE LOADED.
;
LOAD:
          CALL      EXPR                ; GET TWO ADDRESSES
          CALL      CRLF
LO0:
          CALL      DECODE              ; CONVERT BNPF, RETURN IN C-REGISTER
          MOV       A,C                 ; CONVERTED DATA BYTE
          CALL      GETAD               ; GET HL AND DE
          MOV       M,A                 ; STORE DATA
          CALL      HILO                ; TEST FOR COMPLETION
          JC        START
          CALL      SAVIT
          JMP       LO0
;
; MOVE A BLOCK OF RAM MEMORY
;
MOVE:
          INR       C                   ; GET THREE ADDRESSES
          CALL      EXPR
MV0:
          CALL      GETAD
          MOV       A,M                 ; GET DATA
          LXI       H,ADR3              ; GET DESTINATION ADDRESS
          MOV       B,M
          INR       L
          MOV       L,M
          MOV       H,B
          MOV       M,A                 ; STORE DATA
          CALL      INCHL               ; INCREMENT DESTINATION ADDRESS
          MOV       B,H
          MOV       C,L
          LXI       H,ADR3
          MOV       M,B
          INR       L
          MOV       M,C
          CALL      GETAD
          CALL      HILO
          JC        START
          CALL      SAVIT
          JMP       MV0
;
; PUNCH LEADER AND TRAILER
;
; THIS ROUTINE PUNCHES 60 NULL CHARACTERS ON THE DEVICE ASSIGNED
; AS THE PUNCH. IT IS BRANCHED TO BY THE 'B' AND 'E' COMMANDS
; AS WELL AS BEING INVOKED BY THE 'N' COMMAND.
;
NULL:
          CALL      LEAD
          JMP       START
;
; PROGRAM A 1702A PROM WITH FAST ALGORITHM
; (20.48 TO 409.6 SECONDS)
;
; THIS ROUTINE EXPECTS THREE HEXADECIMAL PARAMETERS FROM THE CONSOLE.
; THE FIRST AND SECOND ARE THE BOUNDS OF A MEMORY AREA TO BE
; REPRODUCED IN THE 1702A PROM IN THE FRONT PANEL SOCKET. THE THIRD
; PARAMETER IS THE ADDRESS IN THE PROM (8 BITS) WHERE THE DUPLICATION
; IS TO COMMENCE. THE ALGORITHM USED IN THIS ROUTINE TAKES ADVANTAGE
; OF THE FACT THAT MOST PROMS MAY BE PROGRAMMED IN A SMALL FRACTION
; OF THE TIME IT WOULD TAKE UNDER WORST CASE CONDITIONS, THEREFORE
; GREATLY REDUCING PROGRAMMING TIME FOR MOST PROMS. THE WIDE VARIATION
; IN TIMES QUATED IS DUE TO THE ALLOWABLE RANGE BETWEEN BEST AND WORST
; CASE PROGRAMMING TIMES.
;
PROG:
          INR       C
          CALL      EXPR                ; HL = TOP AFTER RETURN
          DCR       L
          MOV       C,M                 ; PROM ADDRESS
          DCR       L
          DCR       L                   ; HL = TOP - 3
          MOV       E,M                 ; LSB OF HIGH ADDRESS
          DCR       L
          MOV       D,M                 ; MSB OF HIGH ADDRESS
          DCR       L
          MOV       B,M                 ; LSB OF LOW ADDRESS
          DCR       L
          MOV       H,M                 ; MSB OF LOW ADDRESS
          MOV       L,B
          MOV       A,E
          SUB       L
          MOV       E,A                 ; COUNT
          INR       E                   ; ADJUST SO 256 = 0
          MOV       A,D
          SBB       H
          JC        LER                 ; CARRY = ERROR
PR0:
          MVI       A,ENB
          OUT       PROMC               ; ENABLE PROM PROGRAMMER
          MOV       A,C
          XRI       0FFH
          OUT       PAD                 ; PROM ADDRESS
          IN        PDI                 ; READ VALUE
          XRI       0FFH
          CMP       M                   ; COMPARE WITH DESIRED
          JZ        PR4                 ; DON'T HAVE TO PROGRAM THE LOCATION
          MVI       D,-16               ; SET MAX TRIES = 16
PR1:
          CALL      PGRM                ; PULSE AND DELAY 20 MS
          IN        PDI                 ; READ VALUE
          XRI       0FFH                
          CMP       M                   ; COMPARE WITH DESIRED
          JZ        PR2                 ; GOT IT, NOW PULSE 3*N MORE TIMES
          INR       D                   ; INCREMENT COUNTER
          JNZ       PR1                 ; KEEP GOING
          CALL      CRLF
          MVI       B,'$'               ; ERROR OUT
          CALL      CO
          CALL      BLK                 ; OUTPUT A SPACE
          MOV       A,C                 ; DISPLAY PROM ADDRESS
          CALL      LBYTE
          JMP       LER                 ; BAD PROM, ABORT
PR2:
          MOV       A,D                 ; MOVE COUNT RESIDUE TO A
          ADI       17                  ; ACTUAL COUNT OF TRIES REQUIRED
          ADD       A                   ; COUNT = COUNT * 2
          ADD       A                   ; COUNT = COUNT * 4
          MOV       D,A
PR3:                                    ; OVERPROGRAM 4*N TIMES
          CALL      PGRM
          DCR       D
          JNZ       PR3
PR4:
          INR       C                   ; BUMP PROM ADDRESS
          JZ        START               ; PROM ADDRESS ROLLOVER, TERMINATE
          CALL      INCHL               ; BUMP MEMORY ADDRESS
          DCR       E                   ; DECREMENT COUNT
          JNZ       PR0                 ; CONTINUE WITH PROGRAMMING
          JMP       START
;
; READ ROUTINE.
;
; THIS ROUTINE READS A HEXADECIMAL FILE FROM THE ASSIGNED
; READER DEVICE AND LOADS IT INTO MEMORY. ONE HEXADECIMAL 
; PARAMETER IS EXPECTED. THIS PARAMETER IS A BIAS ADDRESS
; TO BE ADDED TO THE MEMORY ADDRESS OF EACH DATA BYTE ENCOUNTERED.
; IN THIS WAY, HEXADECIMAL FILES MAY BE LOADED INTO MEMORY 
; IN AREAS OTHER THAN THOSE FOR WHICH THEY WERE ASSEMBLED OR COMPILED.
; ALL RECORDS READ ARE CHECKSUMMED AND COMPARED AGAINST THE 
; CHECKSUM IN THE RECORD. IF A CHECKSUM ERROR (OR TAPE READ ERROR)
; OCCURS, THE ROUTINE TAKES AN ERROR EXIT. NORMAL LOADING IS 
; TERMINATED WHEN A RECORD OF LENGTH 0 IS ENCOUNTERED. THIS IS
; INTERPRETED AS AN END OF FILE RECORD AND THE LOAD ADDRESS
; FIELD OF THAT RECORD IS TAKEN TO BE THE ENTRY POINT OF THE 
; PROGRAM (IF IT IS NON-ZERO).
; 
READ:
          DCR       C                   ; GET ONE ADDRESS
          CALL      EXPR
RED0:
          CALL      RIX
          MVI       B,':'
          SUB       B
          JNZ       RED0                ; SCAN TO RECORD MARK
          MOV       D,A                 ; CLEAR CHECKSUM
          CALL      BYTE
          JZ        RED2                ; ZERO RECORD LENGTH, ALL DONE
          MOV       E,A                 ; E <- RECORD LENGTH
          CALL      BYTE                ; GET MSB OF LOAD ADDRESS
          LXI       H,ADR2
          MOV       M,A                 ; SAVE IT
          CALL      BYTE                ; GET LSB OF LOAD ADDRESS
          LXI       H,ADR2+1
          MOV       M,A
          CALL      BYTE                ; RECORD TYPE
          LXI       H,ADR2+1
          MOV       A,M
          MVI       L,(ADR1+1) & 0FFH
          ADD       M
          MOV       C,A
          DCR       L
          MOV       A,M
          MVI       L,ADR2 & 0FFH
          ADC       M
          LXI       H,HPRIME
          MOV       M,A
          INR       L
          MOV       M,C
RED1:
          CALL      BYTE                ; READ DATA
          LXI       H,HPRIME
          MOV       C,M
          INR       L
          MOV       L,M
          MOV       H,C
          MOV       M,A                 ; PUT IN MEMORY
          CALL      INCHL
          MOV       B,H
          MOV       C,L
          LXI       H,HPRIME
          MOV       M,B
          INR       L
          MOV       M,C
          DCR       E
          JNZ       RED1                ; LOOP UNTIL DONE
          CALL      BYTE                ; READ CHECKSUM
          JNZ       LER                 ; CHECKSUM ERROR
          JMP       RED0                ; GET ANOTHER RECORD
RED2:
          CALL      BYTE                ; GET MSB OF TRANSFER ADDRESS
          MOV       E,A
          CALL      BYTE
          MOV       D,E
          MOV       E,A
          ORA       D
          JNZ       GO                  ; TAKE THE BRANCH
          JMP       START
;
; SUBSTITUTE MEMORY CONTENTS ROUTINE
;
; THIS ROUTINE EXPECTS ONE PARAMETER FROM THE CONSOLE, FOLLOWED 
; BY A SPACE. THE PARAMETER IS INTERPRETED AS A MEMORY LOCATION 
; AND THE ROUTINE WILL DISPLAY THE CONTENTS OF THAT LOCATION,
; FOLLOWED BY A DASH (-). TO MODIFY MEMORY, TYPE IN THE NEW DATA
; FOLLOWED BY A SPACE OR A CARRIAGE RETURN.  IF NO MODIFICATION 
; OF THE LOCATION IS REQUIRED, TYPE ONLY A SPACE OR CARRIAGE RETURN.
; IF A SPACE WAS LAST TYPED, THE NEXT MEMORY LOCATION WILL BE DISPLAYED
; AND MODIFICATION OF IT IS ALLOWED. IF A CARRIAGE RETURN WAS ENTERED 
; THE COMMAND IS TERMINATED.
;
SUBS:
          DCR       C
          CALL      EXPR                ; GET ONE ADDRESS
          CPI       CR
          JZ        START
          CALL      GETAD
SU0:
          MOV       A,M
          CALL      LBYTE               ; DISPLAY DATA
          MVI       B,'-'
          CALL      CO
          CALL      TI
          CPI       ' '
          JZ        SU1
          CPI       ','
          JZ        SU1
          CPI       CR
          JZ        START
          MVI       C,1
          MVI       E,0
          LXI       H,HPRIME
          MVI       M,ADR2 >> 8
          INR       L
          MVI       M,ADR2 & 0FFH
          CALL      EX1
          CALL      GETAD
          MOV       M,E
          CPI       CR                  ; TEST DELIMITER
          JZ        START               ; CR ENTERED AFTER LAST SUBSTITUTION
SU1:
          CALL      GETAD
          CALL      INCHL
          CALL      SAVIT
          CALL      GETAD
          JMP       SU0
;
; TRANSFER CONTENTS OF A PROM TO MEMORY.
;
; THIS ROUTINE EXPECTS ONE HEXADECIMAL PARAMETER WHICH 
; IT INTERPRETS AS THE LOCATION IN MEMORY WHERE A COPY OF THE 
; PROM IN THE FRONT PANEL IS TO BE STORED. THIS COPY IS ALWAYS
; 256 BYTES IN LENGTH.
;
TRAN:
          DCR       C
          CALL      EXPR                ; GET ONE ADDRESS
          MVI       A,ENB               ; ENABLE PROM PROGRAMMER
          OUT       PROMC
          CALL      GETAD               ; HL = MEM ADR
          MVI       E,0                 ; COUNT PROM ADDRESS
TR0:
          MOV       A,E
          XRI       0FFH                ; INVERT ADDRESS
          OUT       PAD                 ; SET PROM ADDRESS
          CALL      DELAY               ; WAIT FOR 6-76 BOARD TO LATCH DATA
          IN        PDI                 ; GET PROM DATA
          XRI       0FFH
          MOV       M,A                 ; PUT IN MEMORY
          CALL      INCHL               ; BUMP MEMORY POINTER
          INR       E                   ; BUMP PROM POINTER
          JNZ       TR0                 ; GET ANOTHER BYTE
          JMP       START
;
; WRITE ROUTINE.
;
; THIS ROUTINE EXPECTS TWO HEXADECIMAL PARAMETERS WHICH ARE 
; INTERPRETED AS THE BOUNDS OF A MEMORY AREA TO BE ENCODED 
; INTO HEXADECIMAL FORMANT AND PUNCHED ON THE ASSIGNED PUNCH
; DEVICE.
;
WRITE:
          CALL      EXPR                ; GET TWO ADDRESSES
WRI0:
          CALL      GETAD
          MOV       A,L
          ADI       16
          MOV       C,A
          MOV       A,H
          ACI       0
          MOV       B,A
          MOV       A,E
          SUB       C
          MOV       C,A
          MOV       A,D
          SBB       B
          JM        WRI1                ; RECORD LENGTH = 16
          MVI       A,16
          JMP       WRI2
WRI1:
          MOV       A,C
          ADI       17
WRI2:
          ORA       A
          JZ        START
          MOV       E,A                 ; E <- RECORD LENGTH
          MVI       D,0                 ; CLEAR CHECKSUM
          CALL      PEOL
          MVI       B,' '
          CALL      PO
          MVI       B,':'
          CALL      PO
          MOV       A,E
          CALL      PBYTE               ; PUNCH LENGTH
          LXI       H,ADR1              
          MOV       A,M
          CALL      PBYTE               ; PUNCH MSB OF ADDRESS
          LXI       H,ADR1+1
          MOV       A,M
          CALL      PBYTE               ; PUNCH LSB OF ADDRESS
          XRA       A
          CALL      PBYTE               ; PUNCH RECORD TYPE
WRI3:
          LXI       H,ADR1
          MOV       A,M
          INR       L
          MOV       L,M
          MOV       H,A
          MOV       A,M
          CALL      INCHL
          MOV       B,H
          MOV       C,L
          LXI       H,ADR1
          MOV       M,B
          INR       L
          MOV       M,C
          CALL      PBYTE               ; PUNCH DATA
          DCR       E
          JNZ       WRI3
          XRA       A
          SUB       D
          CALL      PBYTE               ; PUNCH CHECKSUM
          JMP       WRI0
;
; ERROR EXIT
; 
; THIS ABNORMAL EXIT IS EXECUTED FOR ALL MONITOR ERROR CONDITIONS.
;
LER:
          MVI       B,'*'
          CALL      CO
          JMP       START
;
; SUBROUTINES
;
BLK:
          MVI       B,' '               ; PRINT A BLANK
;
; EXTERNALLY REFERENCED ROUTINE
; CONSOLE OUTPUT CODE. VALUE EXPECTED IN B
; A,B,H,L, AND FLAGS MODIFIED
; STACK USAGE: 2 BYTES
;
CO:                                     ; CONSOLE OUTPUT
          LXI       H,IOBYT
          MOV       A,M                 ; GET STATUS BYTE
          ANI       00000011B ;~CMSK            ; GET CONSOLE BITS
          JNZ       CO0                 ; TEST FOR CRT
TTYOUT:
          IN        TTS                 ; CONSOLE = TTY
          ANI       TTYBE
          JNZ       TTYOUT              ; LOOP UNTIL READY
          MOV       A,B
          XRI       0FFH
          OUT       TTO                 ; OUTPUT CHARACTER
          RET                           ; RETURN
CO0:
          CPI       CCRT                ; CONSOLE = CRT?
          JNZ       CO1                 ; TEST FOR BATCH
CRTOUT:
          IN        CRTS                ; CONSOLE = CRT
          ANI       CRTBE
          JNZ       CRTOUT              ; LOOP UNTIL READY
          MOV       A,B
          XRI       0FFH
          OUT       CRTO
          RET
CO1:
          CPI       BATCH
          JZ        LO                  ; BATCH MODE, OUTPUT = LIST
          JMP       COLOC               ; BRANCH TO USER CONSOLE OUTPUT
;
; READ TWO ASCII CHARACTERS, DECODE INTO 8 BITS BINARY
;
BYTE:
          CALL      RIX                 ; READ CHAR FROM TAPE
          CALL      NIBBLE              ; CONVERT ASCII TO HEX
          RLC
          RLC
          RLC
          RLC                           ; SHIFT FOUR PLACES
          MOV       C,A
          CALL      RIX
          CALL      NIBBLE              ; GET LOWER NIBBLE
          ORA       C
          MOV       C,A
          ADD       D                   ; UPDATE CHECKSUM
          MOV       D,A
          MOV       A,C
          RET                           ; RETURN
;
; EXTERNALLY REFERENCED ROUTINE
; CONSOLE INPUT CODE, VALUE RETURNED IN A
; A,B,H,L, AND FLAGS MODIFIED
; STACK USAGE: 2 BYTES
;
CI:                                     ; CONSOLE INPUT
          LXI       H,IOBYT
          MOV       A,M                 ; GET STATUS BYTE
          ANI       00000011B ;~CMSK               ; GET CONSOLE BITS
          JNZ       CI1                 ; TEST FOR CRT
TTYIN:
          IN        TTS                 ; TTY STATUS PORT
          ANI       TTYDA               ; CHECK FOR DATA AVAILABLE
          JNZ       TTYIN
          IN        TTI                 ; READ THE CHARACTER
CI0:
          XRI       0FFH
          RET
CI1:
          CPI       CCRT                ; CONSOLE = CRT?
          JNZ       CI2                 ; TEST FOR BATCH
CRTIN:
          IN        CRTS                ; CRT STATUS PORT
          ANI       CRTDA               ; CHECK FOR DATA AVAILABLE
          JNZ       CRTIN               ; NOT READY, CONTINUE LOOPING
          IN        CRTI                ; READ THE CHARACTER
          JMP       CI0
CI2:
          CPI       BATCH
          JZ        RI                  ; BATCH MODE, INPUT = READER
          JMP       CILOC               ; CONSOLE = USER DEVICE
;
; CONVERT 4 BIT HEX VALUE TO ASCII CHARACTER
;
CONV:
          CPI       10
          JM        CN0                 ; LESS THAN 10 (0-9)
          ADI       'A'-'0'-10          ; ADJUST OF (A-F)
CN0:
          ADI       '0'                 ; ADD BIAS FOR ASCII
          MOV       B,A
          RET                           ; RETURN
;
; TYPE CARRIAGE RETURN AND LINE FEED ON CONSOLE
;
CRLF:
          MVI       B,CR                ; <CR>
          CALL      CO
          MVI       B,LF                ; <LF>
          JMP       CO
;
; EXTERNALLY REFERENCED ROUTINE.
; CONSOLE INPUT STATUS CODE
; A,FLAGS MODIFIED
; STACK USAGE: 2 BYTES
;
CSTS:                                   ; CONSOLE INPUT STATUS
          LXI       H,IOBYT
          MOV       A,M                 ; GET STATUS BYTE
          ANI       00000011B ;~CMSK            ; CONSOLE = TTY?
          JNZ       CS0                 ; CONSOLE = CRT
          IN        TTS                 ; GET TTY STATUS
          JMP       CS1
CS0:
          CPI       CCRT
          JNZ       CS3
          IN        CRTS                ; GET CRT STATUS
CS1:
          ANI       TTYDA
          MVI       A,FALSE             ; RETURN FALSE IF NO DATA AVAILABLE
CS2:
          RNZ
          XRI       0FFH
          RET                           ; RETURN
CS3:
          CPI       BATCH
          MVI       A,TRUE
          JZ        CS2
          JMP       CSLOC
;
; READ BNPF TAPE RECORD, BUILD BYTE, STORE IN C-REGISTER
; IF ERROR ABORT COMMAND
;
DECODE:
          CALL      RIX                 ; READ TAPE
          CPI       'B'                 ; SCAN FOR 'B'
          JNZ       DECODE
          MVI       C,1                 ; INITIALIZE MEMORY
DC0:
          CALL      RIX                 ; GET DATA
          CPI       'N'                 ; CHECK FOR 'N'
          JNZ       DC2                 ; NO, CHECK FOR 'P'
                                        ; CARRY = 0
DC1:
          MOV       A,C                 ; SHIFT IN DATA BIT
          RAL
          MOV       C,A
          JNC       DC0                 ; IF CARRY IS SET, 8 BITS READ
          CALL      RIX                 ; TEST FOR REQ'D 'F'
          CPI       'F'
          JNZ       LER
          RET                           ; RETURN
DC2:
          ADI       -'P'
          JNZ       LER                 ; ERROR
          JMP       DC1                 ; CARRY IS SET
;
; 1.0 MS DELAY (INCLUDING CALL, DCR OR INC, AND JUMP IN CALLING LOOP)
;
DELAY:
          MVI       B,DLY
DL0:
          DCR       B
          JNZ       DL0
          RET                           ; RETURN
;
; CONVERT BINARY NUMBER TO A STRING OF ASCII DIGITS
; HL = BINARY NUMBER
; DE = DIVISOR (DESCENDING POWERS OF 10)
; C = LEADING ZERO SUPPRESSION CHARACTER
; A,B = TEMPORARIES
DIGIT:
          MVI       B,'0'               ; INITIALIZE CHARACTER
DG0:
          MOV       A,L                 ; SUB DENOM (DE) FROM NUMERATOR (HL)
          SUB       E
          MOV       L,A
          MOV       A,H
          SBB       D
          MOV       H,A
          JC        DG1                 ; NEGATIVE RESULT, ALL DONE
          INR       B                   ; COUNT NUMBER OF SUBTRACTS
          JMP       DG0
DG1:
          MOV       A,L
          ADD       E
          MOV       L,A
          MOV       A,H
          ADC       D
          MOV       H,A
          MOV       A,B
          CPI       '0'                 ; CHECK FOR LEADING ZERO SUPPRESSION
          JNZ       DG3
          MOV       B,C
DG2:
          MOV       D,H
          MOV       E,L
          CALL      PO
          MOV       H,D
          MOV       L,E
          RET                           ; PUNCH CHARACTER
DG3:
          MVI       C,'0'
          JMP       DG2
;
; ENCODE A BPNF WORD AND PUNCH IT
;
ENCODE:
          MOV       D,H                 ; SAVE HL
          MOV       E,L
          MVI       B,'B'               ; PUNCH A 'B'
          CALL      PO
          MVI       C,8                 ; 8 BIT COUNT
EN0:
          MOV       H,D
          MOV       L,E
          MVI       A,9
          SUB       C
          MOV       B,A
          MOV       A,M
EN1:
          RLC
          DCR       B
          JNZ       EN1
          JNC       EN3
          MVI       B,'P'
EN2:
          CALL      PO
          DCR       C
          JNZ       EN0
          MVI       B,'F'
          CALL      PO
          MVI       B,' '
          JMP       PO
EN3:
          MVI       B,'N'
          JMP       EN2
;
; EVALUATE EXPRESSION: <EXPR>,<EXPR>,<EXPR>
;
EXPR:
          MOV       D,H                 ; SAVE HL
          MOV       E,L
          LXI       H,HPRIME
          MOV       M,D
          INR       L
          MOV       M,E
          MVI       D,0                 ; D,E = 0
          MOV       E,D
EX0:
          CALL      TI                  ; GET A CHARACTER
EX1:
          MOV       B,A
          CALL      NIBBLE              ; CONVERT TO HEX
          JC        EX2                 ; NOT LEGAL CHAR, TREAT AS DELIMITER
          MOV       B,A
          CALL      SLDE
          CALL      SLDE
          CALL      SLDE
          CALL      SLDE
          MOV       A,B
          ORA       E
          MOV       E,A
          JMP       EX0                 ; GET ANOTHER CHARACTER
EX2:
          LXI       H,HPRIME
          MOV       A,M
          INR       L
          MOV       L,M
          MOV       H,A
          MOV       M,D                 ; PUT MSB IN MEMORY
          INR       L
          MOV       M,E                 ; PUT LSB IN MEMORY
          INR       L
          MOV       A,B                 ; RESTORE DELIMITER
          CPI       ','
          JZ        EX3
          CPI       ' '
          JZ        EX3
          CPI       CR
          JNZ       LER
          DCR       C
          JNZ       LER
          RET
EX3:
          DCR       C
          JNZ       EXPR
          RET
;
; GET ADDRESS FROM MEMORY AND PUT IN HL AND DE
;
GETAD:
          LXI       H,ADR1              ; ADDRESS OF FIRST PARAMETER
          MOV       B,M                 ; MSB OF LOW ADDRESS
          INR       L
          MOV       C,M                 ; LSB OF LOW ADDRESS
          INR       L
          MOV       D,M                 ; MSB OF HIGH ADDRESS
          INR       L
          MOV       E,M                 ; LSB OF HIGH ADDRESS
          MOV       H,B                 ; RESET HL
          MOV       L,C
          RET
;
; COMPARE HL WITH DE:
; IF HL < DE THEN CARRY = 0;
; IF HL = DE THEN CARRY = 0;
; IF HL > DE THEN CARRY = 1;
;
HILO:
          CALL      INCHL               ; BUMP HL
          MOV       A,E                 ; DE - HL, SET/RESET CARRY
          SUB       L
          MOV       A,D
          SBB       H
          RET                           ; RETURN
;
; CONVERT NIBBLE IN A-REGISTER TO ASCII IN A-REGISTER
; AND PRINT ON TELEPRINTER
;
HXD:
          CALL      CONV
          JMP       CO
;
; INCREMENT H AND L
;
INCHL:
          INR       L
          RNZ
          INR       H
          RET
;
; EXTERNALLY REFERENCED ROUTINE
; I/O SYSTEM STATUS CODE
; STATUS BYTE RETURNED IN A
; STACK USAGE: 2 BYTES
;
IOCHK:
          LXI       H,IOBYT
          MOV       A,M                 ; GET STATUS BYTE
          RET                           ; RETURN
;
; EXTERNALLY REFERENCED ROUTINE
; SET I/O CONFIGURATION
; VALUE EXPECTED IN B
; STACK USAGE: 2 BYTES
;
IOSET:
          LXI       H,IOBYT             ; POINT HL AT IOBYT
          MOV       M,B
          RET                           ; RETURN
;
; PRINT CONTENTS OF HL IN HEX ON CONSOLE DEVICE
;
LADR:
          MOV       D,H
          MOV       E,L
          MOV       A,D
          CALL      LBYTE
          MOV       A,E
          CALL      LBYTE
          CALL      BLK
          MOV       H,D
          MOV       L,E
          RET
;
; LIST A BYTE AS 2 ASCII CHARACTERS
;
LBYTE:
          MOV       C,A                 ; SAVE A COPY OF A
          RRC
          RRC
          RRC
          RRC
          ANI       0FH                 ; UPPER 4 BITS
          CALL      HXD
          MOV       A,C                 ; RETRIEVE ORIGINAL VALUE
          ANI       0FH                 ; LOWER 4 BITS
          JMP       HXD
;
; PUNCH 6 INCHES OF LEADER
;
LEAD:
          MVI       C,60                ; SET TO PUNCH 6 INCHES OF NULLS
LE0:
          MVI       B,0
          CALL      PO
          DCR       C
          JNZ       LE0
          RET                           ; RETURN
;
; EXTERNALLY REFERENCED ROUTINE
; LIST OUTPUT CODE
; VALUE EXPECTED IN B
; A,B,H,L, AND FLAGS MODIFIED
; STACK USAGE: 2 BYTES
;
LO:                                     ; LIST OUTPUT
          LXI       H,IOBYT             
          MOV       A,M                 ; GET STATUS BYTE
          ANI       ~LMSK            ; GET LIST BITS
          JZ        TTYOUT              ; LIST = TTY
          CPI       LCRT
          JZ        CRTOUT              ; LIST = CRT
          CPI       LUSE1               ; TEST FOR USER DEFINED LIST DEVICE
          JZ        L1LOC               ; BRANCH TO USER DEVICE
          JMP       L2LOC               ; ELSE BRANCH TO USER LIST 2
;
; EXTERNALLY REFERENCED ROUTINE
; RETURN ADDRESS OF END OF MEMORY TO USER
; A,B,C,H,L, AND FLAGS MODIFIED
; VALUE RETURNED IN (C,A)
; STACK USAGE: 2 BYTES
;
MEMCK:
          LXI       H,0
M0:
          MOV       B,M
          MVI       M,0AAH
          MOV       A,M
          MOV       M,B
          INR       H
          CPI       0AAH
          JZ        M0
          DCR       H
          DCR       H
          DCR       L
          MOV       A,L
          MOV       C,H
          RET
;
; DECODE ASCII CHAR IN A-REGISTER INTO HEX DIGIT IN A-REGISTER
; FILTER OUT ALL CHARACTERS NOT IN THE SEQUENCE (0...9,A...F).
; RETURN CARRY = 1 FOR ILLEGAL CHARACTERS
;
NIBBLE:
          SUI       '0'
          RC
          ADI       '0'-'G'
          RC
          ADI       6
          JP        NI0
          ADI       7
          RC
NI0:
          ADI       10
          ORA       A
          RET                           ; RETURN
;
; DISREGARD NOISE CHARACTERS
;
NOISE:
          CALL      TI
          CPI       '='
          JNZ       NOISE
NO0:
          CALL      TI
          CPI       ' '
          JZ        NO0
          RET                           ; RETURN
;
; PUNCH A BYTE AS 2 ASCII CHARACTERS
;
PBYTE:
          MOV       C,A
          RRC
          RRC
          RRC
          RRC
          ANI       0FH
          CALL      CONV
          CALL      PO
          MOV       A,C
          ANI       0FH
          CALL      CONV
          CALL      PO
          MOV       A,C
          ADD       D
          MOV       D,A
          RET                           ; RETURN
;
; PUNCH CR,LF
;
PEOL:
          MVI       B,CR
          CALL      PO
          MVI       B,LF
          JMP       PO
;
; PULSE A PROM LOCATION
; HL POINTS TO DATA IN MEMORY
; PROM ADDRESS IS ALREADY SET
;
PGRM:
          MOV       A,M                 ; GET DATA FROM MEMORY
          XRI       0FFH                ; INVERT IT
          OUT       PDO                 ; OUTPUT IT
          MVI       A,PROGO             ; PULSE FROM PROGRAMMER
          OUT       PROMC
          MVI       A,PRONO
          OUT       PROMC
          MOV       A,D                 ; SAVE D
          MVI       D,LDLY              ; DELAY 20 MS. FOR PROGRAMMER SETTLING
PG0:
          CALL      DELAY
          DCR       D
          JNZ       PG0
          MOV       D,A
          RET
;
; EXTERNALLY REFERENCED ROUTINE
; PUNCH OUTPUT CODE, VALUE EXPECTED IN B
; A,B,H,L, AND FLAGS MODIFIED
; STACK USAGE: 2 BYTES
;
PO:                                     ; PUNCH OUTPUT
          LXI       H,IOBYT
          MOV       A,M                 ; GET STATUS BYTE
          ANI       00110000B;~PMSK               ; GET PUNCH BITS
          JZ        TTYOUT              ; NO, PUNCH = TTY
          CPI       PPTP                ; TEST FOR PTP
          JNZ       PO1                 ; TEST FOR USER DEVICE(S)
PO0:                                    ; PUNCH = PTP
          IN        PTPS                ; GET STATUS
          ANI       PRDY                ; CHECK STATUS
          JZ        PO0                 ; LOOP UNTIL READY
          MOV       A,B
          OUT       PTPO
          MVI       A,PTPGO             ; START PUNCH
          OUT       PTPC
          MVI       A,PTPNO             ; STOP PUNCH
          OUT       PTPC
          RET
PO1:
          CPI       PUSE1
          JZ        P1LOC
          JMP       P2LOC
;
; EXTERNALLY REFERENCED ROUTINE
; READER INPUT CODE
; VALUE RETURNED IN A
; A,B,H,L, AND FLAGS MODIFIED
; STACK USAGE: 4 BYTES
;
RI:                                     ; READER INPUT
          LXI       H,IOBYT             ; POINT HL AT IOBYT
          MOV       A,M
          ANI       00001100B ; ~RMSK               ; READER = PTR?
          JNZ       RI3                 ; BRANCH TO PTR ROUTINE
          MVI       A,TTYGO             ; READER = TTY
          OUT       TTC
          MVI       A,TTYNO
          OUT       TTC
          MVI       H,TOUT              ; SET TIMER FOR READER TIMEOUT
RI0:
          IN        TTS
          ANI       TTYDA
          JZ        RI2                 ; DATA IS READY
          CALL      DELAY               ; DELAY 1.0 MS
          DCR       H
          JNZ       RI0
RI1:
          ORA       A
          MVI       A,1
          RAR                           ; SET CARRY INDICATING EOF
          RET                           ; RETURN
RI2:
          IN        TTI
          XRI       0FFH                ; INVERT DATA, CLEAR CARRY
          RET                           ; RETURN
RI3:                                    ; PTR ROUTINE
          CPI       RPTR
          JNZ       RI6
          MVI       A,PTRGO
          OUT       PTRC
          MVI       A,PTRNO
          OUT       PTRC
          MVI       H,TOUT              ; SET TIMER FOR READER TIMEOUT
RI4:
          IN        PTRS
          ANI       PTRDA
          JNZ       RI5
          CALL      DELAY               ; DELAY 1.0 MS
          DCR       H
          JNZ       RI4
          JMP       RI1
RI5:
          IN        PTRI                ; GET THE DATA
          ORA       A                   ; CLEAR CARRY
          RET                           ; RETURN
RI6:
          CPI       RUSE1
          JZ        R1LOC
          JZ        R2LOC
;
; GET CHARACTER FROM READER, MASK OFF PARITY BIT
; 
RIX:
          CALL      RI
          JC        LER
          ANI       7FH
          RET                           ; RETURN
;
; SAVE HL AND DE IN MEMORY
;
SAVIT:
          MOV       B,H                 ; SAVE HL
          MOV       C,L
          LXI       H,ADR1              ; POINT TO FIRST PARAMETER
          MOV       M,B                 ; MSB OF LOW ADDRESS
          INR       L
          MOV       M,C                 ; LSB OF LOW ADDRESS
          INR       L
          MOV       M,D                 ; MSB OF HIGH ADDRESS
          INR       L
          MOV       M,E                 ; LSB OF HIGH ADDRESS
          RET
;
; SHIFT DE LEFT 1 PLACE
;
SLDE:
          MOV       A,E
          ADD       A
          MOV       E,A
          MOV       A,D
          ADC       A
          MOV       D,A
          RET
;
; INPUT FROM CONSOLE, ECHOED AND RETURNED IN A
;
TI:
          CALL      CI
          ANI       7FH
          MOV       B,A
          CALL      CO
          MOV       A,B
          RET                           ; RETURN
;
; I/O SYSTEM PHYSICAL DEVICE TABLES
; 2 BYTES/ENTRY
;   BYTE 0 = IDENTIFYING CHARACTER
;   BYTE 1 = DEVICE SELECT BIT PATTERN
;
ICT:
          DB        'T',CTTY            ; CONSOLE = TTY
          DB        'C',CCRT            ; CONSOLE = CRT
          DB        'B',BATCH           ; BATCH MODE CONSOLE = READ,LIST
          DB        '1',CUSE            ; USER DEFINED CONSOLE DEVICE
IRT:
          DB        'T',RTTY            ; READER = TTY
          DB        'P',RPTR            ; READER = PTR
          DB        '1',RUSE1           ; USER DEFINED READER DEVICE 1
          DB        '2',RUSE2           ; USER DEFINED READER DEVICE 2
OPT:
          DB        'T',PTTY            ; PUNCH = TTY
          DB        'P',PPTP            ; PUNCH = PTP
          DB        '1',PUSE1           ; USER DEFINED PUNCH DEVICE 1
          DB        '2',PUSE2           ; USER DEFINED PUNCH DEVICE 2
OLT:
          DB        'T',LTTY            ; LIST = TTY
          DB        'C',LCRT            ; LIST = CRT
          DB        '1',LUSE1           ; USER DEFINED LIST DEVICE 1
          DB        '2',LUSE2           ; USER DEFINED LIST DEVICE 2
;
; END OF PROGRAM
;
          END

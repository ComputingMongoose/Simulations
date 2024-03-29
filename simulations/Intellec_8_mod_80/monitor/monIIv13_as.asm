; Changes for assembling with MacroAssembler AS 1.42Beta
; - change "DATE" to "DATC" ("DATE" is a reserved symbol)
; - change "OR" to "|"
; - change "NOT" to "~"
; - change "AND" to "&"
; - change NOT CMSK to NCMSK (the symbol was added)
; - change NOT RMSK to NRMSK (the symbol was added)
; - change NOT PMSK to NPMSK (the symbol was added)
; - change "MOD" to "#"
; - change "TRUE"/"FALSE" to "MTRUE"/"MFALSE" (TRUE and FALSE are predefined symbols)
;
; - corrected USCS and USCC to F7
; - corrected IICP0 to FB


		;************************************************************************
		;*                                                                      *
		;*                  INTELLEC SERIES II BOOT/MONITOR        9800605B     *
		;*                                 VERSION 1.3                          *
		;*                                                                      *
		;* COPYRIGHT (C) 1978, 1979 INTEL CORPORATION. ALL RIGHTS               *
		;* RESERVED. NO PART OF THIS PROGRAM OR PUBLICATION                     *
		;* MAY BE REPRODUCED, TRANSMITTED, TRANSCRIBED,                         *
		;* STORED IN A RETRIEVAL SYSTEM, OR TRANSLATED INTO                     *
		;* ANY LANGUAGE OR COMPUTER LANGUAGE, IN ANY FORM                       *
		;* OR BY ANY MEANS, ELECTRONIC, MECHANICAL, MAGNETIC,                   *
		;* OPTICAL, CHEMICAL, MANUAL OR OTHERWISE, WITHOUT                      *
		;* THE PRIOR WRITTEN PERMISSION OF INTEL CORPORATION,                   *
		;* 3065 BOWERS AVENUE, SANTA CLARA, CALIFORNIA 95051.                   *
		;*                                                                      *
		;************************************************************************
		; <LEGAL COMMAND> ::=   <ASSIGN I/O COMMAND>
		;                       <DISPLAY MEMORY COMMAND>
		;                       <ENDFILE COMMAND>
		;                       <FILL MEMORY COMMAND>
		;                       <PROGRAM EXECUTE COMMAND>
		;                       <HEXADECIMAL ARITHMETIC COMMAND>
		;                       <MOVE MEMORY COMMAND>
		;                       <LEADER COMMAND>
		;                       <QUERY STATUS COMMAND>
		;                       <READ HEXADECIMAL FILE COMMAND>
		;                       <SUBSTITUTE MEMORY COMMAND>
		;                       <WRITE HEXADECIMAL RECORD COMMAND>
		;                       <REGISTER MODIFY COMMAND>
		;                       <TRANSFER CONTROL TO DIAGNOSTIC PROGRAM COMMAND>
		; <ASSIGN I/O COMMAND> ::= A<LOGICAL DEVICE>=<PHYSICAL DEVICE>
		; <DISPLAY MEMORY COMMAND> ::= D<NUMBER>,<NUMBER>
		; <ENDFILE COMMAND> ::= E<NUMBER>
		; <FILL MEMORY COMMAND> ::= F<NUMBER>,<NUMBER>,<NUMBER>
		; <PROGRAM EXECUTE COMMAND> ::= G<NUMBER>,<NUMBER>,<NUMBER>
		; <HEXADECIMAL ARITHMETIC COMMAND> ::= H<NUMBER>,<NUMBER>
		; <MOVE MEMORY COMMAND> ::= M<NUMBER>,<NUMBER>,<NUMBER>
		; <LEADER COMMAND> ::= N
		; <QUERY STATUS COMMAND> ::= Q
		; <READ HEXADECIMAL FILE COMMAND> ::= R<NUMBER>
		; <SUBSTITUTE MEMORY COMMAND> ::= S<NUMBER><COMMA>...
		; <WRITE HEXADECIMAL RECORD COMMAND> ::= W<NUMBER>,<NUMBER>
		; <REGISTER MODIFY COMMAND> ::= X<REGISTER IDENTIFIER><NUMBER>...
		; <TRANSFER CONTROL TO DIAGNOSTIC PROGRAM COMMAND> ::= Z$
		; <LOGICAL DEVICE> ::= LOCAL CONSOLE!READER!LIST!PUNCH
		; <PHYSICAL DEVICE> ::= CRT!TTY!PTR!PTP!LPT!BATCH!1!2
		; <REGISTER IDENTIFIER> ::= A!B!C!D!E!F!H!I!L!M!P!S
		; <NUMBER> ::= <HEX DIGIT>
		;              <NUMBER><HEX DIGIT>
		; <HEX DIGIT> ::= 0!1!2!3!4!5!6!7!8!9!A!B!C!D!E!F
		;*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*
		;$       TITLE   (' INTELLEC SERIES II MONITOR, VERSION 1.3, 1 MARCH 1979 ')
		        TITLE   " INTELLEC SERIES II MONITOR, VERSION 1.3, 1 MARCH 1979 "
VER     EQU     13      ; VERSION 1.3
VERH    EQU     13H     ; STORAGE REPRESENTATION OF VERSION
DATC    EQU     0103H   ; CREATION DATE, 01 MARCH 1979
		; NOTE:
		; THE DATE SHOWN ABOVE IS ENCODED IN A TWO BYTE FIELD IN BOTH THE BOOTSTRAP
		; PROM AND THE MONITOR PROM IN ORDER TO CONTROL NEW RELEASES OF THIS PROGRAM.
		; THE DATE CODE IS LOCATED AT ADDRESSES 0E804H AND 0E805H IN THE BOOTSTRAP
		; AND AT ADDRESSES 0F824H AND 0F825H IN THE MONITOR.
		; THE VERSION CODE IS LOCATED IN THE MONITOR ROM AT ADDRESS 0F82FH.
		; WHEN A NEW RELEASE IS ISSUED, PLEASE CHANGE THE DATE AND VERSION CODES.
		; THE COPYRIGHT NOTICE IS LOCATED IN THE MONITOR ROM BEGINNING AT 0F830H.
		;********************************************************************************
		;*                                                                              *
		;*                      SYMBOL DEFINITIONS                                      *
		;*                                                                              *
		;********************************************************************************
		;
		; INTELLEC SERIES II SYSTEM CONSTANTS
		;
		; INTEGRATED CONSOLE I/O PORTS
		;
CONI    EQU     0C0H            ; CONSOLE INPUT DATA PORT
CONO    EQU     0C0H            ; CONSOLE OUTPUT DATA PORT
CONS    EQU     0C1H            ; CONSOLE STATUS PORT
CONC    EQU     0C1H            ; CONSOLE CONTROL PORT
		;
		; SYSTEM BOOTSTRAP CONSTANTS (ISSUED TO PORT CPUC)
		;
DISABL  EQU     0DH             ; DISABLE INTERRUPTS
ENABL   EQU     05H             ; ENABLE INTERRUPTS
DISAXP  EQU     00H             ; DISABLE AUXILIARY PROM
		
ENAXP   EQU     08H             ; ENABLE AUXILIARY PROM
BOVROF  EQU     01H             ; TURN OFF BUS OVERRIDE
BOVRON  EQU     09H             ; TURN ON BUS OVERRIDE
BTDGOF  EQU     04H             ; TURN OFF BOOT/DIAGNOSTIC
BTDGON  EQU     0CH             ; TURN ON BOOT/DIAGNOSTIC
MOVBOT  EQU     02H             ; MOVE BOOT TO 0E800H
		;
		; SYSTEM I/O PORTS
		;
CPUS    EQU     0FEH            ; CPU STATUS PORT
CPUC    EQU     0FFH            ; CPU CONTROL PORT (CONTROLS BOOT & AUX.PROM)
		;
		; SYSTEM INTERRUPT CONSTANTS
		;
ICW1    EQU     00010010B       ; INITIALIZATION COMMAND WORD 1
ICW2    EQU     00000000B       ; INITIALIZATION COMMAND WORD 2
OCW3    EQU     00001011B       ; OPERATION COMMAND WORD 3
EOI     EQU     00100000B       ; END OF INTERRUPT
		;
		; SYSTEM INTERRUPT MASKS AND VALUES
		;
INT0    EQU     00000001B       ; MASK FOR INTERRUPT LEVEL 0
INT1    EQU     00000010B
INT2    EQU     00000100B
INT3    EQU     00001000B
INT4    EQU     00010000B
INT5    EQU     00100000B
INT6    EQU     01000000B
INT7    EQU     10000000B
INTA    EQU     00000000B       ; NO INTERRUPTS ALLOWED AT ALL
		;
		; SYSTEM INTERRUPT I/O PORTS
		;
SICP0   EQU     0FDH            ; INITIALIZATION COMMAND PORT 0
SICP1   EQU     0FCH            ; INITIALIZATION COMMAND PORT 1
SOCP0   EQU     0FDH            ; OPERATION COMMAND PORT 0
SOCP1   EQU     0FCH            ; OPERATION COMMAND PORT 1
		;
		; DEDICATED PROM PROGRAMMER CONSTANTS (USED IN C,P,T COMMANDS)
		;
PCOMP   EQU     00000010B       ; PROGRAMMING COMPLETE
PGRDY   EQU     00000001B       ; PROM READY
PSOCK   EQU     00100000B       ; 16 PIN SOCKET SELECTED
PNIB    EQU     00010000B       ; SELECT UPPER NIBBLE
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; INTELLEC SERIES II I/O SUBSYSTEM CONSTANTS
		;
		; TTY AND CRT MODE INSTRUCTION DEFINITIONS, I.E. USART MODE CONTROL
		; WORD (FIRST CONTROL BYTE AFTER RESET)
		;
R64X    EQU     00000011B       ; 64 X BAUD RATE
R16X    EQU     00000010B       ; 16 X BAUD RATE
R1X     EQU     00000001B       ; 1 X BAUD RATE
SYNC    EQU     00000000B       ; SYNC MODE
CL8     EQU     00001100B       ; CHARACTER LENGTH = 8
CL7     EQU     00001000B       ; CHARACTER LENGTH = 7
CL6     EQU     00000100B       ; CHARACTER LENGTH = 6
CL5     EQU     00000000B       ; CHARACTER LENGTH = 5
PENB    EQU     00010000B       ; PARITY ENABLE
PEVEN   EQU     00100000B       ; EVEN PARITY
ST2     EQU     11000000B       ; 2 STOP BITS
ST15    EQU     10000000B       ; 1.5 STOP BITS
ST1     EQU     01000000B       ; 1 STOP BIT
		;
		
		; TTY AND CRT COMMAND INSTRUCTION DEFINITIONS (USART COMMAND CONTROL WORD)
		;
TXEN    EQU     00000001B       ; TRANSMITTER ENABLE
DTR     EQU     00000010B       ; DATA TERMINAL READY
RXEN    EQU     00000100B       ; ENABLE RECEIVER
SBCH    EQU     00001000B       ; SEND BREAK CHARACTER
CLERR   EQU     00010000B       ; CLEAR ERROR
RTS     EQU     00100000B       ; SET REQUEST TO SEND OUTPUT  
USRST   EQU     01000000B       ; USART RESET - RETURN TO MODE CONTROL CYCLE
ENHM    EQU     10000000B       ; ENABLE HUNT MODE
		;
		; TTY/CRT STATUS WORD BIT DEFINITIONS
		;
TRDY    EQU     00000001B       ; TRANSMIT READY
RRDY    EQU     00000010B       ; RECEIVE BUFFER READY
TXBE    EQU     00000100B       ; TRANSMIT BUFFER EMPTY
RPAR    EQU     00001000B       ; RECEIVE PARITY ERROR
ROV     EQU     00010000B       ; RECEIVE OVERRUN ERROR
RFR     EQU     00100000B       ; RECEIVE FRAMING ERROR 
SYND    EQU     01000000B       ; SYNC DETECTED
DSR     EQU     10000000B       ; DATA SET READY INPUT
		;
		; TTY TAPE READER CONSTANTS
		;
RADCT   EQU     48              ; TTY TAPE READER ADVANCE TIMER COUNT
RTOCT   EQU     250             ; TTY TAPE READER TIMEOUT COUNT
TADV    EQU     TXEN | RXEN | RTS | DTR
COMD    EQU     TXEN | RXEN | RTS
		;
		; TTY I/O PORTS
		;
TTYI    EQU     0F4H            ; TTY INPUT DATA PORT
TTYO    EQU     0F4H            ; TTY OUTPUT DATA PORT
TTYS    EQU     0F5H            ; TTY INPUT STATUS PORT
TTYC    EQU     0F5H            ; TTY OUTPUT CONTROL PORT
		;
		; USER I/O PORTS
		;
USCI    EQU     0F6H            ; USER INPUT DATA PORT 
USCS    EQU     0F7H            ; USER INPUT STATUS PORT
USCO    EQU     0F6H            ; USER OUTPUT DATA PORT     
USCC    EQU     0F7H            ; USER OUTPUT CONTROL PORT
		;
		; INTERVAL TIMER CONSTANTS
		;
CTR0S   EQU     00000000B       ; COUNTER 0 SELECT
CTR1S   EQU     01000000B       ; COUNTER 1 SELECT
CTR2S   EQU     10000000B       ; COUNTER 2 SELECT
LCTR    EQU     00000000B       ; LATCHING COUNTER
RLMB    EQU     00100000B       ; READ/LOAD MSB ONLY
RLLB    EQU     00010000B       ; READ/LOAD LSB ONLY
RLLM    EQU     00110000B       ; READ/LOAD LSB,MSB
MODE0   EQU     00000000B       ; MODE 0
MODEl   EQU     00000010B       ; MODE 1
MODE2   EQU     00000100B       ; MODE 2
MODE3   EQU     00000110B       ; MODE 3
MODE4   EQU     00001000B       ; MODE 4
MODE5   EQU     00001010B       ; MODE 5
BCDC    EQU     00000001B       ; BCD COUNTER
B9600   EQU     7               ; 9600 BAUD RATE FACTOR
B2400   EQU     32              ; 2400 BAUD RATE FACTOR
B0110   EQU     698             ; 110 BAUD RATE FACTOR
		;
		; INTERVAL TIMER (8253) I/O PORTS
		;
CTR0P   EQU     0F0H            ; LOAD COUNTER 0 OUTPUT COMMAND PORT
CTR1P   EQU     0F1H            ; LOAD COUNTER 1 OUTPUT COMMAND PORT
CTR2P   EQU     0F2H            ; LOAD COUNTER 2 OUTPUT COMMAND PORT
ITCP    EQU     0F3H            ; INTERVAL TIMER OUTPUT COMMAND PORT
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; I/O CONTROLLER SYSTEM CONSTANTS
		;
		; I/O CONTROLLER PORTS
		;
IOCI    EQU     0C0H            ; I/O CONTROLLER INPUT DATA (FROM DBB) PORT
IOCO    EQU     0C0H            ; I/O CONTROLLER OUTPUT DATA (TO DBB) PORT
IOCS    EQU     0C1H            ; I/O CONTROLLER INPUT DBB STATUS PORT
IOCC    EQU     0C1H            ; I/O CONTROLLER OUTPUT CONTROL COMMAND PORT
		;
		; CRT, KEYBOARD, AND FLOPPY DISK COMMANDS
		;
CRTC    EQU     10H             ; CRT OUTPUT DATA COMMAND
CRTS    EQU     11H             ; CRT DEVICE STATUS COMMAND     
KEYC    EQU     12H             ; KEYBOARD. INPUT DATA COMMAND     
KSTS    EQU     13H             ; KEYBOARD DEVICE STATUS COMMAND
KINT    EQU     14H             ; RESERVED
WPBC    EQU     15H             ; FLOPPY PARAMETER BLOCK TRANSFER COMMAND
WPBCC   EQU     16H             ; FLOPPY PARAMETER BLOCK(CONT) TRANSFER COMMAND
WDBC    EQU     17H             ; FLOPPY DATA BLOCK OUTPUT COMMAND
WDBCC   EQU     18H             ; RESERVED
RDBC    EQU     19H             ; FLOPPY INPUT DATA BLOCK COMMAND
RDBCC   EQU     1AH             ; RESERVED
RRSTS   EQU     1BH             ; FLOPPY RESULT STATUS COMMAND
RDSTS   EQU     1CH             ; FLOPPY DEVICE STATUS COMMAND
		;
		; CRT, KEYBOARD, AND FLOPPY STATUS BITS
		;
KRDY    EQU     00000001B       ; KEYBOARD READY WITH DATA
FRDY    EQU     00000001B       ; FLOPPY READY FOR DATA
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; PARALLEL I/O SYSTEM CONSTANTS
		;
		; PARALLEL I/O PORTS
		;
PIOI    EQU     0F8H            ; PARALLEL I/O INPUT DATA (FROM DBB) PORT
PIOO    EQU     0F8H            ; PARALLEL I/O OUTPUT DATA (TO DBB) PORT
PIOS    EQU     0F9H            ; PARALLEL I/O INPUT DBB STATUS PORT
PIOC    EQU     0F9H            ; PARALLEL I/O OUTPUT CONTROL COMMAND PORT
		;
		; PTR, PTP, LPT AND UPP COMMANDS
		;
RDRC    EQU     010H            ; READER DATA TRANSFER COMMAND
PTRREV  EQU     01100000B       ; READER REVERSE DIRECTION 1 FRAME OPTION
PTRADV  EQU     01000000B       ; READER ADVANCE DIRECTION 1 FRAME OPTION
RSTC    EQU     011H            ; READER DEVICE STATUS COMMAND
PUNC    EQU     012H            ; PUNCH DATA TRANSFER COMMAND
PSTC    EQU     013H            ; PUNCH DEVICE STATUS COMMAND
LPTC    EQU     014H            ; LINE PRINTER DATA TRANSFER COMMAND
LSTC    EQU     015H            ; LINE PRINTER STATUS COMMAND
WPPC    EQU     016H            ; WRITE TO UPP COMMAND
RPPC    EQU     017H            ; READ FROM UPP COMMAND
RPSTC   EQU     018H            ; READ UPP STATUS COMMAND
		;
		; LPT, PTR AND PTP STATUS BITS
		;
LPTRY   EQU    00000001B        ; LPT READY
PTRDY   EQU    00000001B        ; PTR READY WITH DATA
PTPRY   EQU    00000001B        ; PTP READY FOR DATA
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; PARALLEL I/O AND I/O CONTROLLER SYSTEM COMMANDS
		;
PACIFY  EQU     00H             ; REINITIALIZE SYSTEM
ERESET  EQU     01H             ; ERROR RESET    
SYSTAT  EQU     02H             ; SYSTEM STATUS     
DSTAT   EQU     03H             ; DEVICE STATUS     
SRQDAK  EQU     04H             ; DEVICE SERVICE REQUEST ACK     
SRQACK  EQU     05H             ; SYSTEM SERVICE REQUEST ACK     
SRQ     EQU     06H             ; SERVICE REQUEST     
		;
		; PARALLEL I/O AND I/O CONTROLLER DIAGNOSTIC COMMANDS
		;
DECHO   EQU     07H             ; DATA ECHO TEST
CSMEM   EQU     08H             ; CHECKSUM MEMORY
TRAM    EQU     09H             ; TEST RAM
SINT    EQU     0AH             ; SYSTEM INTERRUPT CONTROL
		;
		;
		; PARALLEL I/O AND I/O CONTROLLER STATUS CONSTANTS
		;
OBF     EQU     00000001B       ; SLAVE OUTPUT BUFFER IS FULL
IBF     EQU     00000010B       ; SLAVE INPUT BUFFER IS FULL
F0      EQU     00000100B       ; FLAG 0 - SLAVE IS BUSY, MASTER IS LOCKED OUT
CNOTD   EQU     00001000B       ; DBB CONTAINS CONTROL INFO NOT DATA
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; FDCC (FLOPPY DISKETTE CHANNEL COMMAND) CONSTANTS
		;
OPCPL   EQU     4               ; DISK COMPLETION STATUS
LOWW    EQU     79H             ; LOW(IOPB)
HI      EQU     7AH             ; HIGH(IOPB)
RSTS    EQU     7BH             ; DISK RESULT STATUS INPUT PORT
DSTS    EQU     78H             ; DISK STATUS INPUT PORT
TRK0    EQU     3000H           ; FIRST ADDRESS OF DISK BOOTSTRAP
		;
		;       CONDITIONAL ASSEMBLY SWITCHES
		;
MFALSE   EQU     0
MTRUE    EQU     ~ MFALSE
HMSK    EQU     0FFH            ; SAFE MOVE OF 16 BITS INTO 8 8 BIT REGISTER
		;
		; GLOBAL CONSTANTS
		;
ONEMS   EQU     112             ; 1 MILLISECOND TIME CONSTANT
TOUT    EQU     250             ; 250 MS. COUNTER FOR READER TIMEOUT
CR      EQU     0DH             ; ASCII VALUE OF CARRIAGE RETURN
LF      EQU     0AH             ; ASCII VALUE OF LINE FEED
ETX     EQU     03H             ; MONITOR 8REAK CHARACTER (CONTROL C)
		;
		; MONITOR I/O STATUS BYTE MASKS AND VALUES
		;
CMSK    EQU     11111100B       ; MASK FOR LOCAL CONSOLE I/O
NCMSK   EQU     00000011B       ; ~ CMSK
RMSK    EQU     11110011B       ; MASK FOR READER INPUT
NRMSK    EQU    00001100B       ; ~ RMSK
PMSK    EQU     11001111B       ; MASK FOR PUNCH OUTPUT
NPMSK    EQU    00110000B       ; ~ PMSK
LMSK    EQU     00111111B       ; MASK FOR LIST OUTPUT
		;-----
CTTY    EQU     00000000B       ; LOCAL CONSOLE TTY
CCRT    EQU     00000001B       ; LOCAL CONSOLE CRT
BATCH   EQU     00000010B       ; BATCH MODE:
		                                ; CONSOLE INPUT READER, CONSOLE OUTPUT 
CUSE    EQU     00000011B       ; USER DEFINED LOCAL CONSOLE I/O
		;-----
RTTY    EQU     00000000B       ; READER = TTY
RPTR    EQU     00000100B       ; READER = PTR
RUSE1   EQU     00001000B       ; USER DEFINED READER (1)
RUSE2   EQU     00001100B       ; USER DEFINED READER (2)
		;-----
PTTY    EQU     00000000B       ; PUNCH = TTY
PPTP    EQU     00010000B       ; PUNCH = PTP
PUSE1   EQU     00100000B       ; USER DEFINED PUNCH (1)
PUSE2   EQU     00110000B       ; USER DEFINED PUNCH (2)
		;-----
LTTY    EQU     00000000B       ; LIST = TTY
LCRT    EQU     01000000B       ; LIST = CRT
LLPT    EQU     10000000B       ; LIST = LPT
LUSE    EQU     11000000B       ; USER DEFINED LIST
		;
		; LOCAL I/O SUBSYSTEM INTERRUPT PORTS
		;
IICP0   EQU     0FBH            ; INITIALIZATION COMMAND PORT 0
IICP1   EQU     0FAH            ; INITIALIZATION COMMAND PORT 1
IOCP0   EQU     0FBH            ; OPERATION COMMAND PORT 0
IOCP1   EQU     0FAH            ; OPERATION COMMAND PORT 1
		;
		; LOCAL INTERRUPT STATUS AND CONTROL BITS
		;
ITTYO   EQU     00000001B       ; TTY OUTPUT INTERRUPT
ITTYI   EQU     00000010B       ; TTY INPUT INTERRUPT
IPTP    EQU     00000100B       ; PTP OUTPUT INTERRUPT
IPTR    EQU     00001000B       ; PTR INPUT INTERRUPT
ICRTO   EQU     00010000B       ; CRT OUTPUT INTERRUPT
ICRTI   EQU     00100000B       ; CRT INPUT INTERRUPT
ILPT    EQU     01000000B       ; LPT OUTPUT INTERRUPT
MENB    EQU     10000000B       ; ENABLE MONITOR INTERRUPTS EXCEPT LEVEL 7
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; BOOTSTRAP CONSTANTS
		;
FSTOP   EQU     0E7H            ; FULL SYSTEM TOP OF MEMORY ADDRESS
FSTP    EQU     0F7H            ; FULL SYSTEM TOP PAGE ADDRESS
FDOC    EQU     004H            ; FLOPPY DISK OPERATION COMPLETE
ACHRM   EQU     07FH            ; ASCII CHARACTER MASK
ITIMO   EQU     0FFH            ; IOC TIMEOUT CONSTANT
LBMK    EQU     0FFH            ; LOWER BYTE MASK
ICFG    EQU     041H            ; CONSOLE CONFIGURATION STATUS
ICNP    EQU     001H            ; INTEGRATED CONSOLE NOT PRESENT STATUS
LSTE    EQU     040H            ; LIST DEVICE VALUE FOR CONSOLE
RTCC    EQU     1229            ; REAL TIME CLOCK IMS CONSTANT
DPRNT   EQU     08H             ; DISK READY MASK
TRKL    EQU     26*128          ; TRACK LENGTH
PARML   EQU     4               ; PARAMETER LENGTH - 1
COP     EQU     0F809H          ; ENTRY�POINT FOR CONSOLE OUT
IOCDP1  EQU     0F821H          ; ENTRY POINT FOR IOC DRIVER 1
IOCDP2  EQU     0F844H          ; ENTRY POINT FOR IOC DRIVER 2
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; PAGE 0 DEDICATED RAM LOCATIONS, INITIALIZED BY BOOTSTRAP PROM CODE.
		;
        ORG     0
		RESET:
        DS      3               ; TRAP TO MONITOR RESTART
		IOBYT:
        DS      1               ; I/O SYSTEM STATUS BYTE
		MEMTOP:
        DS      2               ; TOP OF RAM, ONLY H SAVED
		INITIO:
        DS      1               ; INITIAL I/O CONFIGURATION
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; BOOTSTRAP PROM CODE
		;
		;BBASE   SET     0E800H
BBASE   EQU     0E800H
        ORG     BBASE
        JMP     BS0             ; BRANCH AROUND DATE CODE BYTE
		INIT:
	        DB      0               ; INITIALLY
		                                ; CONSOLE = TTY,
		                                ; READER = TTY,
		                                ; PUNCH = TTY,
		                                ; LIST = TTY
        DW      DATC            ; DATE STAMP FOR BOOTSTRAP PROM
		;
		; FUNCTIONS:
		;
		;       A. INITIALIZE INTERRUPT SYSTEM AND REAL TIME CLOCK
		;               0. INITIALIZE PORT 0FFH (CPUC)
		;               1. PROGRAM SYSTEM INTERRUPTS (8259)
		;               2. MASK ALL SYSTEM INTERRUPTS BUT TRAP LOGIC
		;               3. PROGRAM I/O SUBSYSTEM INTERRUPTS (8259)
		;               4. MASK ALL I/O SUBSYSTEM INTERRUPTS
		;               5. PROGRAM REAL TIME CLOCK
		;               
		BS0:
	        DI                      ; DISABLE INTERRUPT SYSTEM
        MVI     A,MOVBOT        ; TURN ON RAM (ROM WILL NOW RESPOND ONLY TO ADDRESS E800H)
        OUT     CPUC
        MVI     A,BOVROF        ; TURN OFF BUS OVERRIDE
        OUT     CPUC
        MVI     A,ENABL         ; PSEUDO ENABLE OF INTERRUPTS
        OUT     CPUC
        MVI     A,ENAXP         ; ENABLE AUXILIARY PROM
        OUT     CPUC
        MVI     A,ICW1          ; OUTPUT INITIALIZATION COMMAND WORD 1
        OUT     SICP0           ;       TO SYSTEM 8259
        OUT     IICP0           ;       TO I/O 8259
        MVI     A,ICW2          ; OUTPUT INITIALIZATION COMMAND WORD 2
        OUT     SICP1           ;       TO SYSTEM 8259
        OUT     IICP1           ;       TO I/O 8259
        MVI     A,~ INT0      ; INITIALIZE MASK REGISTER
        OUT     SOCP1           ;       FOR SYSTEM 8259
        MVI     A,~ INTA      ; INITIALIZE MASK REGISTER
        OUT     IOCP1           ;       FOR I/O 8259
        MVI     A,CTR2S | MODE3 | RLLM ; INITIALIZE 1MS REAL TIME CLOCK
        OUT     ITCP
        LXI     H,RTCC
	        MOV     A,L
        OUT     CTR2P
	        MOV     A,H
        OUT     CTR2P
		;
		;       B.      INITIALIZE RAM.
		;               1. COMPUTE SIZE OF RAM MEMORY.
		;               2. SET UP DEDICATED MEMORY LOCATIONS
		;                       USER I/O ENTRY POINTS (TOP OF MEMORY)
		;                       EXIT TEMPLATE
		;                       USER REGISTERS
		;                       USER INTERRUPT MASK
		;                       USER INTERRUPT MASK
		;                       USER STACK
		;                       MONITOR STACK
		;                       RESTART ROUTINE JUMP ADDRESS
		;
        LXI     H,0             ; INITIAL VALUE H:=0, L:=0
		BS1:
	        INR     H               ; INCREMENT BY 256 BYTE PAGES, I.E.100H,200H;..,F800H
	        MOV     A,M             ; FETCH CONTENTS OF MEMORY
	        CMA                     ; INVERT IT
	        MOV     M,A             ; ATTEMPT TO WRITE IT BACK INTO MEMORY     
	        CMP     M               ; IS LOCATION READ/WRITE, I.E. EXISTING RAM
	        CMA                     ; INVERT AGAIN BACK TO ORIGINAL VALUE
	        MOV     M,A             ; WRITE ORIGINAL DATA VALUE BACK IN
        JZ      BS1             ; YES, CONTINUE (I.E. STILL CONTIGUOUS RAM)
	        DCX     H               ; OTHERWISE, IT'S LAST ADDRESS IN RAM
		                                ;   UP TO 0E7FFH
        MVI     A,FSTOP         ; LOAD FULL-SYSTEM-UP-TO-BOOT-ROM PAGE ADDRESS
	        CMP     H               ; TEST FOR FULL-SYSTEM-UP-TO-BOOT-ROM
        JNZ     BS2             ; JUMP IF LESS THAN 0E7FFH IN RAM
		                                ; AT THIS POINT WE HAVE CONTIGUOUS RAM UP TO
		                                ;   0E7FFH; SKIP OVER 0E800-EFFFH WHICH IS
		                                ;   SHADOWED BY BOOT ROM AND THEREFORE
		                                ;   INACCESSIBLE; CONTINUE TESTING RAM FROM
		                                ;   0F000H
        LXI     H,0EF00H
		BS1X:
	        INR     H               ; INCREMENT BY 256 BYTE PAGES
	        MOV     A,M             ; FETCH CONTENTS OF MEMORY
	        CMA                     ; INVERT IT
	        MOV     M,A             ; ATTEMPT TO WRITE IT BACK INTO MEMORY
	        CMP     M               ; IS LOCATION READ/WRITE, I.E. EXISTING RAM
	        CMA                     ; INVERT IT BACK AGAIN TO ORIGINAL VALUE
	        MOV     M,A             ; WRITE ORIGINAL DATA VALUE BACK IN
        JZ      BS1X            ; YES, CONTINUE (I.E. STILL CONTIGUOUS RAM)
	        DCX     H               ; OTHERWISE HL POINT TO LAST CONTIGUOUS
		                                ;   BYTE OF RAM
        MVI     A,0F0H 
	        CMP     H               ; TEST IF H > 0F0H (I.E. THAT TOP OF MEMORY
		                                ;   IS AT LEAST 512 BYTES ABOVE SHADOW BOOT
		                                ;   ROM BECAUSE WE NEED SPACE FOR MONITOR
		                                ;   WORK TEMPLATE)
        JC      BS2             ; IF H > 0F0H THEN CARRY=1 AND HL CONTAIN
		                                ;   TRUE TOP OF MEMORY
        MVI     H,FSTOP         ; OTHERWISE H <= 0F0H THEN CARRY=0, SO
		                                ;   SET TOP OF MEMORY TO 0E7FFH, WHICH IS
		                                ;   JUST BELOW THE START OF SHADOW BOOT ROM
		BS2:
        SHLD    MEMTOP          ; STORE TOP OF MEMORY
        LXI     B,TOS           ; MOVE EXIT TEMPLATE TO RAM
	        MOV     L,C
	        SPHL                    ; SET MONITOR'S STACK POINTER
		BS3:
	        LDAX    B 
	        MOV     M,A
	        INR     C               ; MOVE BOTH POINTERS
	        INR     L   
        JNZ     BS3             ; END ON PAGE BOUNDARY
        MVI     L,SLOC & HMSK ; SET UP INITIAL VALUE FOR USER STACK
	        MOV     M,H             ; LOWER HALF OF STACK POINT-ER IS KNOWN
	        DCR     M               ; MERELY SET UPPER HALF
		                                ; TRAP TO MONITOR (AT LOCATIONS 0,1,2)
		;        MVI     A, (JMP RESTART)
        MVI     A, 0C3H
        STA     RESET
        LXI     H,RESTART       ; SET UP RESTART 0 FOR BREAKPOINT
        SHLD    RESET+1         ;   LOGIC
		;
		;       C.      PROGRAM I/O DEVICES.
		;               1. BAUD RATE GENERATOR FOR CRT
		;               2. USART FOR CRT
		;               3. BAUD RATE GENERATOR FOR TTY
		;               4. USART FOR TTY
		;
        MVI     A,CTR1S | MODE3 | RLLM
        OUT     ITCP
        LXI     H,B2400         ; CRT BAUD RATE
	        MOV     A,L
        OUT     CTR1P
	        MOV     A,H
        OUT     CTR1P
        MVI     A,ST2 | R16X | CL8
        OUT     USCC
        MVI     A,TXEN | DTR | RXEN | RTS
        OUT     USCC
        MVI     A,CTR0S | MODE3 | RLLM
        OUT     ITCP
        LXI     H,B0110         ; TTY BAUD RATE
	        MOV     A,L
        OUT     CTR0P
	        MOV     A,H
        OUT     CTR0P
        MVI     A,ST2 | R16X | CL8
        OUT     TTYC
        MVI     A,TXEN | RXEN | RTS
        OUT     TTYC
		;
		;       D.      DETERMINE IF INTEGRATED CONSOLE PRESENT
		;
        MVI     L,ITIMO         ; LOAD TIMEOUT CONSTANT
		BS4:
        IN      IOCS            ; 
        ANI     IBF | OBF | F0; MASK OFF STATUS FLAGS
		                                ; AND TEST FOR SLAVE PRESENCE
        JZ      BS5             ; JUMP IF INTEGRATED CONSOLE PRESENT
        CALL    BDLY            ; DELAY 1 MS FOR ANY RESETS TO COMPLETE
        CALL    BDLY            ; DELAY 1 MS. 
	        DCR     L               ; DECREMENT TIMER
        JZ      BS8             ; JUMP IF TIME EXPIRED
        JMP     BS4             ; OTHERWISE TRY AGAIN
		BS5:
        MVI     A,CRTS          ; LOAD CRT DEVICE STATUS COMMAND
        OUT     IOCC            ; OUTPUT COMMAND TO IOC CONTROL PORT
        MVI     L,ITIMO         ; LOAD TIMEOUT CONSTANT
		BS6:
        IN      IOCS            ; INPUT DBB STATUS
        ANI     IBF | OBF | F0; MASK OFF STATUS FLAGS
        CPI     OBF             ; TEST FOR SLAVE DONE; SOMETHING FOR THE MASTER
        JZ      BS7             ; JUMP IF DONE
        CALL    BDLY            ; DELAY 1 MS FOR ANY RESETS TO COMPLETE
        CALL    BDLY            ; DELAY 1 MS.
	        DCR     L               ; DECREMENT TIMER
        JZ      BS8             ; JUMP IF TIME EXPIRED
        JMP     BS6             ; OTHERWISE, TRY AGAIN
		BS7:
        IN      IOCI            ; INPUT CRT DEVICE STATUS FROM DBB
	        RRC                     ; TEST FOR CRT READY
        JC      BS9             ; JUMP IF READY (INTEGRATED CRT PRESENT)
		BS8:                            ; INTEGRATED CRT NOT PRESENT/READY SO RECORD THIS FACT
        LHLD    MEMTOP          ; LOAD TOP OF MEMORY PAGE ADDRESS 
        MVI     L,(BLOC+1) & LBMK ; LOAD CONFIGURATION ADDRESS
        MVI     A,ICNP          ; LOAD INTEGRATED CONSOLE NOT PRESENT
	        MOV     M,A             ; STORE IN CONFIGURATION BYTE IN EXIT TEMPLATE
		BS9:
		;
		;       E.      LOAD ISIS.T0 IF DISKETTE 0 IS READY
		;
	        XRA     A
	        CMA                     ; A-REG = 0FFH
	        PUSH    PSW             ; THREE-VALUED FLAG:
		                                ;   0FFH IF NEITHER FDCC NOR ISD SELECTED
		                                ;   00H IF FDCC SELECTED
		                                ;   01H IF ISD SELECTED
        IN      DSTS            ; SAMPLE FDCC STATUS
		                                ;   STATUS = 00H IF NO CONTROLLER PRESENT
        ANI     00001000B       ; IS FDCC CONTROLLER PRESENT?
        JZ      BS11            ; JUMP TO ISD SECTION IF FDCC NOT PRESENT
        IN      DSTS            ; SAMPLE FDCC STATUS AGAIN
	        RRC                     ; DRIVE 0 READY STATUS ROTATED INTO CARRY BIT
        JNC     BSX1            ; JUMP TO MONITOR IF FDCC CONTROLLER PRESENT
		                                ;   AND DRIVE 0 NOT READY
		                                ; THE FOLLOWING CODE IS USED TO WRITE THE DISK IOPB TO
		                                ; PROCESSOR MEMORY SO THAT IF ICE IS BEING USED TO DEBUG
		                                ; THE BOOT/MONITOR, THE DISK CONTROLLER CAN ACCESS THE IOPB
        LXI     H,1000H         ; LOAD POINTER TO DESTINATION MEMORY
        LXI     D,IOPB          ; LOAD POINTER TO SOURCE MEMORY FOR IOPB
        MVI     B,7             ; LOAD IOPB LENGTH COUNT
		MLP:
	        LDAX    D               ; LOAD BYTE OF IOPB
	        MOV     M,A             ; MOVE TO MEMORY
	        INX     H               ; INCREMENT IOPB POINTER
	        INX     D               ; INCREMENT MEMORY POINTER
	        DCR     B               ; DECREMENT IOPB LENGTH COUNT
        JNZ     MLP             ; CONTINUE UNTIL ALL OF IOPB MOVED
        LXI     H,1000H         ; RELOAD POINTER TO IOPB
	        MOV     A,L             ; A CONTAINS LSB OF IOPB ADDRESS
        OUT     LOWW            ; LOW (IOPB)
	        MOV     A,H             ; A CONTAINS MSB OF IOPB ADDRESS
        OUT     HI              ; HIGH(IOPB), START DISK I/O
		BS10:
        IN      DSTS            ; WAIT FOR FDCC TO COMPLETE
        ANI     OPCPL           ; TEST FOR DISK COMPLETION
        JZ      BS10
	        POP     PSW             ; GET READY TO SET FLAG TO NEW VALUE
	        XRA     A               ; SET A TO ZERO TO INDICATE DRIVE OTHER THAN INTEGRATED
		                                ; FLOPPY WAS ACCESSED CORRECTLY
	        PUSH    PSW             ; SAVE ON STACK
        JMP     BSX1            ; BYPASS INTEGRATED FLOPPY BOOT
		;
		; LOAD ISIS.T0 FROM INTEGRATED DISK IF AVAILABLE
		;
		BS11:
        LHLD    MEMTOP          ; LOAD TOP OF MEMORY PAGE ADDRESS
        MVI     L,(BLOC+1) & LBMK ; LOAD CONFIGURATION ADDRESS
	        MOV     A,M
	        RRC                     ; TEST FOR INTEGRATED CONSOLE PRESENT
        JC      BSX1            ; JUMP IF IOC NOT PRESENT OR FUNCTIONAL
        MVI     B,RDSTS         ; LOAD FLOPPY DEVICE STATUS COMMAND
        CALL    IOCDP1          ; READ STATUS FROM I/O CONTROLLER
        ANI     DPRNT           ; TEST FOR DRIVE PRESENT
        JZ      BSX1            ; JUMP IF NOT PRESENT
        MVI     B,RDSTS         ; LOAD FLOPPY DEVICE STATUS COMMAND
        CALL    IOCDP1          ; READ STATUS FROM I/O CONTROLLER
		                                ; SECOND STATUS READ USED TO INSURE DRIVE READY
	        RRC                     ; TEST FOR DRIVE READY     
        JNC     BSX1            ; JUMP IF DRIVE NOT READY
	        POP     PSW             ; UNLOAD STACK
	        XRA     A               ; SET A TO 1 TO INDICATE
	        INR     A               ; INTEGRATED FLOPPY WAS ACCESSED
	        PUSH    PSW             ; SAVE ON STACK
        LXI     H,IOPB          ; LOAD POINTER TO IOPB
        MVI     B,WPBC          ; LOAD WRITE IOPB COMMAND
	        MOV     C,M             ; LOAD FIRST BYTE OF IOPB
        CALL    IOCDP2          ; SEND BYTE TO IOC 
        MVI     E,PARML         ; LOAD IOPB LENGTH REMAINING
        MVI     B,WPBCC         ; LOAD WRITE IOPB CONTINUE COMMAND
		BS12:
	        INX     H               ; MOVE POINTER TO NEXT BYTE OF IOPB
	        MOV     C,M             ; MOVE TO C
        CALL    IOCDP2          ; SEND TO IOC 
	        DCR     E               ; DECREMENT IOPB LENGTH
        JNZ     BS12            ; CONTINUE UNTIL ALL DATA TRANSMITTED
        MVI     B,RDSTS         ; LOAD DEVICE STATUS COMMAND
		BS13:
        CALL    IOCDP1          ; READ STATUS FROM IOC 
        ANI     OPCPL           ; TEST FOR OPERATION COMPLETE
        JZ      BS13            ; LOOP UNTIL DONE
        MVI     B,RRSTS         ; LOAD RESULT STATUS COMMAND
        CALL    IOCDP1          ; READ RESULT STATUS FROM IOC 
        STA     TRK0-2          ; SAVE FOR TEST LATER
	        ORA     A               ; SET CONDITION CODES
        JNZ     BSX1            ; JUMP IF DISK OPERATION UNSUCCESSFUL
        LXI     H,TRK0          ; LOAD POINTER TO DISK DESTINATION ADDRESS
        LXI     D,TRKL          ; LOAD TRACK LENGTH
        MVI     B,RDBC          ; LOAD DISK READ DATA COMMAND
        CALL    IOCDP1          ; LOAD DATA FROM IOC 
	        MOV     M,A             ; MOVE TO MEMORY
	        DCX     D               ; DECREMENT LENGTH
	        INX     H               ; MOVE PDINTER TO NEXT LOCATION
		BS14:
        IN      IOCS            ; INPUT DBB STATUS
        ANI     IBF | OBF | F0; MASK OFF STATUS FLAGS
        CPI     OBF             ; TEST FOR DATA IN BUFFER 
        JNZ     BS14            ; JUMP IF NO DATA
        IN      IOCI            ; INPUT DATA FROM DBB
	        MOV     M,A             ; MOVE TO MEMORY
	        INX     H               ; MOVE POINTER TO NEXT LOCATION
	        DCX     D               ; DECREMENT LENGTH
	        MOV     A,D             ; LOAD D FOLLOWED BY E
	        ORA     E               ; 
        JNZ     BS14            ; CONTINUE UNTIL DONE
		;
		;       F.      DETERMINE COLD START LOCAL CONSOLE.
		;
		;-------------------------------
		; CONSOLE IS EITHER INTEGRATED CRT, SERIAL CRT, OR TTY
		BSX1:
        LHLD    MEMTOP          ; LOAD TOP OF MEMORY PAGE ADDRESS
        MVI     L,(BLOC+1) & LBMK ; LOAD CONFIGURATION ADDRESS
	        MOV     A,M             ; LOAD INTEGRATED CONSOLE FLAG
	        RRC                     ; TEST FOR INTEGRATED CONSOLE PRESENT
        JC      BSX2            ; JUMP IF INTEGRATED CONSOLE NOT PRESENT
        MVI     B,KSTS          ; LOAD KEYBOARD STATUS COMMAND
        CALL    IOCDP1          ; READ STATUS FROM IOC
	        RRC                     ; TEST FOR KEYBOARD PRESENT
	        RRC
        MVI     D,ICFG          ; LOAD INITIAL CONFIGURATION
        JC      BSX5            ; JUMP IF KEYBOARD PRESENT
		;-----------------------------------
		; CONSOLE IS EITHER SERIAL CRT OR TTY
		BSX2:
	        XRA     A               ; ZERO A
	        MOV     D,A             ; D CONTAINS 0H, I.E.C=T,R=T,P=T,L=T
        IN      TTYS            ; GET TTY STATUS
        ANI     RRDY            ; IS IT READY?
        JZ      BSX3            ; JUMP IF TTY NOT READY
        IN      TTYI            ; OTHERWISE GET CHARACTER FROM TTY
        JMP     BSX4
		BSX3:
        MVI     D,ICFG          ; LOAD INITIAL CONFIGURATION STATUS
        IN      USCS            ; GET SERIAL CRT STATUS
        ANI     RRDY            ; IS IT READY?
        JZ      BSX2            ; JUMP BACKWARDS IF CRT NOT READY
        IN      USCI            ; OTHERWISE, GET CHARACTER FROM CRT
		BSX4:
        ANI     7FH             ; MASK OUT PARITY BIT
        CPI     ' '             ; DID USER TYPE IN A SPACE CHARACTER?
        JNZ     BSX2            ; START ALL OVER IF NOT A SPACE CHARACTER
		                                ; IN CASE OF INTEGRATED CONSOLE PRESENT BUT
		                                ;   KEYBOARD DISCONNECTED, THE CONSOLE IS
		                                ;   NOW A SERIAL CRT, SO UPDATE
		                                ;   INTEGRATED CONSOLE FLAG
        LHLD    MEMTOP          ; LOAD TOP OF MEMORY PAGE ADDRESS
        MVI     L,(BLOC+1) & LBMK ; LOAD CONFIGURATION ADDRESS
        MVI     A,ICNP          ; INTEGRATED CONSOLE NOT PRESENT
	        MOV     M,A             ; STORE IN CONFIGURATION BYTE IN EXIT TEMPLATE 
		;-------------------------------
		; AT THIS POINT THE CONSOLE DEVICE HAS BEEN DETERMINED
		BSX5:
        LXI     H,IOBYT         ; HL POINTS TO I/O STATUS BYTE
	        MOV     M,D             ; REPLACE MODIFIED I/O STATUS BYTE
        MVI     L,INITIO        ; HL POINTS TO INITIAL I/O STATUS BYTE
	        MOV     M,D             ; SET INITIAL I/O STATUS BYTE
		;
		;       G.      CALL THE DIAGNOSTIC PROGRAM
		;
        CALL    DIAGBT
		;
		;       H.      IF DISK IS READY, TRANSFER TO ISIS.T0
		;
	        POP     PSW             ; UNLOAD FLAG
	        ORA     A               ; SET CONDITION CODES
        JNZ     BSX6            ; JUMP IF INTEGRATED CONSOLE ACCESSED
        IN      RSTS            ; SAMPLE FDCC RESULT STATUS
	        ORA     A               ; SET CONDITION CODES
        JNZ     BSX10           ; JUMP IF ERROR CONDITION
        IN      DSTS            ; SAMPLE FDCC STATUS
	        RRC                     ; IS IT READY?
        JNC     BSX9            ; JUMP TO MONITOR IF DISK NOT READY
		                                ; OTHERWISE, PRIOR TO TRANSFERRING CONTROL
		                                ;   TO T0.BOOT, WRITE AN INSTRUCTION TO
		                                ;   TURN OFF BOOTSTRAP PROM
        JMP     BSX8
		BSX6:
	        RLC                     ; TEST FOR NON DISK ACCESS
        JC      BSX9            ; JUMP IF NO ACCESS
        LDA     TRK0-2          ; LOAD TEMPORARY STORAGE FOR RESULT BYTE
	        ORA     A               ; SET CONDITION CODES
        JNZ     BSX10           ; JUMP IF ERROR CONDITION
        MVI     B,RDSTS         ; LOAD FLOPPY DEVICE STATUS COMMAND
        CALL    IOCDP1          ; READ STATUS FROM I/O CONTROLLER
	        RRC                     ; TEST FOR DRIVE READY
        JNC     BSX9            ; JUMP IF NOT READY
		BSX8:
		;        MVI     A,(OUT CPUC)    ; LOAD OUTPUT INSTRUCTION
        MVI     A,0D3H          ; LOAD OUTPUT INSTRUCTION
        STA     TRK0-2          ; STORE IN RAM BEFORE DISK BOOT
        MVI     A,CPUC          ; LOAD PORT ADDRESS
        STA     TRK0-1
        MVI     A,BTDGOF        ; TURN OFF BOOTSTRAP/DIAGNOSTIC ROM
        JMP     TRK0-2          ; EFFECT IS SAME AS: MVI A,BTDGOF
		                                ;                    OUT CPUC
		                                ;                    JMP TRK0 
		;
		;       I.      OTHERWISE, TYPE SIGN-ON FOR RAM MONITOR
		;
		BSX9:
        LXI     H,VERS          ; HL POINTS TO ADDRESS OF SIGN-ON MESSAGE
        MVI     B,LVER          ; B CONTAINS LENGTH OF MESSAGE
        CALL    PRTM            ; PRINT SIGN-ON MESSAGE
		;
		;       J.      BOOTSTRAP ALL DONE, SO BRANCH TO MONITOR.
        JMP     BEGIN           ; AT THIS POINT, INTERRUPTS ARE DISABLED
		;
		;       K.      PRINT DISK ERROR MESSAGE
		BSX10:
        LXI     H,ERMSG         ; HL POINTS TO ADDRESS OF DISK ERROR MESSAGE
        MVI     B,LERM          ; B CONTAINS LENGTH OF MESSAGE
        CALL    PRTM            ; PRINT SIGN-ON MESSAGE
        JMP     BSX9            ; PRINT MESSAGE
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		;       BDLY - BOOTSTRAP DELAY 1 MS SUBROUTINE
		;
		BDLY:
        MVI     C,ONEMS         ; LOAD 1 MS. CONSTANT
		BDLY1:
	        DCR     C               ; DECREMENT COUNTER
        JNZ     BDLY1           ; JUMP IF NOT EXPIRED
	        RET
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		;       PRTM - PRT SUBROUTINE FOR SIGN~ON MESSAGES
		;
		PRTM:
	        MOV     C,M             ; C CONTAINS A CHARACTER FROM THE MESSAGE
        CALL    COP             ; PRINT ON CONSOLE
	        INX     H
	        DCR     B
        JNZ     PRTM            ; KEEP LOOPING UNTIL ENTIRE MESSAGE IS OUTPUT
	        RET
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		;       DISK I/O PARAMETER BLOCK
		;
		IOPB:
	        DB      80H             ; IOCW, NO UPDATE BIT SET
	        DB      04H             ; I/O INSTRUCTION, READ DISK 0
	        DB      26              ; READ 26 SECTORS
	        DB      0               ; TRACK 0
	        DB      1               ; SECTOR 1
        DW      TRK0            ; LOAD ADDRESS
		;
		;       MONITOR SIGN-ON MESSAGE
		;
		VERS:
		;        DB      CR,LF,'SERIES II MONITOR, V'
        DB      CR,LF,"SERIES II MONITOR, V"
        DB      VER/10+'0','.',VER # 10+'0'
        DB      CR,LF
LVER    EQU     $-VERS          ; LENGTH OF SIGN-ON MESSAGE
		;
		;       MONITOR ERROR SIGN-ON MESSAGE
		;
		ERMSG:
        DB      CR,LF,'DISK ERROR',CR,LF
LERM    EQU     $-ERMSG         ; LENGTH OF ERROR SIGN-ON MESSAGE
	BTCKSM: DB      056H            ; BOOT CHKSUMS TO 55H
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-***-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; EXIT CODE TEMPLATE, TO BE EXECUTED IN RAM
		; THIS CODE IS ORIGINATED SO AS TO BE ALIGNED
		; AGAINST THE TOP OF A PAGE (1 PAGE = 256 BYTES)
		;
        ORG     BBASE + 02C8H
		TOS:                            ; BASE OF MONITOR WORK STACK
USER    EQU     TOS-8           ; BASE OF DEFAULT USER WORK STACK
	ELOC:   DB      0EEH            ; E REGISTER STORAGE
	DLOC:   DB      0DDH            ; D REGISTER
	CLOC:   DB      0CCH            ; C REGISTER
	BLOC:   DB      0BBH            ; B REGISTER
	        DB      0               ; CONFIGURATION BYTE
		                                ; BIT 0 = 0 IF INTEGRATED CRT IS PRESENT
		                                ;       = 1 IF INTEGRATED CRT NOT PRESENT
	ILOC:   DB      ~ INT0        ; INTERRUPT MASK
	FLOC:   DB      0FFH            ; CPU FLAGS
	ALOC:   DB      0AAH            ; A REGISTER
	        DB      USER & HMSK   ; LOW(SP)
	SLOC:   DB      0               ; HIGH(SP)
		;
		EXIT:                           ; MONITOR STACK ORIGIN
	        DI                      ; DISABLE INTERRUPTS TO PROTECT THIS SEQUENCE
	        POP     D               ; RESTORE D,E
	        POP     B               ; RESTORE B,C
	        POP     PSW
        OUT     SOCP1           
	        POP     PSW             ; RESTORE A AND FLAGS
	        POP     H               ; RESTORE ORIGINAL STACK VALUE
	        SPHL
        LXI     H,1234H         ; RESTORE H,L; 1234H IS FILLER WHICH WILL BE
		                                ;   OVERWRITTEN BY RESTART ROUTINE
LLOC    EQU     $-2
HLOC    EQU     $-1
	        EI                      ; ENABLE INTERRUPTS
        JMP     6789H           ; RETURN TO INTERRUPTED CODE; 6789H IS FILLER
		                                ;   WHICH WILL BE OVERWRITTEN BY 'G' COMMAND
		                                ;   AND RESTART ROUTINE
PLOC    EQU     $-1
TLOC:   DW      0               ; TRAP 1 ADDRESS
	        DB      0               ; TRAP 1 VALUE
        DW      0               ; TRAP 2 ADDRESS
	        DB      0               ; TRAP 2 VALUE
		XTBL:                           ; EXTENSIBLE I/O ENTRY POINTS
		                                ;   FILLED IN WHEN USER GIVES ADDRESS OF OWN
		                                ;   DRIVER ROUTINE VIA IODEF SYSTEM CALL IN MONITOR
		CILOC:
        JMP     0
		COLOC:
        JMP     0
		R1LOC:
        JMP     0
		R2LOC:
        JMP     0
		P1LOC:
        JMP     0
		P2LOC:
        JMP     0
		LILOC:
        JMP     0
		CSLOC:
        JMP     0
		ENDX:                           ; THIS LABEL SHOULD BE AT 0EA00H.
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		; SELECTION CODES FOR USER I/O ENTRY POINTS
UCI     EQU     (CILOC-XTBL)/3
UCO     EQU     (COLOC-XTBL)/3
UR1     EQU     (R1LOC-XTBL)/3
UR2     EQU     (R2LOC-XTBL)/3
UP1     EQU     (P1LOC-XTBL)/3
UP2     EQU     (P2LOC-XTBL)/3
UL1     EQU     (LILOC-XTBL)/3
UCS     EQU     (CSLOC-XTBL)/3
		; END OF BOOTSTRAP PROM CODE
		;*******************************************************************************
DIAGMN  EQU     0EB00H          ; STARTING ADDRESS OF DIAGNOSTIC PROGRAM
		                                ;   WHEN ENTERED FROM CALL FROM MONITOR
DIAGBT  EQU     0EB03H          ; STARTING ADDRESS OF DIAGNOSTIC PROGRAM
		                                ;   WHEN ENTERED FROM CALL FROM BOOT
        ORG     0EB00H          ; WHEN BURNING THE PROM; THIS SECTION OF CODE
		                                ;   WILL BE OVERLAYED BY THE REAL DIAGNOSTIC
		                                ;   PROGRAM.
	        RET
	        NOP
	        NOP
	        RET                     ; 0EB03H
		                                ; BOOTSTRAP/DIAGNOSTIC PROM
		;*******************************************************************************
		;*******************************************************************************
		;*******************************************************************************
		;***                                                                         ***
		;***           START OF MONITOR PROPER                                       ***  
		;***                                                                         ***
		;*******************************************************************************
		;*******************************************************************************
		;*******************************************************************************
		;BASE    SET     0F800H          ; BASE ADDRESS OF MONITOR
BASE    EQU     0F800H          ; BASE ADDRESS OF MONITOR
        ORG     BASE            ; TOP 2K OF 64K ADDRESS SPACE
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; BRANCH TABLE FOR I/O SYSTEM (EXTERNAL I/O ENTRY POINTS)
		;
		; THE MONITOR IS ENTERED AT ENTRY POINT 'BEGIN' VIA A JUMP FROM THE BOOTSTRAP;
		; THIS IN TURN LEADS TO A JUMP TO ENTRY POINT 'START'. THE OTHER ENTRIES
		; IN THIS "TABLE" ARE EXTERNAL I/O ENTRY POINTS KNOWN TO THE USER PLUS
		; THE DATE, VERSION, AND COPYRIGHT STAMPS.
		BEGIN:
        JMP     START0          ; RESET ENTRY POINT
        JMP     CI              ; LOCAL CONSOLE INPUT
        JMP     RI              ; READER INPUT
        JMP     CO              ; LOCAL CONSOLE OUTPUT
        JMP     PO              ; PUNCH OUTPUT
        JMP     LO              ; LIST OUTPUT
        JMP     CSTS            ; LOCAL CONSOLE INPUT STATUS
        JMP     IOCHK           ; I/O SYSTEM STATUS
        JMP     IOSET           ; SET I/O CONFIGURATION
        JMP     MEMCHK          ; COMPUTE SIZE OF MEMORY
        JMP     IODEF           ; DEFINE USER I/O ENTRY POINTS
        JMP     IOCDR1          ; IOC INPUT
        DW      DATC            ; DATE STAMP FOR MONITOR ROM
        JMP     UI              ; UPP INPUT
        JMP     UO              ; UPP OUTPUT
        JMP     UPPS            ; UPP STATUS
	        DB      VERH            ; VERSION STAMP FOR MONITOR ROM
		;        DB      '(C)INTEL CORP1979' ; COPYRIGHT NOTICE IN ASCII REP
        DB      "(C)INTEL CORP1979" ; COPYRIGHT NOTICE IN ASCII REP
        JMP     IOCCOM          ; IOCCOM ENTRY POINT
        JMP     IOCDR2          ; IOC OUTPUT
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		,
		; 'ERROR' - ENTERED VIA JUMP FROM VARIOUS ROUTINES WHEN AN ERROR IS DETECTED
		; PROCESS: ABNORMAL EXIT FOR ALL MONITOR ERROR CONDITIONS. BECAUSE OF THE
		;          UNKNOWN STATE OF THE MONITOR AS A RESULT OF A COMMAND OR DATA ERROR,
		;          THE VALUE OF THE MONITOR STACK POINTER IS REINITIALIZED AND
		;          EXECUTION CONTINUES TO THE MAIN COMMAND LOOP.
		; INPUT: MEMTOP,TOS
		; OUTPUT: SP POINTS TO BASE OF MONITOR STACK IN TOP PAGE OF CONTIGUOUS RAM
		; MODIFIED: H,L, SP
		; STACK USAGE:
		; REGISTER USAGE
		; X = MODIFIED BY THIS ROUTINE, CONTENTS UNDEFINED.
		; S = SET BY THIS ROUTINE, RETURNED AS A RESULT.
		; U = USED AS INPUT.
		;          A -
		;          B -          C - S
		;          D -          E -
		;          H - X        L - X
		;          CARRY - X    ZERO - X
		;          SIGN - X     PARITY - X
		;          SP - S       PC -
		;          STACK USAGE: 2 BYTES
		ERROR:
        LHLD    MEMTOP          ; H POINTS TO TOP PAGE OF MEMORY
        MVI     L,TOS & 0FFH  ; L POINTS TO BASE OF STACK WITHIN THAT PAGE
	        SPHL                    ; SP NOW POINTS TO BASE OF MONITOR STACK
        CALL    COMC            ; OUTPUT THE ERROR INDICATOR CHAR '#'
	        DB      '#'
		                                ; FALL THROUGH TO MAIN COMMAND LOOP
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		; MAIN COMMAND LOOP.
		;
		; THIS LOOP IS THE STARTING POINT OF ALL COMMAND SEQUENCES.
		; IT IS ENTERED VIA A JUMP FROM THE BEGINNING OF THE MONITOR PROPER CODE,
		; A FALL THROUGH FROM THE ERROR ROUTINE, OR A RETURN FROM A MONITOR COMMAND
		; ROUTINE.
		; IN THIS CODE INTERRUPTS ARE ENABLED AND A CARRIAGE RETURN
		; AND LINE FEED ARE TYPED ALONG WITH THE PROMPT CHARACTER, '.'.
		; WHEN A CHARACTER IS ENTERED FROM THE LOCAL CONSOLE KEYBOARD, IT
		; IS CHECKED FOR VALIDITY, THEN A BRANCH TO THE PROPER
		START0:
        MVI     A,BTDGOF        ; DISABLE BOOT, I.E. SWITCH BOOT PROM
        OUT     CPUC            ;   OUT OF ADDRESSABLE MEMORY SPACE
		START:
	        EI                      ; ENABLE INTERRUPTS
        CALL    CRLF            ; TYPE <CR>,<LF>
        CALL    COMC            ; OUTPUT A PERIOD
	        DB      '.'
        CALL    TI              ; GET A CHARACTER, ECHO IT.
        CPI     CR              ; IS IT A CARRIAGE RETURN?
        JZ      START           ; JUMP IF IT IS
        SUI     'A'             ; OTHERWISE TEST FOR A-Z (VALID COMMAND RANGE)
        JM      ERROR           ; LESS THAN A, NOT A VALID COMMAND
        MVI     C,2             ; ASSUME THE COMMAND NEEDS 2 PARAMETERS
        LXI     D,START         ; SET UP PSEUDO RETURN ADDRESS TO SIMULATE
	        PUSH    D               ;   EFFECT OF A CALL. COMMANDS WHICH PERFORM
		                                ;   A RETURN WILL CAUSE THE STACK TO BE
		                                ;   POPPED, THUS RETURNING TO ENTRY POINT
		                                ;   START. THE 'G' COMMAND, HOWEVER, WIPES
		                                ;   OUT THIS ADDRESS WITH ANOTHER ADDRESS
		                                ;   OF ITS OWN CHOOSING (I.E. USER'S PC).
        LXI     H,CTBL          ; LOAD POINTER TO PROCESSING ROUTINE PTRS
        CPI     LCT             ; TEST FOR OVERRUN
        JP      ERROR           ; IF SO, THEN ERROR
	        MOV     E,A             ; OTHERWISE, MOVE INDEX TO DE
        MVI     D,0
	        DAD     D
	        DAD     D               ; HL := CTBLBASE + (2 * INDEX); HL NOW POINTS
		                                ; TO PROPER COMMAND IN COMMAND BRANCH TABLE
	        MOV     A,M             ; GET LSB OF BRANCH LOCATION
	        INX     H
	        MOV     H,M             ; GET MSB OF BRANCH LOCATION
	        MOV     L,A             ; HL POINTS TO ADDRESS OF COMMAND CODE
	        PCHL                    ; TAKE THE BRANCH
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; COMMAND BRANCH TABLE.
		;
		; THIS TABLE CONTAINS THE ADDRESSES OF THE ENTRY POINTS OF
		; ALL THE COMMAND PROCESSING ROUTINES. IT IS ENTERED FROM THE MAIN
		; COMMAND LOOP. NOTE THAT AN ENTRY TO 'ERROR'
		; IS AN ERROR CONDITION, I.E., NO COMMAND CORRESPONDING TO THAT
		; CHARACTER EXISTS.
		CTBL:
        DW      ASSIGN          ; A - ASSIGN I/O UNITS
        DW      ERROR           ; B -
        DW      ERROR           ; C -
        DW      DISP            ; D - DISPLAY RAM MEMORY
        DW      EOF             ; E - ENDFILE A HEXADECIMAL FILE
        DW      FILL            ; F - FILL MEMORY
        DW      GOTO            ; G - GO TO MEMORY ADDRESS
        DW      HEXN            ; H - HEXADECIMAL SUM AND DIFFERENCE
        DW      ERROR           ; I -
        DW      ERROR           ; J -
        DW      ERROR           ; K -
        DW      ERROR           ; L -
        DW      MOVE            ; M - MOVE MEMORY
        DW      NULL            ; N - PUNCH NULLS FOR LEADER ON PAPER TAPE
        DW      ERROR           ; O -
        DW      ERROR           ; P -
        DW      QUERY           ; Q - QUERY I/O SYSTEM STATUS
        DW      READ            ; R - READ HEXADECIMAL PAPER TAPE FILE
        DW      SUBS            ; S - SUBSTITUTE MEMORY
        DW      ERROR           ; T -
        DW      ERROR           ; U -
        DW      ERROR           ; V -
        DW      WRITE           ; W - WRITE FILE TO PAPER TAPE IN HEX FORMAT
        DW      X               ; X - EXAMINE AND MODIFY REGISTERS
        DW      ERROR           ; Y -
        DW      Z               ; Z - INVOKE THE DIAGNOSTIC PROGRAM
LCT     EQU     ($-CTBL)/2      ; LCT = NUMBER OF 16-BIT ENTRIES IN TABLE
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; 'A' COMMAND - ASSIGN I/O DEVICE
		;
		; THIS ROUTINE MAPS SYMBOLIC DEVICE IDENTIFIERS TO BITS
		; IN THE I/O STATUS BYTE (IOBYT) TO ALLOW FOR LOCAL CONSOLE
		; MODIFICATION OF SYSTEM "rIO CONFIGURATION.
		ASSIGN:
        CALL    TI              ; GET LOGICAL DEVICE CHARACTER (C,R,P,L)
        LXI     H,LTBL          ; ADDRESS OF MASTER TABLE
        MVI     C,4             ; MAXIMUM OF 4 ENTRIES
		;       ---------------------------------------------------------------------
		AS0:                            ; HL POINTS TO IDENTIFYING CHARACTER IN LTBL
	        CMP     M               ; DOES A-REG CONTAIN C,R,P, OR L?
	        INX     H               ; HL POINTS TO CORRESPONDING DEVICE MASK
        JZ      AS1             ; YES IT DOES
	        INX     H
	        INX     H
	        INX     H               ; HL POINTS TO NEXT 4-BYTE ENTRY IN LTBL
	        DCR     C               ; DECREMENT LOOP COUNT
        JNZ     AS0             ; TRY NEXT ENTRY
        JMP     ERROR           ; NO MATCH, ERROR
		;       ---------------------------------------------------------------------
		AS1:                            ; USER HAS SPECIFIED A VALID LOGICAL DEVICE
	        MOV     B,M             ; B := LOGICAL DEVICE MASK
	        INX     H               ; HL CONTAINS SUBORDINATE PHYS.DEV.TBL.ADDRESS
	        MOV     E,M             ; E CONTAINS LSB OF PDT ADDRESS
	        INX     H
	        MOV     D,M             ; D CONTAINS MSB OF PDT ADDRESS
	        XCHG                    ; HL POINTS TO I/O SYSTEM PHYSICAL DEVICE
		                                ;   TABLE (I.E. ACT,ART,APT, OR ALT)
		;       ---------------------------------------------------------------------
		ALUP1:                          ; SCAN INPUT UNTIL '='
        CALL    TI
        CPI     '='
        JNZ     ALUP1
		;       ---------------------------------------------------------------------
		ALUP2:                          ; SCAN INPUT WHILE ' ' (BLANK)
        CALL    TI
        CPI     ' '
        JZ      ALUP2
		;       ---------------------------------------------------------------------
        MVI     C,4             ; SET TABLE LENGTH
		AS2:                            ; INDEX THROUGH PHYSICAL UNIT TABLE
	        CMP     M               ; COMPARE DEVICE CHAR WITH LEGAL VALUES
	        INX     H               ; HL CONTAINS DEVICE SELECT BIT PATTERN
        JZ      AS3             ; USER HAS SPECIFIED A VALID PHYS.DEVICE ASSIGNMNT
	        INX     H               ; HL POINTS TO NEXT ENTRY WITHIN THE TABLE
	        DCR     C
        JNZ     AS2             ; CONTINUE LOOKUP
        JMP     ERROR           ; ERROR RETURN
		;       ---------------------------------------------------------------------
		AS3:
		ALUP3:                          ; SCAN INPUT UNTIL <CR>
        CALL    TI
        CPI     CR
        JNZ     ALUP3
        LDA     IOBYT           ; GET I/O STATUS
	        ANA     B               ; B CONTAINS LOG DEV MASK. CLEAR OUT THE
		                                ;   APPROPRIATE FIELD IN IOBYT BECAUSE WE ARE
		                                ;   GOING TO CHANGE IT
	        ORA     M               ; PUT IN THE NEW STATUS FIELD
        STA     IOBYT           ; RETURN IT TO MEMORY
	        RET                     ; RETURN CONTROL TO MAIN COMMAND LOOP
		;
		; MASTER I/O DEVICE TABLE
		; 4 BYTES/ENTRY
		; 
		;   BYTE 0 = IDENTIFYING CHARACTER
		;   BYTE 1 = LOGICAL DEVICE MASK
		;   BYTES 2,3 = ADDRESS OF SUBORDINATE PHYSICAL DEVICE TABLE
		;
		LTBL:
        DB      'C',CMSK
        DW      ACT
        DB      'R',RMSK
        DW      ART
        DB      'P',PMSK
        DW      APT
        DB      'L' ,LMSK
        DW      ALT
		;
		; I/O SYSTEM PHYSICAL DEVICE TABLES
		; 2 BYTES/ENTRY
		;
		;   BYTE 0 = IDENTIFYING CHARACTER
		;   BYTE 1 = DEVICE SELECT BIT PATTERN
		;
		ACT:
        DB      'T',CTTY        ; LOCAL CONSOLE = TTY
        DB      'C',CCRT        ; LOCAL CONSOLE = CRT
        DB      'B',BATCH       ; BATCH MODE LOCAL CONSOLE READ, LIST
        DB      '1',CUSE        ; USER DEFINED LOCAL CONSOLE DEVICE
		ART:
        DB      'T',RTTY        ; READER TTY
        DB      'P',RPTR        ; READER PTR
        DB      '1',RUSE1       ; USER DEFINED READER DEVICE 1
        DB      '2',RUSE2       ; USER DEFINED READER DEVICE 2
		APT:
        DB      'T',PTTY        ; PUNCH TTY
        DB      'P',PPTP        ; PUNCH PTP
        DB      '1',PUSE1       ; USER DEFINED PUNCH DEVICE 1
        DB      '2',PUSE2       ; USER DEFINED PUNCH DEVICE 2
		ALT:
        DB      'T',LTTY        ; LIST = TTY
        DB      'C',LCRT        ; LIST = CRT
        DB      'L',LLPT        ; LIST = LPT
        DB      '1',LUSE        ; USER DEFINED LIST DEVICE
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; 'D' COMMAND - DISPLAY CONTENTS OF MEMORY ON LIST DEVICE
		;
		; THIS ROUTINE EXPECTS TWO HEXADECIMAL PARAMETERS SPECIFYING
		; THE BOUNDS OF A MEMORY AREA TO BE DISPLAYED ON THE
		; LIST DEVICE. THE MEMORY AREA IS DISPLAYED 16 BYTES
		; PER LINE, WITH THE MEMORY ADDRESS OF THE FIRST BYTE
		; PRINTED FOR REFERENCE. ALL LINES ARE BLOCKED INTO INTEGRAL
		; MULTIPLES OF 16 FOR CLARITY, SO THE FIRST AND LAST LINES MAY
		; BE LESS THAN 16 BYTES IN ORDER TO SYNCHRONIZE THE DISPLAY.
		DISP:
        CALL    EXPR            ; GET TWO ADDRESSES
	        POP     D               ; GET HIGH ADDRESS
	        POP     H               ; GET LOW ADDRESS
		DI0:
        CALL    LCRLF           ; PRINT CR,LF
        CALL    DADR            ; PRINT MEMORY ADDRESS
		DI1:
        MVI     C,' '
        CALL    LOM             ; PRINT SPACE
	        MOV     A,M
        CALL    DBYTE           ; PRINT DATA
        CALL    HILO            ; TEST FOR COMPLETION
        JC      DI2             ; RETURN TO MAIN LOOP
	        MOV     A,L
        ANI     0FH             ; PRINT CR,LF,ADDRESS ON MULTIPLE OF 16
        JNZ     DI1
        JMP     DI0
		DI2:
        CALL    LCRLF           ; WRITE CR,LF
        MVI     C,0
        CALL    LOM             ; WRITE A NULL TO TRIGGER CLOSE
	        RET
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; 'E' COMMAND - PUNCH HEXADECIMAL END-OF-FILE
		;
		; THIS ROUTINE PRODUCES A TERMINATION RECORD WHICH PROPERLY
		; COMPLETES A HEXADECIMAL FILE CREATED BY 'W' COMMANDS.
		; IT EXPECTS ONE HEXADECIMAL PARAMETER, WHICH IT INTERPRETS AS THE
		; START ADDRESS TO BE LOADED INTO THE USER'S PROGRAM COUNTER (LOCATED
		; IN EXIT TEMPLATE) ON A SUBSEQUENT 'R' COMMAND; THIS START ADDRESS
		; WILL REPLACE THE STORED VALUE OF THE USER'S PROGRAM COUNTER ONLY
		; IF THE START ADDRESS IS NONZERO.
		EOF:
	        DCR     C               ; C:=1; GET ONE PARAMETER
        CALL    EXPR            ; PUT (START ADDRESS) ON TOP OF STACK
        CALL    POC             ; OUTPUT RECORD MARK (':')
	        DB      ':'
	        XRA     A               ; ZERO CHECKSUM
	        MOV     D,A             ; D := 0; A := 0
        CALL    PBYTE           ; OUTPUT A RECORD LENGTH OF ZERO
	        POP     H               ; RETRIEVE START ADDRESS
        CALL    PADR            ; OUTPUT IT AS THE LOAD ADDRESS
        MVI     A,1             ; RECORD TYPE = 1
        CALL    PBYTE           ; OUTPUT RECORD TYPE
	        XRA     A               ; A := 0
	        SUB     D               ; D CONTAINS RUNNING CHECKSUM
        CALL    PBYTE           ; OUTPUT CHECKSUM := -D
        JMP     NU0             ; PUNCH TRAILER AND RETURN
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; 'F' COMMAND - FILL RAM WITH 8-BIT CONSTANT
		;
		; THIS ROUTINE EXPECTS THREE HEXADECIMAL PARAMETERS, THE
		; FIRST AND SECOND (16 BITS) ARE INTERPRETED AS THE BOUNDS
		; OF A MEMORY AREA TO BE INITIALIZED TO A CONSTANT VALUE,
		; THE THIRD PARAMETER (8 BITS) IS THAT VALUE.
		FILL:
	        INR     C               ; C:=3; GET 3 PARAMETERS
        CALL    EXPR
	        POP     B               ; C := 8-BIT CONSTANT
	        POP     D               ; DE := HIGH ADDRESS
	        POP     H               ; HL := LOW ADDRESS
		FI0:
	        MOV     M,C             ; STORE CONSTANT IN MEMORY
        CALL    HILO            ; TEST FOR COMPLETION
        JNC     FI0             ; CONTINUE LOOPING
	        RET                     ; GO BACK TO START
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; 'G' COMMAND - GO TO <ADDRESS>, OPTIONALLY SET BREAKPOINT(S)
		;
		; THE G COMMAND IS USED FOR TRANSFERRING CONTROL FROM THE
		; MONITOR TO A USER PROGRAM. IT HAS SEVERAL MODES OF
		; OPERATION.
		; IF ONE HEXADECIMAL PARAMETER IS ENTERED, IT IS INTERPRETED
		; AS THE ENTRY POINT OF THE USER PROGRAM AND A TRANSFER TO
		; THAT LOCATION IS EXECUTED.
		; IF ADDITIONAL (UP TO 2) PARAMETERS ARE ENTERED, THESE ARE
		; CONSIDERED 'BREAKPOINTS', I.E., LOCATIONS WHERE
		; CONTROL IS TO BE RETURNED TO THE MONITOR WHEN THEY ARE
		; ENCOUNTERED IN COURSE OF EXECUTING THE USER PROGRAM.
		; IF THE FIRST PARAMETER IS NOT ENTERED, THE STORED VALUE
		; OF THE USER'S PROGRAM COUNTER (REGISTER P) IS USED AS
		; THE USER PROGRAM ENTRY POINT.
		;
		; THIS COMMAND WORKS IN THE FOLLOWING MANNER:
		;   1. IT FINDS THE EXIT CODE IN TOP OF RAM AND PLACES THIS ADDRESS IN THE
		;       MONITOR'S STACK, REPLACING THE RETURN ADDRESS TO ENTRY POINT START
		;       THAT WAS PLACED THERE BY THE MAIN COMMAND LOOP.
		;   2. IF THERE IS NO FURTHER INPUT (I.E. ONLY <CR� THEN BY EXECUTING A
		;       RET, WE CAUSE EXECUTION OF THE EXIT CODE, WHICH CONTAINS A JUMP TO
		;       A) A DUMMY ADDRESS (IF IMPROPER USE OF COMMAND), B) THE PROGRAM
		;       COUNTER FROM WHEN THE USER PROGRAM WAS INTERRUPTED OR BREAKPOINT
		;       WAS ENCOUNTERED.
		;   3. IF THERE IS A START ADDRESS SPECIFIED, THIS VALUE IS STORED OVER
		;       THAT PART OF THE EXIT CODE WHICH CONTAINS THE JMP INSTRUCTION.
		;       IF THERE IS NO FURTHER INPUT, A RET IS EXECUTED AND THE EXIT
		;       CODE IS EXECUTED.
		;   4. IF TRAPS (BREAKPOINTS) ARE TO BE SET, THEN THEY ARE READ IN AND PLACED
		;       ON THE MONITOR STACK. THEY ARE THEN STORED IN THE PROPER SECTION OF
		;       THE EXIT TEMPLATE. ALSO, IN THE USER'S PROGRAM THE INSTRUCTION SPECIFIED
		;       BY THE BREAKPOINT ADDRESS IS SAVED IN THE EXIT TEMPLATE AND REPLACED
		;       WITH A RST 0 INSTRUCTION.
		;   5. THE EXIT CODE IS EXECUTED AND CONTROL IS PASSED TO THE USER PROGRAM.
		GOTO:
        LHLD    MEMTOP
        MVI     L,EXIT & 0FFH ; HL NOW POINTS TO EXIT CODE IN TOP OF RAM
	        XTHL                    ; REPLACE THE START RETURN ADDRESS IN THE 
		                                ;   STACK (PUSHED BY MAIN COMMAND LOOP) WITH
		                                ;   THIS EXIT CODE ADDRESS SO THAT WHEN THE
		                                ;   G COMMAND DOES A RETURN, THE EXIT CODE
		                                ;   WILL BE EXECUTED INSTEAD OF THE MAIN
		                                ;   COMMAND LOOP.
        CALL    PCHK            ; GET A CHARACTER, SET Z,C
        JZ      GO0             ; IF ' ',',' OR <CR>: JUMP, DON'T CHANGE PC
        CALL    PA0             ; GET NEW PC VALUE
	        XCHG                    ; DE = NEW PC
        LHLD    MEMTOP
        MVI     L,PLOC & 0FFH ; HL NOW POINTS TO PLOC IN EXIT CODE IN TOP OF RAM
	        MOV     M,D             ; STORE MSB OF MODIFIED PC IN EXIT CODE IN RAM
	        DCX     H
	        MOV     M,E             ; STORE LSB OF MODIFIED PC IN EXIT CODE IN RAM
		GO0:
        JC      GO4             ; JUMP IF <CR> (NO TRAPS TO BE SET)
        LXI     D,2             ; SET COUNTER(S), D=0, E=2
		GO1:
        CALL    COMC            ; ISSUE A PROMPT FOR A TRAP
	        DB      '-'
        CALL    PARAM           ; GET A TRAP
	        PUSH    H               ; STACK IT
	        INR     D               ; UP 1 COUNTER
        JC      GO2             ; TERMINATE IF CR ENTERED
	        DCR     E               ; DOWN THE OTHER
        JNZ     GO1             ; GET ONE MORE TRAP
		GO2:                            ; D CONTAINS HOW MANY TRAPS (1 OR 2)
        JNC     ERROR           ; LAST TRAP NOT FOLLOWED BY CR
        LHLD    MEMTOP
        MVI     L,TLOC & 0FFH ; HL NOW POINTS TO TLOC (BEGINNING OF TRAP
		                                ;   AREA) IN EXIT TEMPLATE IN TOP OF RAM
		GO3:                            ; BC CONTAINS THE USER SPECIFIED TRAP ADDRESS
	        POP     B               ; GET A TRAP (BREAKPOINT) ADDRESS
	        MOV     M,C             ; STORE LSB OF TRAP ADDRESS INTO TRAP AREA
	        INX     H
	        MOV     M,B             ; STORE MSB OF TRAP ADDRESS INTO TRAP AREA
	        INX     H
	        LDAX    B               ; FETCH OPCODE BYTE
	        MOV     M,A             ; PUT IN TRAP AREA
	        INX     H 
		;        MVI     A, (RST 0)      ; REPLACE THE USER'S OPCODE IN USER PROGRAM
        MVI     A,0C7H          ; REPLACE THE USER'S OPCODE IN USER PROGRAM
	        STAX    B               ;   WITH A RST 0
	        DCR     D
        JNZ     GO3             ; DO SAME THING AGAIN FOR 2ND BREAKPOINT
		GO4:
        CALL    CRLF
	        RET                     ; EXECUTE MONITOR EXIT CODE, RETURNING TO
		                                ; USER CODE
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; 'H' COMMAND - COMPUTE HEXADECIMAL SUM AND DIFFERENCE
		;
		; THIS ROUTINE EXPECTS TWO HEXADECIMAL PARAMETERS.
		; IT COMPUTES THE SUM AND DIFFERENCE OF THE TWO VALUES
		; AND DISPLAYS THEM ON THE LOCAL CONSOLE DEVICE AS FOLLOWS:
		; <Pl+P2> <PI-P2>
		HEXN:
        CALL    EXPR            ; GET TWO NUMBERS
        CALL    CRLF
	        POP     D               ; DE CONTAINS P2
	        POP     H
	        PUSH    H               ; HL CONTAINS P1
	        DAD     D               ; HL := HL + DE := P1 + P2
        CALL    LADR            ; DISPLAY SUM
        CALL    BLK             ; TYPE A SPACE
	        POP     H               ; HL CONTAINS P1 AGAIN
	        MOV     A,L             ; COMPUTE HL-DE
	        SUB     E               ; A := LSB OF P1 - LSB OF P2
	        MOV     L,A             ; A := LSB OF (P1 - P2)
	        MOV     A,H
	        SBB     D               ; A -= MSB OF P1 - MSB OF P2 WITH CARRY
	        MOV     H,A             ;H := MSB OF (P1 - P2) 
        CALL    LADR            ; DISPLAY DIFFERENCE
	        RET
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; 'M' COMMAND - MOVE A BLOCK OF MEMORY
		;
		; THIS ROUTINE EXPECTS THREE HEXADECIMAL PARAMETERS FROM THE
		; LOCAL CONSOLE. THE FIRST AND SECOND PARAMETERS ARE THE BOUNDS OF
		; THE MEMORY AREA TO BE MOVED, THE THIRD PARAMETER IS THE
		; STARTING ADDRESS OF THE DESTINATION AREA.
		MOVE:
	        INR     C               ; GET THREE ADDRESSES
        CALL    EXPR
	        POP     B               ; DESTINATION ADDRESS
	        POP     D               ; SOURCE END ADDRESS
	        POP     H               ; SOURCE START ADDRESS
		MV0:
	        MOV     A,M             ; GET A DATA BYTE
	        STAX    B               ; STORE AT DESTINATION
	        INX     B               ; MOVE DESTINATION POINTER
        CALL    HILO            ; TEST FOR COMPLETION
        JNC     MV0
	        RET
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; 'N' COMMAND - PUNCH NULL CHARACTERS FOR TAPE LEADER/TRAILER
		;
		; THIS ROUTINE PUNCHES 60 NULL CHARACTERS ON THE DEVICE ASSIGNED
		; AS THE PUNCH. IT IS ENTERED VIA A JUMP TO ENTRY POINT NU0
		; FROM THE 'E' COMMAND AS WELL AS BEING INVOKED BY
		; THE 'N' COMMAND.
		NULL:
        CALL    TI              ; REQUIRE CR
        CPI     CR
        JNZ     ERROR
		NU0:
        MVI     B,60            ; SET TO PUNCH 60 NULLS
		NLEADX:
        CALL    POC             ; PUNCH ONE ASCII NULL CHARACTER (=00H)
	        DB      0
	        DCR     B
        JNZ     NLEADX          ; DO IT FOR 60 TIMES
	        RET
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; 'Q' COMMAND - I/O SYSTEM STATUS QUERY
		;
		; THIS COMMAND IS INVOKED BY TYPING THE LETTER Q. THIS
		; COMMAND PRODUCES A LISTING OF LOGICAL I/O DEVICES AND
		; THEIR CORRESPONDING PHYSICAL DEVICE ASSIGNMENTS. THE
		; DATA DISPLAYED IS EQUIVALENT TO THE CURRENT VALUE OF IOBYT.
		QUERY:
        CALL    TI              ; REQUIRE CR
        CPI     CR
        JNZ     ERROR
        MVI     B,4             ; SET UP OUTER LOOP COUNTER.
		                                ;   THERE ARE 4 LOGICAL DEVICES.
        LXI     H,LTBL          ; POINT HL AT LOGICAL DEVICE TABLE.
		Q0:                             ; OUTER LOOP
        CALL    CRLF            ; START A NEW LINE.
	        MOV     C,M             ; DISPLAY LOGICAL DEVICE IDENTIFIER.
        CALL    COM
        CALL    COMC            ; DISPLAY '='.
	        DB      '='
	        INX     H               ; POINT AT MASK FOR LOGICAL DEVICE.
	        MOV     A,M             ; FETCH MASK.
	        CMA                     ; INVERT IT
	        MOV     C,A             ; PUT IN C
	        INX     H               ; POINT AT PHYSICAL DEVICE TABLE
	        MOV     E,M             ; ADDRESS OF SUBORDINATE
	        INX     H               ; TABLE
	        MOV     D,M
	        INX     H
	        XCHG                    ; HL <- PHYSICAL DEVICE TABLE
        LDA     IOBYT
	        ANA     C               ; PHYSICAL SELECTION
	        PUSH    B               ; SAVE OUTER LOOP COUNTER
        MVI     B,4             ; SET UP INNER LOOP COUNTER
		Ql:                             ; INNER LOOP
	        MOV     C,M             ; GET PHYSICAL DEVICE IDENTIFIER
	        INX     H
	        CMP     M               ; TEST FOR EQUALITY
        JZ      Q2
	        INX     H               ; POINT AT NEXT ENTRY
	        DCR     B               ; DECREMENT INNER LOOP
        JNZ     Ql
		Q2:
        CALL    COM             ; DISPLAY PHYSICAL DEVICE
	        XCHG                    ; POINT AT MASTER TABLE
	        POP     B
	        DCR     B               ; DECREMENT OUTER LOOP
        JNZ     Q0
	        RET
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; 'R' COMMAND - READ HEXADECIMAL FILE
		;
		; THIS ROUTINE READS A HEXADECIMAL FILE FROM THE ASSIGNED
		; READER DEVICE AND LOADS IT INTO MEMORY. ONE HEXADECIMAL
		; PARAMETER IS EXPECTED. THIS PARAMETER IS A BASE ADDRESS
		; TO BE ADDED TO THE MEMORY ADDRESS OF EACH DATA BYTE ENCOUNTERED.
		; IN THIS WAY, HEXADECIMAL FILES MAY BE LOADED INTO MEMORY
		; IN AREAS OTHER THAN THAT FOR WHICH THEY WERE ASSEMBLED OR COMPILED.
		; ALL RECORDS READ ARE CHECKSUMMED AND COMPARED AGAINST THE
		; CHECKSUM IN THE RECORD. IF A CHECKSUM ERROR (OR TAPE READ ERROR)
		; OCCURS, THE ROUTINE TAKES AN ERROR EXIT. NORMAL LOADING IS
		; TERMINATED WHEN AN EOF RECORD IS ENCOUNTERED. THE ADDRESS
		; GIVEN WHEN THE EOF RECORD WAS CREATED (VIA THE lEI COMMAND) REPLACES
		; THE USER'S STORED PC VALUE ONLY IF THE ADDRESS WAS NONZERO.
		; A TRANSFER TO THE PROGRAM MAY THEN BE ACCOMPLISHED BY A IG<CR)'.
		READ:
	        DCR     C               ; GET ONE ADDRESS; C := 1
        CALL    EXPR            ; GET THE HEX BASE ADDRESS
        CALL    CRLF            ; OUTPUT A <CR>,<LF>
		RED0:
        CALL    RIX             ; GET AN ASCII CHARACTER FROM THE READER
        CPI     ':'             ; IS IT A START OF RECORD MARK (':')?
        JNZ     RED0            ; LOOP UNTIL WE FIND SUCH A RECORD MARK
	        XRA     A
	        MOV     D,A             ; D WILL CONTAIN THE CHECKSUM; INITIALIZE TO 0
        CALL    BYTE            ; READ 2 ASCII CHAR REPRESENTING THE RECORD
		                                ;   LENGTH AND DECODE THEM INTO 8 BITS BINARY
		                                ;   STORING THE RESULT IN A-REG
        JZ      RED3            ; JUMP IF ZERO RECORD LENGTH BECAUSE THIS
		                                ;   MEANS IT'S AN EOF RECORD SO WE'RE DONE
	        MOV     E,A             ; E := RECORD LENGTH
        CALL    BYTE            ; GET MSB OF LOAD ADDRESS
	        MOV     H,A             ; H := MSB OF LOAD ADDRESS
        CALL    BYTE            ; GET LSB OF LOAD ADDRESS
	        MOV     L,A             ; L := LSB OF LOAD ADDRESS
        CALL    BYTE            ; GET RECORD TYPE AND IGNORE IT
	        MOV     C,E             ; C := RECORD LENGTH
	        PUSH    H               ; STORE LOAD ADDRESS ON THE STACK
        LXI     H,-256          ; COMPUTE BUFFER POINTER
	        DAD     SP              ; HL NOW POINTS TO THAT PART OF THE MONITOR
		                                ;   STACK ONE PAGE (256 BYTES) BELOW WHERE
		                                ;   THE SP IS CURRENTLY POINTING
		                                ; WE WILL NOW READ DATA FROM THE FILE RECORD
		                                ; AND STORE THEM TEMPORARILY IN THE MONITOR'S
		                                ; STACK STARTING FROM A LOW MEMORY ADDRESS AND
		                                ; MOVING TOWARD A HIGHER MEMORY ADDRESS (REVERSE
		                                ; OF USUAL PROCEDURE WHERE STACK GROWS DOWN)
		RED1:
        CALL    BYTE            ; READ DATA; NOTE: 8 BITS OF MEMORY (DATA)
		                                ; IS REPRESENTED AS 2 HEX CHAR AND EACH HEX
		                                ; HEX CHAR IS REPRESENTED AS ONE 8 BIT ASCII CHAR
	        MOV     M,A             ; PUT DATA IN MONITOR BUFFER
	        INX     H               ; MOVE "UP" THE STACK
	        DCR     E               ; DECREMENT RECORD LENGTH COUNT
        JNZ     RED1            ; LOOP UNTIL RECORD LENGTH COUNTER IS 0
        CALL    BYTE            ; READ THE CHECKSUM RECORD FRAME --- PRIOR TO
		                                ;   CALL TO BYTE, D-REG CONTAINED SUM OF DATA
		                                ;   RECORDS. THE CHECKSUM FRAME SHOULD CONTAIN
		                                ;   THE NEGATIVE OF THIS SUM. BYTE ADDS D AND A
		                                ;   TOGETHER AND SETS THE ZERO BIT IF D = (-A)
        JNZ     ERROR           ; CHECKSUM ERROR
	        POP     D               ; DE = LOAD ADDRESS; STACK ENTRY POINTED TO BY SP
		                                ;   NOW CONTAINS BASE (BIAS) ADDRESS
	        XTHL                    ; HL = BIAS ADDRESS; CONTENTS OF STACK ENTRY
		                                ;   POINTED TO BY SP NOW IS ADDRESS ONE ABOVE
		                                ;   WHERE LAST DATA IS STORED IN MONITOR STACK 
	        XCHG                    ; DE BIAS ADDRESS, HL = LOAD ADDRESS
	        DAD     D               ; HL BIAS + LA
        MVI     B,0             ; BC RECORD LENGTH (RL)
	        DAD     B               ; HL BIAS + LA + RL
	        XCHG                    ; DE BIAS + LA + RL, HL = BIAS
	        XTHL                    ; HL POINTS TO ADDRESS 1 GREATER THAN WHERE LAST
		                                ;   DATA IS STORED IN MONITOR STACK
		;------------------------------
		RED2:                           ; LOAD INTO PROPER AREA IN RAM BUT IN
		                                ;   REVERSE ORDER
	        DCX     H               ; DECREMENT STACK BUFFER POINTER
	        MOV     A,M             ; A := DATA 
	        DCX     D               ; DECREMENT MEMORY POINTER
	        STAX    D               ; PUT DATA IN DESIGNATED ADDRESS
	        DCR     C               ; KEEP DOING THIS UNTIL RECORD LENGTH
        JNZ     RED2            ;   COUNT IS EXHAUSTED
        JMP     RED0            ; DONE WITH ONE RECORD, GO GET ANOTHER
		;-------------------------------
		RED3:                           ; EOF RECORD - ENTIRE FILE HAS BEEN READ IN
	        PUSH    B               ; SAVE B,C
        CALL    BYTE            ; GET MSB OF LOAD ADDRESS OF EOF RECORD ---
		                                ;   THIS IS THE <START ADDRESS> SPECIFIED IN
		                                ;   THE 'E' COMMAND. IF IT IS ZERO, DO NOT
		                                ;   MODIFY THE USER'S STORED PC IN EXIT TEMPLATE
	        MOV     B,A             ; B := MSB OF START ADDRESS
        CALL    BYTE            ; GET LSB OF START ADDRESS
	        MOV     C,A             ; C := LSB OF START ADDRESS
	        ORA     B               ; SEE IF START ADDRESS IS 0000
        JZ      RED4            ; JUMP IF IT IS (DON'T SET NEW PC)
        LHLD    MEMTOP
        MVI     L,PLOC & 0FFH ; HL POINTS TO PLOC IN EXIT CODE IN TOP OF RAM
	        MOV     M,B             ; STORE MSB OF START ADDRESS
	        DCX     H               ; HL POINTS TO PLOC - 1 OF EXIT CODE
	        MOV     M,C             ; STORE LSB OF START ADDRESS
		RED4:                           ; FINISH PROCESSING EOF RECORD
	        POP     B               ; RESTORE B,C
        CALL    BYTE            ; GET RECORD TYPE AND IGNORE IT
        CALL    BYTE            ; GET CHECKSUM
        JNZ     ERROR           ; JUMP IF CHECKSUM ERROR
	        POP     H               ; CUT BACK STACK POINTER
	        RET
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; 'S' COMMAND - SUBSTITUTE MEMORY
		;
		; THIS ROUTINE EXPECTS ONE PARAMETER FROM THE LOCAL CONSOLE, FOLLOWED
		; BY A SPACE. THE PARAMETER IS INTERPRETED AS A MEMORY LOCATI9N
		; AND THE ROUTINE WILL DISPLAY THE CONTENTS OF THAT LOCATION,
		; FOLLOWED BY A DASH (-). TO MODIFY MEMORY, TYPE IN THE NEW DATA
		; FOLLOWED BY A SPACE OR A CARRIAGE RETURN. IF NO MODIFICATION
		; OF THE LOCATION IS REQUIRED, TYPE ONLY A SPACE OR CARRIAGE RETURN.
		; IF A SPACE WAS LAST TYPED, THE NEXT MEMORY LOCATION WILL BE DISPLAYED
		; AND MODIFICATION OF IT IS ALLOWED. IF A CARRIAGE RETURN WAS ENTERED,
		; THE COMMAND IS TERMINATED.
		;
		SUBS:
        CALL     PARAM          ; GET MEMORY ADDRESS
	        RC                      ; ONLY CR ENTERED SO RETURN TO MAIN COMMAND LOOP
		SU0:
	        MOV     A,M             ; HL HAS REQUESTED MEMORY ADDRESS
        CALL    LBYTE           ; DISPLAY CONTENTS OF THAT ADDRESS
        CALL    COMC            ; OUTPUT PROMPT CHARACTER
	        DB      '-'
        CALL    PCHK
	        RC                      ; CR ENTERED, RETURN TO COMMAND MODE
        JZ      SU1             ; SPACE ENTERED, SPACE BY
	        XCHG                    ; SAVE MEMORY ADDRESS
        CALL    PA0             ; GET NEW VALUE
	        XCHG                    ; E = VALUE
	        MOV     M,E             ; STORE NEW VALUE
	        RC                      ; CR ENTERED AFTER VALUE, RETURN
		SU1:
	        INX     H               ; HL POINTS TO NEXT MEMORY LOCATION
        JMP     SU0
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; 'W' COMMAND - WRITE HEXADECIMAL FILE
		;
		; THIS ROUTINE EXPECTS TWO HEXADECIMAL PARAMETERS WHICH ARE
		; INTERPRETED AS THE BOUNDS OF A MEMORY AREA TO BE ENCODED
		; INTO HEXADECIMAL FORMAT AND PUNCHED ON THE ASSIGNED PUNCH
		; DEVICE.
		WRITE:
        CALL    EXPR            ; GET ADDRESS RANGE
        CALL    CRLF            ; NEW LINE
	        POP     D               ; DE := HIGH ADDRESS
	        POP     H               ; HL := LOW ADDRESS
		WR0:
        CALL    POC             ; EMIT RECORD MARK
	        DB      ':'
        LXI     B,16            ; INITIALIZE B := 0, C := AH (DECIMAL
		;-------------------------------
	        PUSH    H               ; SAVE HL
		WR1:
	        INR     B               ; INCREMENT RECORD LENGTH
	        DCR     C
        JZ      WR2             ; TERMINATE ON COUNT OF 16 BYTES
        CALL    HILO            ; OR END OF RANGE 
        JNC     WR1             ; WHICHEVER OCCURS FIRST
		;-------------------------------
		WR2:                            ; OUTPUT A DATA RECORD
	        POP     H               ; RESTORE HL := LOW ADDRESS
	        PUSH    D               ; SAVE HIGH ADDRESS
        MVI     D,0             ; INITIALIZE CHECKSUM D := 0
	        MOV     A,B             ; A := RECORD LENGTH
        CALL    PBYTE           ; EMIT RECORD LENGTH
        CALL    PADR            ; EMIT HL := LOW ADDRESS
	        XRA     A
        CALL    PBYTE           ; EMIT RECORD TYPE = 1
		;-------------------------------
		WR3:
	        MOV     A,M             ; FETCH DATA
        CALL    PBYTE           ; EMIT IT
	        INX     H               ; INCREMENT MEMORY ADDRESS
	        DCR     B               ; DECREMENT COUNT
        JNZ     WR3             ; LOOP UNTIL ENTIRE RECORD HAS BEEN OUTPUT
	        XRA     A
	        SUB     D               ; D CONTAINS RUNNING CHECKSUM
        CALL    PBYTE           ; EMIT CHECKSUM := -D
	        POP     D               ; RESTORE DE := HIGH ADDRESS
	        DCX     H               ; BACKUP MEMORY POINTER
		                                ; NOW PUNCH CR,LF --- IGNORED BY THE 'R'
		                                ;   COMMAND BUT HANDY IF LISTING PUNCHED
		                                ;   TAPE ON THE TTY
        CALL    POC             ; PUNCH CARRIAGE RETURN
	        DB      CR
        CALL    POC             ; PUNCH LINE FEED CHARACTER
	        DB      LF
        CALL    HILO            ; TEST FOR TERMINATION
        JNC     WR0             ; IF NOT DONE, FORM NEXT RECORD AND OUTPUT IT
	        RET
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; 'X' COMMAND - EXAMINE AND MODIFY CPU REGISTERS
		;
		; THIS ROUTINE ALLOWS THE OPERATOR TO EXAMINE AND/OR MODIFY
		; THE CONTENTS OF THE USER PROGRAM'S REGISTERS. THE REGISTER
		; VALUES WERE STORED AS A RESULT OF A PREVIOUS BREAKPOINT AND
		; WILL BE RESTORED TO THE USER PROGRAM DURING A SUBSEQUENT 'G'
		; COMMAND.
		X:
        LXI     H,ACTBL         ; POINT TO ACCESS TABLE
        CALL    PCHK            ; GET REGISTER IDENTIFIER
        JC      X5              ; IF CARRY = 1, CR ENTERED
        MVI     C,NREGS
		X0:
	        CMP     M 
        JZ      X1              ; MATCHED REGISTER IDENTIFIER
	        INX     H               ; POINT TO NEXT TABLE ENTRY
	        INX     H
	        INX     H
	        DCR     C               ; DECREMENT REGISTER COUNTER
        JNZ     X0              ; TRY AGAIN
        JMP     ERROR           ; NOT IN TABLE, ERROR
		X1:
        CALL    BLK
		X2:
        CALL    DREG            ; DISPLAY THE REGISTER
        CALL    COMC
	        DB      '-'             ; TYPE PROMPT
        CALL    PCHK            ; SKIP IF NULL ENTRY
	        RC                      ; CR ENTERED, RETURN TO COMMAND MODE
        JZ      X4
	        PUSH    H               ; SAVE POINTER TO ACTBL
	        PUSH    B               ; SAVE PRECISION
        CALL    PA0             ; GET NEW REG VALUE
	        MOV     A,L
	        STAX    D               ; STORE LSB IN REGISTER AREA
	        POP     PSW             ; RETRIEVE PRECISION (A)
	        ORA     A               ; SET SIGN
        JM      X3              ; 8 BITS ONLY
	        INX     D
	        MOV     A,H
	        STAX    D               ; STORE MSB IN REGISTER AREA
		X3:
	        POP     H               ; RETRIEVE ACTBL POINTER
		X4:
	        XRA     A
	        ORA     M
	        RM                      ; END OF TABLE, RETURN TO COMMAND MODE
	        MOV     A,B             ; TEST DELIMITER
        CPI     CR
	        RZ                      ; CR ENTERED, RETURN TO COMMAND MODE
        JMP     X2
		;       ---------------------------------------------------------------
		X5:                             ; DISPLAY ALL THE REGISTER VALUES
        CALL    CRLF
		X6:
        CALL    BLK             ; OUTPUT A SPACE
	        XRA     A               ; CLEAR A
	        ORA     M               ; SET CONDITION CODES
	        RM                      ; ALL DONE, RETURN TO COMMAND MODE
	        MOV     C,M             ; C CONTAINS A REGISTER IDENTIFIER (A,B,C,D ��� )
        CALL    COM             ; PRINT CHARACTER
        CALL    COMC            ; PRINT EQUAL SIGN
	        DB      '='
        CALL    DREG            ; DISPLAY REGISTER CONTENTS
        JMP     X6              ; CONTINUE
		;
		; TABLE FOR ACCESSING REGISTERS
		; TABLE CONTAINS:
		;       (1) REGISTER IDENTIFIER
		;       (2) LOCATION ON STORAGE PAGE
		;       (3) PRECISION
		ACTBL:
        DB      'A',    ALOC & HMSK,      0
        DB      'B',    BLOC & HMSK,      0
        DB      'C',    CLOC & HMSK,      0
        DB      'D',    DLOC & HMSK,      0
        DB      'E',    ELOC & HMSK,      0
        DB      'F',    FLOC & HMSK,      0
        DB      'H',    HLOC & HMSK,      0
        DB      'I',    ILOC & HMSK,      0
        DB      'L',    LLOC & HMSK,      0
        DB      'M',    HLOC & HMSK,      1
        DB      'P',    PLOC & HMSK,      1
        DB      'S',    SLOC & HMSK,      1
	        DB      -1
NREGS   EQU     ($-ACTBL)/3     ; LENGTH OF ACCESS TABLE
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; 'z' COMMAND - TRANSFER CONTROL TO DIAGNOSTIC PROGRAM IN PROM
		; THIS ROUTINE EXPECTS A '$' AT WHICH POINT IT WILL CALL THE DIAGNOSTIC PROGRAM.
		Z:
        CALL    TI              ; GET A CHARACTER FROM THE CONSOLE
        CPI     '$'             ; IS IT A '$'?
        JNZ     ERROR           ; ERROR IF IT ISN'T
        CALL    TI              ; GET A CHARACTER FROM THE CONSOLE
        CPI     CR              ; EXPECT A CARRIAGE RETURN
        JNZ     ERROR           ; ERROR IF IT ISN'T
        MVI     A,BTDGON        ; TURN ON THE BOOT/DIAGNOSTIC PROM
        OUT     CPUC
        CALL    DIAGMN          ; CALL THE DIAGNOSTIC PROGRAM
	        RET                     ; RETURN TO MAIN COMMAND LOOP
		;********************************************************************************
		;*                                                                              *
		;*  END OF MONITOR COMMANDS, BEGINNING OF I/O ROUTINES                          *
		;*                                                                              *
		;********************************************************************************
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; 'CI' - EXTERNALLY REFERENCED ROUTINE                                          ;
		;        ENTERED VIA CALL FROM 'TI' ROUTINE                                     ;
		; PROCESS: LOCAL CONSOLE INPUT CODE                                             ;
		; INPUT:                                                                        ;
		; OUTPUT: CHARACTER RETURNED IN A-REG                                           ;
		; MODIFIED: A, FLAGS                                                            ;
		; STACK USAGE: 2 BYTES                                                          ;
		; EXPLANATION: BASED ON I/O STATUS BYTE (IOBYT), DECIDE IF CONSOLE INPUT        ;
		;   DEVICE IS TTY, CRT, BATCH, OR USER-DEFINED DEVICE. IF IT IS TTY OR CRT      ;
		;   LOOP UNTIL READ, INPUT THE CHARACTER, THEN RETURN. IF IT IS BATCH,          ;
		;   JUMP TO 'RI' ROUTINE. IF IT IS USER-DEFINED DEVICE, JUMP TO @USER.          ;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		CI:                             ; LOCAL CONSOLE INPUT
        LDA     IOBYT           ; GET STATUS BYTE
        ANI     NCMSK        ; LOOK AT ONLY CONSOLE FIELD
        JNZ     CI0             ; JUMP IF CONSOLE IS NOT TTY
		;-------------------------------
		; CONSOLE = TTY
		TTYIN:
        IN      TTYS            ; TTY STATUS PORT
        ANI     RRDY            ; CHECK FOR RECEIVE BUFFER READY
        JZ      TTYIN           ; LOOP UNTIL IT IS READY
        IN      TTYI            ; INPUT CHARACTER FROM TTY
	        RET                     ; RETURN; CHARACTER IN A-REG
		;-------------------------------
		; CONSOLE = CRT, BATCH, OR USER-DEFINED
		CI0:
        CPI     CCRT            ; LOCAL CONSOLE = CRT?
        JNZ     CI4             ; JUMP IF CONSOLE IS NOT CRT
	        PUSH    H               ; SAVE HL
        LHLD    MEMTOP
        MVI     L,(ILOC-1) & 0FFH; HL NOW POINTS TO CONFIGURATION BYTE STORED
		                                ;   IN EXIT TEMPLATE IN TOP PAGE OF RAM
	        MOV     A,M             ; A := CONFIGURATION BYTE
	        POP     H               ; RESTORE HL
	        RRC                     ; ROTATE BIT 0 INTO CARRY BIT, THUS CARRY = 1
		                                ;   MEANS RUNNING ON SYSTEM WITHOUT INTEGRATED
		                                ; CRT
        JNC     CI2             ; JUMP IF INTEGRATED CRT IS PRESENT
		;-------------------------------
		; CONSOLE = SERIAL CRT
		CI1:
        IN      USCS            ; INPUT CRT STATUS
        ANI     RRDY            ; CHECK FOR RECEIVER BUFFER READY
        JZ      CI1             ; LOOP UNTIL IT IS READY
        IN      USCI            ; GET CHARACTER FROM THE CRT
	        RET                     ; RETURN; CHARACTER IS IN A-REG
		;-------------------------------
		; CONSOLE = INTEGRATED CRT
		CI2:
	        PUSH    B               ; SAVE B,C
		CI3:
        MVI     B,KSTS          ; LOAD KEYBOARD STATUS COMMAND
        CALL    IOCDR1          ; INPUT KEYBOARD STATUS FROM IOC
        ANI     KRDY            ; IS THE KEYBOARD READY?
        JZ      CI3             ; LOOP UNTIL IT IS
        MVI     B,KEYC          ; LOAD INPUT DATA COMMAND
        CALL    IOCDR1          ; INPUT DATA FROM THE KEYBOARD
	        POP     B               ; RESTORE B,C
	        RET                     ; RETURN; CHARACTER IS IN A-REG
		;-------------------------------
		; CONSOLE IS BATCH OR USER-DEFINED DEVICE
		CI4:
        CPI     BATCH
        JZ      RI              ; BATCH MODE, INPUT = READER
        MVI     A,CILOC & HMSK; USER DEFINE LOCAL CONSOLE INPUT
		;        JMP     @USER
        JMP     MUSER
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; 'BREAK' - ENTERED VIA CALLS FROM 'BLK','COM','LOM ' ROUTINES
		; PROCESS: TEST FOR OPERATOR INTERRUPTION OF COMMAND (I.E. DID OPERATOR
		;          DEPRESS THE "BREAK" KEY)
		; INPUT:
		; OUTPUT:
		; MODIFIED: A,FLAGS
		; STACK USAGE: 4 BYTES
		BREAK:
        CALL    CSTS            ; SEE IF A KEY WAS DEPRESSED
	        ORA     A
	        RZ                      ; NO CHARACTER READY
        JMP     TI              ; GET THE CHARACTER
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; 'RI' - EXTERNALLY REFERENCED ROUTINE                                          ;
		;       ENTERED VIA CALLS FROM 'CI','RIX' ROUTINES                              ;
		; PROCESS: READER INPUT CODE                                                    ;
		; INPUT:                                                                        ;
		; OUTPUT: CARRY = 0 AND VALID CHARACTER IN A-REG, OTHERWISE                     ;
		; CARRY = 1 AND INVALID DATA (ZEROES) IN A-REG                                  ;
		; MODIFIED: A, FLAGS                                                            ;
		; STACK USAGE: 8 BYTES                                                          ;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		RI:                             ; READER INPUT
	        PUSH    H               ; SAVE HL
        LDA     IOBYT           ; GET STATUS BYTE
        ANI     NRMSK        ; GET READER BITS
        JNZ     RI5             ; JUMP IF READER IS NOT THE TTY
		;-------------------------------
		; READER = TTY
	        PUSH    B               ; SAVE BC
        MVI     A,DISABL        ; HOLD UP INTERRUPTS WHILE TAPE IS ADVANCING
        OUT     CPUC
        IN      TTYI            ; CLEAR RECEIVE BUFFER BY READING IN ANY
		                                ;   DATA THAT MAY BE THERE
		RI0:
        IN      TTYS            ; READ IN USART STATUS
        ANI     TXBE            ; CHECK FOR TRANSMITTER BUFFER EMPTY
        JZ      RI0             ; TRY AGAIN IF NOT EMPTY
        MVI     A,TADV          ; ADVANCE THE TAPE
        OUT     TTYC            ; OUTPUT THE ADVANCE COMMAND
        MVI     B,RADCT         ; INITIALIZE TIMER FOR 45 MS.
		RI1:
        CALL    DELAY           ; DELAY FOR 1 MILLISECONDS
	        DCR     B               ; DECREMENT TIMER
        JNZ     RI1             ; JUMP IF TIMER NOT EXPIRED
        MVI     A,COMD          ; STOP THE READER ADVANCE
        OUT     TTYC            ; OUTPUT STOP COMMAND
        MVI     B,RTOCT         ; INITIALIZE TIMER FOR 250 MS.
		RI2:
        IN      TTYS            ; INPUT READER STATUS
        ANI     RRDY            ; CHECK FOR RECEIVER BUFFER READY
        JNZ     RI4             ; YES - DATA IS READY
        CALL    DELAY           ; DELAY 1 MS
	        DCR     B               ; DECREMENT TIMER
        JNZ     RI2             ; JUMP IF TIMER NOT EXPIRED
		RI3:
	        XRA     A               ; ZERO A, RESET CARRY
	        STC                     ; SET CARRY INDICATING EOF
        JMP     RI4B
		RI4:
        IN      TTYI
	        ORA     A               ; CLEAR CARRY
		RI4B:
	        PUSH    PSW             ; SAVE DATA
        MVI     A,ENABL         ; PERMIT INTERRUPTS TO GO THROUGH
        OUT     CPUC
	        POP     PSW
	        POP     B               ; RESTORE BC
	        POP     H
	        RET                     ; RETURN
		;-------------------------------
		; READER IS PTR, USER-DEV-1, OR USER-DEV-2
		RI5:
        CPI     RPTR            ; IS READER THE PAPER TAPE READER?
        JNZ     RI8             ; JUMP IF IT ISN'T
		;-------------------------------
		; READER = PAPER TAPE READER
	        PUSH    B               ; SAVE BC
        MVI     B,RDRC | PTRADV; LOAD READER ADVANCE 1 FRAME COMMAND
        CALL    PIOCOM          ; OUTPUT THE COMMAND
        MVI     H,TOUT          ; 250 MS. TIMEOUT COUNTER
		RI6:
        MVI     B,RSTC          ; LOAD READER STATUS COMMAND
        CALL    PIODR1          ; READ STATUS
        ANI     PTRDY           ; IS THE READER READY?
        JNZ     RI7             ; JUMP IF IT IS
        CALL    DELAY           ; STALL FOR 1 MS.
	        DCR     H               ; 250 MS. TIMEOUT LOOP
        JNZ     RI6
        JMP     RI3             ; 250 MS. ARE UP; RETURN WITH CARRY = 1 (EOF COND)
		RI7:                            ; THE PAPER TAPE READER IS READY
        MVI     B,RDRC          ; LOAD READER COMMAND
        CALL    PIODR1          ; READ A CHARACTER FROM THE PAPER TAPE READER
	        ORA     A               ; RESET CARRY BIT
	        POP     B               ; RESTORE BC
	        POP     H
	        RET                     ; RETURN SUCCESSFULLY WITH CARRY
		;-------------------------------
		; READER IS USER-DEFINED DEVICE 1 OR DEVICE 2
		RI8:
	        POP     H
        CPI     RUSE1
        MVI     A,R1LOC & HMSK
		;        JZ      @USER           ; READER USER-DEFINED DEVICE 1
        JZ      MUSER
        MVI     A,R2LOC & HMSK
		;*******JMP     @USER           ; READER USER-DEFINED DEVICE 2
		;*******JMP     USER            ; READER USER-DEFINED DEVICE 2
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; '@USER' - ENTERED VIA JUMPS FROM 'LO','LOM','RI','CI','BLK','COM',
		;           'CO','POC','PO','CSTS' ROUTINES
		;         ENTERED VIA FALL-THRU FROM 'RI' ROUTINE
		; PROCESS: USER-DEFINED I/O ENTRY POINT TRANSFER LOGIC
		; INPUT: A-REG CONTAINS LSB ADDRESS PTR INTO USER-DEFINED ENTRY POINT TABLE (XTBL)
		; OUTPUT:
		; MODIFIED:
		; STACK USAGE:
		; @USER:
		MUSER:
	        PUSH    H               ; SAVE HL, CREATE A STACK ENTRY
        LHLD    MEMTOP
	        MOV     L,A             ; HL NOW POINTS TO PROPER USER ENTRY POINT IN
		                                ;   XTBL IN EXIT TEMPLATE IN TOP PAGE OF RAM
	        XTHL                    ; RESTORE HL; SP NOW POINTS TO USER ENTRY POINT
	        RET                     ; BEGIN EXECUTING AT THIS ENTRY POINT
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; 'CO' - EXTERNALLY REFERENCED ROUTINE                                          ;
		;        ENTERED VIA CALL FROM 'TI' ROUTINE                                     ;
		; 'BLK' - ENTERED VIA CALLS FROM 'H', 'X' COMMANDS                              ;
		; 'COM' - ENTERED VIA CALLS FROM 'Q', 'X' COMMANDS                              ;
		;         ENTERED VIA JUMPS FROM 'COMC', 'HXD' ROUTINES                         ;
		; 'TTYOUT' - ENTERED VIA JUMPS FROM 'LOM','LO','POC','PO' ROUTINES              ;
		; 'CRTOUT' - ENTERED VIA JUMPS FROM 'LOM','LO' ROUTINES                         ;
		;            ENTERED VIA CALL FROM BOOTSTRAP PROGRAM                            ;
		; PROCESS: LOCAL CONSOLE OUTPUT CODE                                            ;
		; INPUT: VALUE IN C-REG                                                         ;
		; OUTPUT: DATA OUTPUT TO APPROPR:IATE DEVICE                                    ;
		; MODIFIED: A, FLAGS, C                                                         ;
		; STACK USAGE: 2 BYTES                                                          ;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		BLK:
        MVI     C,' '           ; PRINT A BLANK
		COM:                            ; LOCAL CONSOLE OUTPUT
        LDA     IOBYT           ; GET STATUS BYTE
        ANI     NCMSK        ; LOOK ONLY AT CONSOLE FIELD
        CPI     BATCH           ; IS CONSOLE = BATCH?
        CNZ     BREAK           ; IF SO, DO NOT HONOR BREAK KEY IN BATCH MODE
		                                ; IF IT ISN'T, THEN TEST FOR BREAK KEY
		CO:                             ; EXTERNAL ENTRY POINT
        LDA     IOBYT           ; GET STATUS BYTE
        ANI     NCMSK        ; LOOK ONLY AT CONSOLE FIELD
        JNZ     CO0             ; JUMP IF CONSOLE IS NOT TTY
		;-------------------------------
		; CONSOLE = TTY
		TTYOUT:
        IN      TTYS            ; LOCAL CONSOLE = TTY; GET TTY STATUS
        ANI     TRDY            ; IS IT READY?
        JZ      TTYOUT          ; LOOP UNTIL IT IS
	        MOV     A,C             ; LOAD CHARACTER TO BE OUTPUT
        OUT     TTYO            ; OUTPUT CHARACTER
	        RET                     ; RETURN
		;-------------------------------
		; CONSOLE IS CRT, BATCH, OR USER-DEFINED
		CO0:
        CPI     BATCH           ; CONSOLE = BATCH?
        JZ      LO              ; JUMP TO LIST OUTPUT IF IT IS
        CPI     CCRT            ; LOCAL CONSOLE = CRT?
        MVI     A,COLOC & 0FFH
		;        JNZ     @USER           ; JUMP IF IT ISN'T, I.E. CONSOLE IS
        JNZ     MUSER            ; JUMP IF IT ISN'T, I.E. CONSOLE IS
		                                ;   USER DEFINED LOCAL CONSOLE OUTPUT
		;-------------------------------
		; CONSOLE = CRT
		CRTOUT:
	        PUSH    H               ; SAVE H,L
        LHLD    MEMTOP
        MVI     L,(ILOC-1) & 0FFH; HL NOW POINTS TO CONFIGURATION BYTE IN EXIT TEMPLATE 
	        MOV     A,M             ; A NOW CONTAINS THIS CONFIGURATION BYTE
	        POP     H               ; RESTORE H,L
	        RRC                     ; ROTATE BIT 0 INTO CARRY BIT; THUS CARRY
		                                ;   1 IF INTEGRATED CRT NOT PRESENT
        JNC     CRTOT2          ; JUMP IF INTEGRATED CRT
		;-------------------------------
		; CONSOLE = SERIAL CRT
		CRTOT1:                         ; INTELLEC WITH SERIALLY CONNECTED CRT
        IN      USCS            ; INPUT CRT STATUS
        ANI     TRDY            ; IS IT READY?
        JZ      CRTOT1          ; LOOP UNTIL IT IS
	        MOV     A,C             ; MOVE CHARACTER TO BE OUTPUT TO A-REG
        OUT     USCO            ; OUTPUT IT TO THE CRT
	        RET
		;-------------------------------
		; CONSOLE = INTEGRATED CRT
		CRTOT2:                         ; INTELLEC WITH INTEGRATED CRT
	        MOV     A,C             ; MOVE CHARACTER TO SE OUTPUT TO A-REG
	        PUSH    B               ; SAVE B,C
		                                ; CRT IS ALWAYS READY AND PRESENT - NO NEED
		                                ; TO CHECK ITS STATUS
        MVI     B,CRTC          ; LOAD OUTPUT TO CRT COMMAND
        CALL    IOCDR2          ; OUTPUT DATA TO CRT
	        POP     B               ; RESTORE B,C
	        RET
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; 'COMC' - ENTERED VIA CALLS FROM 'G','Q','S','X' COMMANDS AND 'ERROR',
		;          'START','CRLF','RESTART' ROUTINES
		; PROCESS: LOCAL CONSOLE OUTPUT OF CONSTANT DATA
		; INPUT: SP
		; OUTPUT: CONTENTS OF ADDRESS POINTED TO BY SP IS A RETURN ADDRESS TWO GREATER
		;         THAN THAT OF THE CALL COMC INSTRUCTION
		; MODIFIED: C,H,L
		; STACK USAGE: 2 BYTES
		COMC:
	        XTHL                    ; SINCE COMC WAS CALLED, SP NOW POINTS TO A STACK
		                                ;   ENTRY CONTAINING THE ADDRESS OF THE NEXT
		                                ;   INSTRUCTION, WHICH IN THIS CASE IS A DB.
		                                ;   HL NOW POINTS TO THIS DB.
	        MOV     C,M             ; C NOW CONTAINS THE CHARACTER TO BE OUTPUT
	        INX     H               ; BUMP RETURN ADDRESS,I.E. POINT IT BEYOND THE DB.
	        XTHL                    ; SP MODIFIED, HL IS AS IT WAS ORIGINALLY
        JMP     COM             ; OUTPUT IT
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; 'PO' - EXTERNALLY REFERENCED ROUTINE                                          ;
		;        ENTERED VIA CALL FROM 'PBYTE' ROUTINE                                  ;
		; 'POC' - ENTERED VIA CALLS FROM 'E','N','W' COMMANDS AND 'LEAD','PEOL'         ;
		;         ROUTINES                                                              ;
		; PROCESS: PUNCH OUTPUT CODE                                                    ;
		; INPUT: VALUE IN C-REG                                                         ;
		; OUTPUT:                                                                       ;
		; MODIFIED: A, FLAGS, C                                                         ;
		; STACK USAGE: 2 BYTES                                                          ;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		POC:                            ; PUNCH A CONSTANT
	        XTHL                    ; SINCE POC ENTERED VIA CALL, SP POINTS TO STACK
		                                ;   ENTRY CONTAINING ADDRESS OF NEXT INSTRUCTION
		                                ;   WHICH IS A DB. HL NOW POINTS TO THIS DB.
	        MOV     C,M             ; C NOW CONTAINS CHARACTER TO BE PUNCHED
	        INX     H               ; BUMP RETURN ADDRESS,I.E. POINT IT BEYOND DB
	        XTHL                    ; SP MODIFIED, HL IS AS IT WAS ORIGINALLY
		PO:                             ; PUNCH OUTPUT
        LDA     IOBYT           ; GET STATUS BYTE
        ANI     NPMSK        ; GET PUNCH BITS
        JZ      TTYOUT          ; JUMP IF PUNCH ISN'T TTY
        CPI     PPTP            ; IS PUNCH = PAPER TAPE PUNCH?
        JNZ     PO1             ; JUMP IF IT ISN'T
		;-------------------------------
		; PUNCH = PAPER TAPE PUNCH
	        PUSH    B               ; SAVE BC
		PO0:                            ; PUNCH = PTP
        MVI     B,PSTC          ; LOAD PUNCH STATUS COMMAND
        CALL    PIODR1          ; READ STATUS
        ANI     PTPRY           ; IS THE PUNCH READY?
        JZ      PO0             ; LOOP UNTIL READY
        MVI     B,PUNC          ; LOAD PUNCH OUTPUT COMMAND
        CALL    PIODR3          ; OUTPUT CHARACTER THAT WAS IN C-REG
	        POP     B               ; RESTORE BC
	        RET
		;-------------------------------
		; PUNCH IS USER-DEFINED DEVICE 1 OR DEVICE 2
		PO1:
        CPI     PUSE1
        MVI     A,P1LOC & 0FFH
		;        JZ      @USER           ; PUNCH = USER DEFINED PUNCH 1
        JZ      MUSER            ; PUNCH = USER DEFINED PUNCH 1
        MVI     A,P2LOC & 0FFH
		;        JMP     @USER           ; PUNCH = USER DEFINED PUNCH 2
        JMP     MUSER            ; PUNCH = USER DEFINED PUNCH 2
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; 'LO' - EXTERNALLY REFERENCED ROUTINE                                          ;
		;        ENTERED VIA JUMPS FROM 'COM','CO','BLK' ROUTINES                       ;
		; 'LOM' - ENTERED VIA CALLS FROM 'D' COMMAND AND 'DBYTE','LCRLF' ROUTINES       ;
		;         ENTERED VIA JUMPS FROM 'DBYTE','LCRLF' ROUTINES                       ;
		; PROCESS: LIST OUTPUT                                                          ;
		; INPUT: VALUE IN C-REG                                                         ;
		; OUTPUT:                                                                       ;
		; MODIFIED: A, FLAGS, C                                                         ;
		; STACK USAGE: 2 BYTES                                                          ;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		LOM:                            ; LIST OUTPUT ON CONSOLE
        LDA     IOBYT
        ANI     NCMSK        ; LOOK ONLY AT CONSOLE FIELD OF IOBYT
        CPI     BATCH           ; IS CONSOLE ASSIGNED TO BATCH MODE?
        CNZ     BREAK           ; IF IT ISN'T, WE SHOULD TEST FOR BREAK KEY
		                                ;   I.E. IN BATCH. MODE THE BREAK KEY IS NOT
		                                ;   HONORED
		LO:                             ; LIST OUTPUT
        LDA     IOBYT           ; GET STATUS BYTE
        ANI     ~ LMSK        ; LOOK AT LIST FIELD
        JZ      TTYOUT          ; JUMP IF LIST = TTY
        CPI     LCRT
        JZ      CRTOUT          ; JUMP IF LIST = CRT
        CPI     LUSE            ; TEST FOR USER DEFINED LIST DEVICE
        MVI     A,LILOC & 0FFH; A := LSB OF LILOC ADDRESS
		;        JZ      @USER           ; JUMP IF LIST = USER-DEFINED DEVICE
        JZ      MUSER            ; JUMP IF LIST = USER-DEFINED DEVICE
		;-------------------------------
		; LIST = LPT
	        PUSH    B               ; SAVE BC
		LP0:
        MVI     B,LSTC          ; LOAD LINE PRINTER STATUS COMMAND
        CALL    PIODR1          ; READ STATUS
        ANI     LPTRY           ; IS IT READY?
        JZ      LP0             ; LOOP UNTIL IT IS
        MVI     B,LPTC          ; LOAD LINE PRINTER PRINT COMMAND
        CALL    PIODR3          ; OUTPUT CHARACTER CONTAINED IN C-REG
	        POP     B               ; RESTORE BC
	        RET
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; 'CSTS' - EXTERNALLY REFERENCED ROUTINE                                        ;
		;          ENTERED VIA CALL FROM 'BREAK' ROUTINE                                ;
		; PROCESS: LOCAL CONSOLE INPUT STATUS                                           ;
		; INPUT:                                                                        ;
		; OUTPUT: A-REG CONTAINS 00 IF NO KEY HAS BEEN DEPRESSED,                       ;
		; A-REG CONTAINS FFH IF A KEY HAS BEEN DEPRESSED                                ;
		; MODIFIED: A, FLAGS                                                            ;
		; STACK USAGE: 2 BYTES                                                          ;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		CSTS:                           ; LOCAL CONSOLE INPUT STATUS
        LDA     IOBYT           ; GET STATUS BYTE
        ANI     NCMSK        ; LOOK ONLY AT CONSOLE FIELD OF IOBYT
        JNZ     CS0             ; JUMP IF CONSOLE IS NOT TTY
		;-------------------------------
		; CONSOLE = TTY
        IN      TTYS            ; GET TTY STATUS
        ANI     RRDY            ; IS RECEIVE BUFFER READY? (IF TTY KEY WAS
        JMP     CS2             ;   DEPRESSED, ZERO BIT WILL BE RESET)
		;-------------------------------
		; CONSOLE = CRT, BATCH, OR USER-DEFINED
		CS0:
        CPI     CCRT            ; CONSOLE = CRT?
        JNZ     CS3             ; JUMP IF CONSOLE IS NOT CRT
	        PUSH    H               ; SAVE H,L
        LHLD    MEMTOP
        MVI     L,(ILOC-1) & 0FFH; HL POINTS TO CONFIGURATION BYTE IN EXIT TEMPLATE
	        MOV     A,M             ; A CONTAINS THIS CONFIGURATION BYTE
	        POP     H               ; RESTORE H,L
	        RRC                     ; ROTATE BIT " INTO CARRY; THUS CARRY = 1
		                                ;   MEANS INTEGRATED CRT NOT PRESENT
        JNC     CS1             ; JUMP IF INTEGRATED CRT PRESENT
		;-------------------------------
		; CONSOLE = SERIAL CRT
        IN      USCS            ; GET CRT STATUS
        ANI     RRDY            ; IS RECEIVE BUFFER READY? (IF KEY HAS BEEN
        JMP     CS2             ;   DEPRESSED, ZERO BIT WILL BE RESET)
		;-------------------------------
		; CONSOLE = INTEGRATED CRT
		CS1:                            ; INTELLEC WITH INTEGRATED CRT
	        PUSH    B               ; SAVE B,C
        MVI     B,KSTS          ; LOAD CRT STATUS COMMAND
        CALL    IOCDR1          ; GET CRT STATUS
        ANI     KRDY            ; IS RECEIVE BUFFER READY? (IF KEY HAS BEEN
		                                ;   DEPRESSED, ZERO BIT WILL BE RESET)
	        POP     B               ; RESTORE B,C
		CS2:                            ; COMMON RETURN POINT FOR CRT,TTY
        MVI     A,MFALSE         ; INITIALIZE A-REG TO 00
	        RZ                      ; RETURN WITH A := 00 IF NO DATA AVAILABLE
	        CMA
	        RET                     ; RETURN WITH A := FF IF DATA AVAILABLE
		;-------------------------------
		; CONSOLE = BATCH OR USER-DEFINED DEVICE
		CS3:
        CPI     BATCH           ; IS IT BATCH?
        MVI     A,MTRUE
	        RZ                      ; RETURN IF CONSOLE IS BATCH; A := FF
        MVI     A,CSLOC & 0FFH; CONSOLE = USER DEFINED LOCAL CONSOLE, BRANCH
		                                ;   TO USER'S OWN STATUS ROUTINE
		;        JMP     @USER
        JMP     MUSER
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; 'IOCHK' - EXTERNALLY REFERENCED ROUTINE                                       ;
		; PROCESS: GET I/O SYSTEM STATUS                                                ;
		; INPUT:                                                                        ;
		; OUTPUT: STATUS BYTE RETURNED IN A-REG                                         ;
		; MODIFIED: A                                                                   ;
		; STACK USAGE: 2 BYTES                                                          ;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		IOCHK:
        LDA     IOBYT           ; GET STATUS BYTE
	        RET                     ; RETURN
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; 'IOSET' - EXTERNALLY REFERENCED ROUTINE                                       ;
		; PROCESS: SET I/O CONFIGURATION                                                ;
		; INPUT: NEW I/O STATUS BYTE IN C-REG                                           ;
		; OUTPUT: IOBYT CONTAINS NEW I/O CONFIGURATION                                  ;
		; MODIFIED: A, C                                                                ;
		; STACK USAGE: 2 BYTES                                                          ;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		IOSET:
	        MOV     A,C
        STA     IOBYT           ; PUT NEW IOBYT IN MEMORY
	        RET                     ; RETURN
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; 'MEMCHK' -EXTERNALLY REFERENCED ROUTINE                                       ;
		; PROCESS: RETURN ADDRESS OF CONTIGUOUS END OF USER MEMORY                      ;
		; INPUT: MEMTOP,USER                                                            ;
		; OUTPUT: ADDRESS IS RETURNED IN B-REG (MSB) AND A-REG (LSB)                    ;
		; MODIFIED: A,B,FLAGS                                                           ;
		; STACK USAGE: 2 BYTES                                                          ;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		MEMCHK:
        LDA     MEMTOP+1        ; MSB OF ADDRESS OF TOP PAGE OF MEMORY
	        DCR     A               ; CHANGE IT TO THE PAGE BELOW THE TOP PAGE
		                                ;   RECALL TOP PAGE IS USED BY MONITOR SO
		                                ;   USER SHOULD NOT ACCESS IT 
	        MOV     B,A             ; SO MSB GOES IN B-REG
        MVI     A,USER & 0FFH ; LSB IN A-REG
	        RET                     ; AB POINTS TO BASE OF USER STACK IN SECOND
		                                ;   FROM TOP PAGE OF RAM
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; 'IODEF ' - EXTERNALLY REFERENCED ROUTINE                                      ;
		; PROCESS: DEFINE USER I/O ENTRY POINTS                                         ;
		; INPUT: SELECTION CODE IN C-REG, USER ENTRY POINT ADDRESS IN D,E               ;
		; OUTPUT:                                                                       ;
		; MODIFIED: A, FLAGS                                                            ;
		; STACK USAGE: 8 BYTES                                                          ;
		; EXPLANATION: POINT HL TO TABLE OF USER ENTRY POINTS IN TOP OF RAM;            ;
		;   SUBSTITUTE IN THERE THE ADDRESS GIVEN BY THE USER IN DE REGISTERS           ; 
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		IODEF: 
	        PUSH    H               ; SAVE H & L
	        PUSH    B               ; SAVE B & C
        LHLD    MEMTOP          ; GET XTBL+1`
        MVI     L,(XTBL+1) & 0FFH; HL NOW POINTS TO XTBL+1 IN TOP PAGE OF RAM 
	        MOV     A,C             ; A := LOGICAL DEVICE CATEGORY
        CPI     UCS+1
        JNC     ERROR           ; INVALID SELECTION CODE
	        ADD     C               ; DOUBLE INDEX
	        ADD     C               ; TRIPLE INDEX
	        MOV     C,A
        MVI     B,0
	        DAD     B               ; COMPUTE PROPER INDEX INTO XTBL
	        MOV     M,E             ; STORE BRANCH OPERAND IN INSTRUCTION
	        INX     H
	        MOV     M,D             ; STORE THE USER-DEFINED I/O ENTRY ROUTINE
		                                ;   ADDRESS IN THE PROPER PLACE IN XTBL,
		                                ;   SO IT LOOKS LIKE:
		                                ;   JMP <USER-DEFINED ADDRESS>
	        POP     B               ; RESTORE B & C
	        POP     H               ; RESTORE H & L
	        RET
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; 'UI' - EXTERNALLY REFERENCED ROUTINE                                          ;
		; PROCESS: INPUT A CHARACTER FROM THE UPP                                       ;
		; INPUT: B CONTAINS MSB OF PROM ADDRESS                                         ;
		;        C CONTAINS LSB OF PROM ADDRESS                                         ;
		; OUTPUT: DATA IN A-REG                                                         ;
		; MODIFIED:A,FLAGS                                                              ;
		; STACK USAGE: 6 BYTES                                                          ;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		UI:
		                                ; IT IS ASSUMED THE 'UPPS' ROUTINE HAS BEEN
		                                ; CALLED AND THAT THE UPP UNIT IS READY
	        PUSH    B               ; SAVE B,C
        MVI     B,RPPC          ; LOAD THE READ PROM COMMAND
		                                ; C CONTAINS PROM LOW ADDRESS
        CALL    PIODR3          ; OUTPUT READ PROM COMMAND
		                                ; OUTPUT PROM LOW ADDRESS
	        POP     B               ; RESTORE B,C; B CONTAINS PROM HIGH ADDRESS
	        PUSH    B               ; SAVE B,C
	        MOV     C,B             ; C CONTAINS PROM HIGH ADDRESS
        CALL    PIODR4          ; OUTPUT PROM HIGH ADDRESS
	        POP     B               ; RESTORE B,C
        CALL    PIODR2          ; INPUT PROM DATA
	        RET
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; 'UO' - EXTERNALLY REFERENCED ROUTINE                                          ;
		; PROCESS: OUTPUT A CHARACTER TO THE UPP                                        ;
		; INPUT: C CONTAINS THE CHARACTER TO BE WRITTEN INTO THE PROM                   ;
		;        D CONTAINS THE MSB OF THE PROM ADDRESS                                 ;
		;        E CONTAINS THE LSB OF THE PROM ADDRESS                                 ;
		; OUTPUT:                                                                       ;
		; MODIFIED:A,FLAGS                                                              ;
		; STACK USAGE: 8 BYTES                                                          ;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		UO:
		                                ; IT IS ASSUMED THE 'UPPS' ROUTINE HAS BEEN
		                                ; CALLED AND THAT THE UPP UNIT IS READY
	        PUSH    B               ; SAVE B,C
        MVI     B,WPPC          ; LOAD WRITE PROM COMMAND
	        MOV     C,E             ; LOAD PROM LOW ADDRESS
        CALL    PIODR3          ; OUTPUT WRITE PROM COMMAND
		                                ; OUTPUT PROM LOW ADDRESS
	        MOV     C,D             ; LOAD PROM HIGH ADDRESS
        CALL    PIODR4          ; OUTPUT PROM HIGH ADDRESS
	        POP     B               ; RESTORE B,C; C CONTAINS THE DATA TO BE
		                                ;   WRITTEN TO THE PROM
        CALL    PIODR4          ; OUTPUT DATA TO PROM
	        RET
		        
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; 'UPPS' - EXTERNALLY REFERENCED ROUTINE                                        ;
		; PROCESS: INPUT THE UPP STATUS BYTE                                            ;
		; INPUT:                                                                        ;
		; OUTPUT: A-REG CONTAINS THE UPP STATUS BYTE                                    ;
		; MODIFIED:                                                                     ;
		; STACK USAGE: 8 BYTES                                                          ;
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		UPPS:
	        PUSH    B               ; SAVE BC
        MVI     B,RPSTC         ; B CONTAINS STATUS COMMAND
        CALL    PIODR1          ; GET UPP STATUS BYTE
	        PUSH    PSW             ; SAVE IT ON THE STACK
        CALL    PIODR2          ; GET PIO DEVICE STATUS BYTE AND IGNORE IT
	        POP     PSW             ; A NOW CONTAINS UPP STATUS BYTE
	        POP     B               ; RESTORE. BC
	        RET
		;********************************************************************************
		;*                                                                              *
		;* END OF I/O SUBROUTINES, BEGINNING OF MONITOR SUBROUTINES                     *
		;*                                                                              *
		;********************************************************************************
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		; 'BYTE' - ENTERED VIA CALL FROM 'R' COMMAND
		; PROCESS: READ TWO 8-BIT ASCII CHARACTERS, DECODE INTO ONE 8-BIT BINARY WORD
		; INPUT: D CONTAINS RUNNING CHECKSUM
		; OUTPUT: DECODED BYTE IN A-REG, RUNNING CHECKSUM IN D-REG, ZERO BIT SET OR RESET
		; MODIFIED: A,F,C,D
		; STACK USAGE:
		BYTE:
	        PUSH    B               ; SAVE B,C
        CALL    RIX             ; READ ONE ASCII CHAR FROM TAPE, PUT IN A-REG
        CALL    NIBBLE          ; CONVERT 8-BIT ASCII TO 4-BIT HEXADECIMAL VALUE
	        RLC                     ; SHIFT FOUR PLACES TO THE LEFT
	        RLC 
	        RLC
	        RLC                     ; MOVE HEX CHAR TO 4 MSB OF A-REG
	        MOV     C,A             ; STORE TEMPORARILY IN C
        CALL    RIX             ; GET ANOTHER ASCII CHAR FROM READER
        CALL    NIBBLE          ; CONVERT TO 4 BIT HEX; NOW LSBOF A-REG
	        ORA     C               ; ASSEMBLE IT ALL TOGETHER
	        MOV     C,A             ; STORE IT TEMPORARILY IN C
	        ADD     D               ; UPDATE CHECKSUM (ZERO BIT IS SET/RESET)
	        MOV     D,A             ; D CONTAINS UPDATED CHECKSUM
	        MOV     A,C             ; LOAD THE CONVERTED WORD
	        POP B   
	        RET                     ; RETURN
		;////////////////////////////////////////////////////////////////////////////
		; 'CONV' - ENTERED VIA CALLS FROM 'DBYTE','HXD','PBYTE' ROUTINES
		; PROCESS: CONVERT 4 BIT HEX VALUE TO ASCII CHARACTER
		; INPUT: 0,1,2,3,4,5,6,7,8,9,A,B,C,D,E, OR F IN HEX IN A-REG
		; OUTPUT: 30H, ��� ,39H,41H, ��� ,46H IN C-REG
		; MODIFIED: A, FLAGS, C
		; STACK USAGE:
		;
		CONV:
        ANI     0FH             ; ONLY 4 LSB ARE SIGNIFICANT, SO MASK 4 MSB
        ADI     90H             ; SET UP A-REG SO THAT A-F CAUSE CARRY
	        DAA
        ACI     40H             ; ADD IN CARRY AND ADJUST UPPER NIBBLE
	        DAA
	        MOV     C,A             ; STORE CONVERTED RESOLT IN C-REG
	        RET                     ; RETURN
		;////////////////////////////////////////////////////////////////////////////
		; 'CRLF' - ENTERED VIA CALLS FROM 'G','H','Q','R','W','X' COMMANDS AND
		;          'START' ROUTINE
		; PROCESS: TYPE CARRIAGE RETURN AND LINE FEED ON LOCAL CONSOLE
		; INPUT:
		; OUTPUT:
		; MODIFIED:
		; STACK USAGE:
		CRLF:
        CALL    COMC            ; OUTPUT <CR> ON CONSOLE
	        DB      CR
        CALL    COMC            ; OUTPUT <LF> ON CONSOLE
	        DB      LF
	        RET
		;////////////////////////////////////////////////////////////////////////////
		; 'DADR' - ENTERED VIA CALL FROM 'D' COMMAND
		; PROCESS: PRINT CONTENTS OF HL IN HEX FORMAT ON LIST DEVICE
		; INPUT: HL CONTAINS <LOW ADDRESS) OF 'D' COMMAND
		; OUTPUT:
		; MODIFIED: A
		; STACK USAGE:
		DADR:
	        MOV     A,H             ; PRINT MSB OF LOW ADDRESS
        CALL    DBYTE
	        MOV     A,L             ; PRINT LSB OF LOW ADDRESS
		;*******JMP     DBYTE
		;////////////////////////////////////////////////////////////////////////////
		; 'DBYTE' - ENTERED VIA CALLS FROM 'D' COMMAND AND 'DADR' ROUTINE
		;           ENTERED VIA FALL-THRU FROM 'DADR' ROUTINE
		; PROCESS: LIST A BYTE ON THE LIST DEVICE AS TWO ASCII CHARACTERS
		; INPUT: A CONTAINS THE BYTE TO BE LISTED
		; OUTPUT:
		; MODIFIED:
		; STACK USAGE:
		DBYTE:
	        PUSH    PSW             ; SAVE A COPY OF A-REG
	        RRC
	        RRC
	        RRC
	        RRC                     ; WANT TO LOOK ONLY AT BITS 4-7 OF A-REG
        CALL    CONV            ; CONVERT 4 MSB OF ORIGINAL A-REG TO 1 ASCII CHAR
        CALL    LOM             ; OUTPUT ON LIST DEVICE
	        POP     PSW             ; RETRIEVE ORIGINAL VALUE
        CALL    CONV            ; CONVERT 4 LSB OF ORIGINAL A-REG TO 1 ASCII CHAR
        JMP     LOM             ; OUTPUT ON LIST DEVICE
		;///////////////////////////////////////////////////////////////////////////////
		; 'DELAY' - ENTERED VIA CALL FROM 'RI' ROUTINE
		; PROCESS: 1.0 MS. DELAY
		; INPUT: ONEMS
		; OUTPUT: ROUTINE IDLES FOR 1.0 MS.
		; MODIFIED: C, FLAGS
		; STACK USAGE: 2 BYTES
		DELAY:
        MVI     C,ONEMS         ; LOAD 1 MS.CONSTANT (USE 3BH IN ICE ENVIRONMENT)
		DLY1:
	        DCR     C               ; DECREMENT COUNTER
        JNZ     DLY1            ; JUMP IF NOT EXPIRED
	        RET                     ; RETURN
		;////////////////////////////////////////////////////////////////////////////
		; 'DREG' - ENTERED VIA CALL FROM 'X' COMMAND
		; PROCESS: DISPLAY THE CONTENTS OF A USER REGISTER
		; INPUT: HL POINtS TO CHARACTER IN ACTBL OF 'X' COMMAND
		; OUTPUT: HL POINTS TO NEXT CHARACTER IN ACTBL,
		;         DE CONTAINS ADDRESS OF REGISTER LOCATION
		;         B CONTAINS REGISTER PRECISION
		; MODIFIED:
		; STACK USAGE:
		DREG:
	        INX     H               ; HL POINTS TO LOCATION ENTRY IN ACTBL OF 'X' COMMAND
	        MOV     E,M             ; INCREMENT HL TO POINT AT DISPLACEMENT
        LDA     MEMTOP+1
	        MOV     D,A             ; D := MSB OF ADDRESS OF TOP PAGE OF MEMORY
		                                ; DE POINTS TO THAT PART OF THE EXIT TEMPLATE
		                                ;   CONTAINING SAVED REGISTER VALUES
	        INX     H               ; HL POINTS TO PRECISION IN ACTBL
	        MOV     B,M             ; PRECISION, 0=8 BITS, 1=16 BITS
	        INX     H               ; POINT AT NEXT REGISTER IDENTIFIER
	        LDAX    D               ; 8/16 BIT DISPLAY AND MODIFICATION
        CALL    LBYTE           ; MSB OF 16 BIT REG, ALL OF 8 BIT REG
	        DCR     B               ; TEST PRECISION
	        RM                      ; 8 BIT DISPLAY, RETURN
	        DCX     D
	        LDAX    D
        JMP     LBYTE           ; LSB OF 16 BIT REG
		;///////////////////////////////////////////////////////////////////////////////
		; 'EXPR' - ENTERED VIA CALLS FROM 'D','E','F','H','M','R','W' COMMANDS
		; PROCESS: EVALUATE EXPRESSION "<EXPR>,<EXPR>,<EXPR>"
		; INPUT: C-REG CONTAINS THE NUMBER OF PARAMETERS REQUIRED (1,2, OR 3)
		; OUTPUT: STACK CONTAINS THE PARAMETERS IN REVERSE ORDER
		; MODIFIED: F,C,H,L,SP
		; STACK USAGE:
		EXPR:
        CALL    PARAM           ; GET A HEXADECIMAL PARAMETER, RETURNED IN HL
	        XTHL                    ; PUT THE PARAMETER IN THE STACK; HL NOW
		                                ;   CONTAINS RETURN ADDRESS OF CALL TO 'EXPR'
	        PUSH    H               ; PUT RETURN ADDRESS ON TOP OF STACK
	        DCR     C               ; DECREMENT PARAMETER COUNT; CARRY BIT UNAFFECTED
        JNC     EX0             ; JUMP IF COMMA ENTERED (PARAM CALLS PCHK)
        JNZ     ERROR           ; INCORRECT PARAM COUNT
	        RET
		EX0:
        JNZ     EXPR            ; GET ANOTHER PARAMETER
        JMP     ERROR           ; NOT TERMINATED WITH CR
		;///////////////////////////////////////////////////////////////////////////////
		; 'HILO' - ENTERED VIA CALLS FROM 'D','F','M','W' COMMANDS
		; PROCESS: COMPARE HL WITH DE
		; INPUT: ADDRESS VALUES IN HL AND DE
		; OUTPUT: IF HL (= DE THE~ CARRY 121;
		;         IF HL > DE THEN CARRY = 1
		; MODIFIED: HL,A,F
		; STACK USAGE:
		HILO:
	        INX     H               ; INCREMENT HL ADDRESS
	        MOV     A,H             ; TEST FOR HL = 0
	        ORA     L               ; ZERO BIT SET IF H=L=00, I.E. HL MUST
		                                ;   HAVE BEEN FFFFH
	        STC                     ; CARRY := 1
	        RZ
	        MOV     A,E             ; DE - HL, SET/RESET CARRY
	        SUB     L               ; (LSB OF HIGH ADDR) - (MSB OF LOW ADDR)
	        MOV     A,D
	        SBB     H               ; (MSB OF HIGH ADDR) - (MSB OF LOW.ADDR)
	        RET                     ; RETURN
		;////////////////////////////////////////////////////////////////////////////
		; 'LADR' - ENTERED VIA CALLS FROM 'H' COMMAND AND 'RESTART' ROUTINE
		; PROCESS: PRINT CONTENTS OF HL IN HEX ON LOCAL CONSOLE DEVICE
		; INPUT: HL CONTAINS THE HEX VALUE TO BE OUTPUT(16 BITS)
		; OUTPUT:
		; MODIFIED: H,L,A
		; STACK USAGE:
		LADR:
	        MOV     A,H
        CALL    LBYTE           ; PRINT 8 MSB OF HEX VALUE ON CONSOLE
	        MOV     A,L
		;*******JMP     LBYTE           ; PRINT 8 LSB OF HEX VALUE ON CONSOLE
		;////////////////////////////////////////////////1///////////////////////////
		; 'LBYTE' - ENTERED VIA CALLS FROM'S' COMMAND AND 'DREG','LADR' ROUTINES
		;           ENTERED VIA JUMP FROM 'DREG' ROUTINE
		;           ENTERED VIA FALL-THRU FROM 'LADR' ROUTINE
		; PROCESS: LIST A BYTE AS TWO ASCII CHARACTERS
		; INPUT: A-REG CONTAINS THE 8 BITS TO BE CONVERTED TO ASCII
		; OUTPUT:
		; MODIFIED: A,F
		; STACK USAGE: 6 BYTES
		LBYTE:
	        PUSH    PSW             ; SAVE A-REG
	        RRC
	        RRC
	        RRC
	        RRC                     ; LOOK ONLY AT 4 MSB OF THE BYTE VALUE
        CALL    HXD             ; CONVERT IT TO ONE ASCII CHAR AND OUTPUT IT
	        POP     PSW             ; RETRIEVE ORIGINAL VALUE
		;*******JMP      HXD             ; CONVERT 4 LSB OF BYTE TO ASCII AND OUTPUT IT
		;////////////////////////////////////////////////1///////////////////////////
		; 'HXD' - ENTERED VIA CALL FROM 'LBYTE' ROUTINE
		;         ENTERED VIA FALL-THRU FROM 'LBYTE' ROUTINE
		; PROCESS: CONVERT 4 LSB IN A-REG INTO ONE ASCII CHAR IN A-REG, PRINT IT
		;          ON LOCAL CONSOLE DEVICE
		; INPUT: NIBBLE TO BE CONVERTED IS IN BITS 0-3 OF A-REG
		; OUTPUT:
		; MODIFIED: A-REG
		; STACK USAGE:
		HXD:
        CALL    CONV            ; CONVERT 4 BITS TO ONE 8-BIT ASCII CHAR
        JMP     COM             ; OUTPUT ON LOCAL CONSOLE
		;/////////////////////////////////////////////////////////////////////////////
		; 'LCRLF' - ENTERED VIA CALL FROM 'D' COMMAND
		; PROCESS: PRINT <CR>,<LF> ON LIST DEVICE
		; INPUT:
		; OUTPUT:
		; MODIFIED: C
		; STACK USAGE: 4 BYTES
		LCRLF:
        MVI     C,CR
        CALL    LOM             ; OUTPUT <CR> TO LIST DEVICE
        MVI     C,LF
        JMP     LOM             ; OUTPUT <LF) TO LIST DEVICE
		;///////////////////////////////////////////////////////////////////////////////
		; 'PARAM' - ENTERED VIA CALLS FROM 'G','S' COMMANDS AND 'EXPR' ROUTINE
		; 'PA0' - ENTERED VIA CALLS FROM 'G','S','X' COMMANDS
		; PROCESS: COLLECT A HEXADECIMAL PARAMETER
		; INPUT:
		; OUTPUT: HEXADECIMAL PARAMETER IN HL
		; MODIFIED: A,F,B,H,L
		; STACK USAGE:
		PARAM:
        CALL    PCHK            ; GET FIRST CHARACTER
        JZ      ERROR           ; DISALLOW NULL PARAMETERS
		PA0:
        LXI     H,0             ; INTIALIZE HL := 0000
		PA1:
	        MOV     B,A             ; SAVE CHAR IN CASE IT'S A DELIMITER
        CALL    NIBBLE          ; CONVERT THE ASCII CHARACTER TO HEXi MUST BE
		                                ;   0-9,A-Fi IF NOT THE CARRY BIT IS SET
        JC      PA2             ; NOT LEGAL CHAR, TREAT AS DELIMITER
	        DAD     H               ; *2
	        DAD     H               ; *4
	        DAD     H               ; *8
	        DAD     H               ; *16 --- SHIFT THE OLD HEX VALUES 4 PLACES TO LEFT
	        ORA     L               ; PUT NEW HEX VALUE IN 4 LSB OF L-REG
	        MOV     L,A
        CALL    TI              ; GET SUBSEQUENT CHARACTERS
        JMP     PA1             ;  DECODE NEXT CHARACTER
		PA2:
	        MOV     A,B             ; A := B := DELIMITER CHARACTER
        CALL    P2C             ; IS IT A VALID DELIMITER?
        JNZ     ERROR           ; JUMP TO ERROR IF IT ISN'T
	        RET
		;////////////////////////////////////////////////////////////////////
		; 'NIBBLE' - ENTERED VIA CALLS FROM 'BYTE','PARAM','PA0' ROUTINES
		; PROCESS: DECODE 8-BIT ASCII CHAR IN A-REG INTO 4-BIT HEX DIGIT IN A-REG,
		;          FILTER OUT ALL CHARACTERS NOT IN THE ASCII CODING SEQUENCE
		;          0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F.
		; INPUT: 8-BIT ASCII CHAR IN A-REG
		; OUTPUT: VALID HEX EQUIVALENT IN A-REG AND CARRY = 0, OTHERWISE
		; GARBAGE IN A-REG AND CARRY = 1 (INDICATING ILLEGAL CHARACTER)
		; MODIFIED: A, FLAGS
		; STACK USAGE: 2 BYTES
		NIBBLE:
        SUI     '0'             ; IF THE ASCII CHAR IS BETWEEN 00 AND 2FH,
	        RC                      ;   THEN RETURN WITH CARRY = 1
        ADI     '0' - 'G'       ; IF THE ASCII CHAR IS GREATER THAN 46H,
	        RC                      ;   THEN RETURN WITH CARRY = 1
        ADI     6               ; ORIGINAL ASCII CHAR WAS BETWEEN 30H AND 46H INCL.
        JP      NI0             ; JUMP IF IT WAS 41H THRU 46H (I.E. A-F)
        ADI     7               ; ORIGINAL ASCII CHAR WAS BETWEEN 30H AND 40H INCL
	        RC                      ; RETURN WITH CARRY = 1 IF ASCII CHAR WAS
		                                ;   BETWEEN 3AH AND 40H INCLUSIVE
		NI0:                            ; VALID VALUE: 30H-39H,41H-46H
        ADI     10              ; A-REG NOW CONTAINS HEX EQUIV. (0-9,A-F)
	        ORA     A               ; CLEAR ERROR FLAG (I.E. RESET CARRY BIT)
	        RET                     ; RETURN WITH VALID VALUE
		;//////////////////////////////////////////////////////////////////////
		; 'PADR' - ENTERED VIA CALLS FROM 'E','W' COMMANDS
		; PROCESS: PUNCH CONTENTS OF HL IN HEX ON PUNCH DEVICE
		; INPUT: HL CONTAINS 8-BIT LOAD ADDRESS
		; OUTPUT:
		; MODIFIED: A
		; STACK USAGE: 4 BYTES
		PADR:
	        MOV     A,H             ; A := MSB OF LOAD ADDRESS
        CALL    PBYTE           ; EMIT FRAMES 3 & 4
	        MOV     A,L             ; A := LSB OF LOAD ADDRESS
		;*******JMP     PBYTE           ; EMIT FRAMES 5 & 6
		;////////////////////////////////////////////////////1///////////////////
		; 'PBYTE' - ENTERED VIA CALLS FROM 'E','W' COMMANDS AND 'PADR' ROUTINE
		;           ENTERED VIA FALL-THRU FROM 'PADR' ROUTINE
		; PROCESS: PUNCH A BYTE AS 2 ASCII CHARACTERS
		; INPUT: A-REG CONTAINS BYTE TO BE CONVERTED, D CONTAINS RUNNING CHECKSUM
		; OUTPUT: D CONTAINS UPDATED CHECKSUM
		; MODIFIED: A,F,D,E
		; STACK USAGE:
		PBYTE:
	        MOV     E,A             ; SAVE BYTE TO BE CONVERTED IN E-REG
	        RRC
	        RRC
	        RRC
	        RRC                     ; LOOK ONLY AT 4 MSB OF THE BYTE
        CALL    CONV            ; CONVERT IT TO 1 ASCII CHARACTER
        CALL    PO              ; PUNCH IT
	        MOV     A,E             ; NOW LOOK ONLY AT 4 LSB OF BYTE
        CALL    CONV            ; CONVERT IT TO ONE ASCII CHAR
        CALL    PO              ; PUNCH IT
	        MOV     A,E
	        ADD     D               ; UPDATE THE RUNNING CHECKSUM
	        MOV     D,A             ; STORE IT BACK IN THE D-REG
	        RET                     ; RETURN
		;///////////////////////////////////////////////////////////////////////////////
		; 'PCHK' - ENTERED VIA CALLS FROM 'G','S','X' COMMANDS AND 'PARAM' ROUTINE
		; 'P2C' - ENTERED VIA CALLS FROM 'PARAM','PA0' ROUTINES
		; PROCESS: TEST FOR NULL INPUT PARAMETER (LOOK FOR SPACE,COMMA,OR (CR�
		; INPUT:
		; OUTPUT: CHARACTER IN A-REG
		;         IF SPACE OR COMMA, THEN ZERO = 1 & CARRY = 0
		;         IF <CR>,           THEN ZERO = 1 & CARRY = 1
		;         IF NONE OF ABOVE,  THEN ZERO = 0 & CARRY = 0
		; MODIFIED: A, FLAGS
		; STACK USAGE: 4 BYTES
		PCHK:
        CALL    TI              ; GET A CHARACTER
		P2C:
        CPI     ' '
	        RZ                      ; IF SPACE, THEN ZERO = 1 & CARRY = 0
        CPI     ','
	        RZ                      ; IF COMMA, THEN ZERO = 1 & CARRY = 0
        CPI     CR
	        STC
	        RZ                      ; IF <CR>, THEN ZERO = 1 & CARRY = 1
	        CMC
	        RET                     ; IF NONE OF THE THREE, THEN ZERO=CARRY=0
		;///////////////////////////////////////////////////////////////////////////////
		;/ 'RESTART' - ENTERED VIA JUMP FROM LOCATION 0                                 /
		;/ PROCESS: BREAKPOINT/INTERRUPT/RESTART PROCESSING                             /
		;/ INPUT:                                                                       /
		;/ OUTPUT:                                                                      /
		;/ MODIFIED:                                                                    /
		;/ EXPLANATION:                                                                 /
		;/ THIS ROUTINE IS ENTERED VIA A RESTART 0 (RST 0) INSTRUCTION. THE             /
		;/ INSTRUCTION IS ENCOUNTERED EITHER IN THE USER PROGRAM (AS A BREAKPOINT)      /
		;/ OR IS INPUT VIA A LOCAL CONSOLE INTERRUPT (I.E. USER HAS ACTIVATED THE       /
		;/ INTERRUPT 0 SWITCH). THIS ROUTINE SAVES THE STATE OF THE CALLING             /
		;/ PROCESS AND TURNS CONTROL OVER TO THE MONITOR. THIS IS DONE IN THE           /
		;/ FOLLOWING MANNER:                                                            /
		;/    1. THE USER ENVIRONMENT IS SAVED BY PUSHING THE REGISTERS ON TOP          /
		;/       OF THE USER'S OWN WORK STACK.                                          /
		;/    2. PROGRAM THE 8259 WITH THE MONITOR'S OWN INTERRUPT MASK REGISTER.       /
		;/    3. THE MONITOR'S EXIT TEMPLATE IS FOUND AND THE REGISTER VALUES           /
		;/       REPRESENTING THE USER'S STATE ARE POPPED OFF THE USER WORK STACK       /
		;/       AND STORED IN THE APPROPRIATE PLACES IN THE EXIT TEMPLATE.             /
		;/    4. TEST TO SEE IF THE POINT AT WHICH USER PROGRAM INTERRUPTION            /
		;/       OCCURRED (VALUE OF PROGRAM COUNTER) COINCIDES WITH A BREAKPOINT        /
		;/       ADDRESS.                                                               /
		;/       A. IF IT DOESN'T, THEN RESTART CODE WAS ENTERED VIA A CONSOLE          /
		;/          INTERRUPT SO SEND EOI TO THE 8259.                                  /
		;/       B. IF IT DOES, THEN PROGRAM THE EXIT CODE TO 1) LOAD THE CORRECT       /
		;/          HAND L VALUES AND TO 2) JUMP TO THE ADDRESS INDICATED BY THE PC     /
		;/          (PUSHED ON STACK AT TIME OF RST 13 INSTRUCTION OR WHEN CONSOLE      /
		;/          INTERRUPT). ALSO, RESTORE THE TRAP VALUES AT THE PROPER             /
		;/          TRAP ADDRESSES.                                                     /
		;/    5. RETURN CONTROL TO THE MONITOR (BY JUMPING TO START).                   /
		;/                                                                              /
		;///////////////////////////////////////////////////////////////////////////////
		RESTART:
	        DI                      ; DISABLE IF SOFTWARE TRAP
		                                ; SAVE USER'S ENVIRONMENT
	        PUSH    H               ; SAVE H,L
	        PUSH    D               ; SAVE D,E
	        PUSH    B               ; SAVE B,C
	        PUSH    PSW             ; SAVE A,FLAGS
	        POP     D               ; TEMPORARILY SAVE PSW IN D & E
	        PUSH    H               ; DUMMY PUSH TO RESERVE SPACE IN STACK FOR
		                                ;   CURRENT INTERRUPT MASK AND CONFIGURATION
		                                ;   BYTE
        LHLD    MEMTOP
        MVI     L,(ILOC-1) & 0FFH; HL NOW POINTS TO CONFIGURATION BYTE IN
		                                ;   EXIT CODE IN TOP PAGE OF RAM
	        MOV     L,M             ; L NOW CONTAINS THIS CONFIGURATION BYTE
        IN      SOCP1           ; INPUT CURRENT INTERRUPT MASK REGISTER --
		                                ;   THIS MASK IS THE USER'S, SO SAVE IT
	        MOV     H,A             ; H NOW CONTAINS THIS INTERRUPT MASK
	        XTHL                    ; THE INTERRUPT MASK AND CONFIGURATION BYTE
		                                ;   ARE NOW ON TOP OF THE USER STACK
	        PUSH    D               ; NOW PUT THE ORIGINAL PSW ON TOP OF THE STACK
        MVI     A,~ INT0      ; SET MONITOR'S DEFAULT INTERRUPT MASK
        OUT     SOCP1           ; OUTPUT NEW MASK
        LHLD    MEMTOP
        MVI     L,EXIT & 0FFH ; HL NOW POINTS TO EXIT CODE AT TOP OF RAM
	        XCHG                    ; SO NOW DE POINTS TO EXIT CODE AT TOP OF RAM
        LXI     H,12            ; H := 00, L := 0C (DECIMAL VALUE 12)
	        DAD     SP              ; EFFECT OF THIS IS TO CUT BACK THE USER'S
		                                ;   STACK TO WHAT IT WAS BEFORE ENTERING
		                                ;   THIS RESTART ROUTINE AND BEFORE THE PC
		                                ;   WAS PUSHED ON BY RST 0 OR INTERRUPT.
		                                ;   HL CONTAINS THIS 'OLD' STACK ADDRESS.
        MVI     B,5             ; COUNT FOR TRANSFER OF MACHINE STATE
		                                ;   TO EXIT TEMPLATE STORAGE (MOVE THE STACK) 
	        XCHG                    ; HL NOW POINTS TO EXIT CODE AT TOP OF RAM
		                                ; DE NOW POINTS TO USER STACK AS IT WAS
		                                ;   PRIOR TO RST 0 OR CONSOLE INTERRUPT.
		;       ---------------------------------------------------------------------
		RST0:                           ; MOVE THE MACHINE STATE FROM THE USER'S STACK 
		                                ; TO THE RESERVED AREA IN THE EXIT TEMPLATE
		                                ; IN TOP PAGE OF RAM.
		                                ;    B=5     !   B=4  !   B=3  !  B=2 ! B=1
		                                ;------------!--------!--------!------!------
	        DCX     H               ;            !        !        !      !
	        MOV     M,D             ;BLOC=MSB(SP)!ALOC=A  !ILOC=INT!BLOC=B!DLOC=D
	        DCX     H               ;            !        !        !      !
	        MOV     M,E             ;    =LSB(SP)!FLOC=FLG!    =FLG!CLOC=C!ELOC=E
	        POP     D               ;DE=AF       !DE=INT,F!DE=BC   !DE=DE !DE=HL
	        DCR     B               ;B=4         !B=3     !B=2     !B=1   !B=0
        JNZ     RST0
		;       ---------------------------------------------------------------------
		                                ; AT THIS POINT, HL POINTS TO THE BASE OF
		                                ; THE MONITOR STACK (TOS) IN TOP PAGE OF
		                                ; RAM. DE CONTAINS THE H & L VALUES THE
		                                ; USER HAD PRIOR TO ENTERING THE RESTART
		                                ; ROUTINE.
	        POP     B               ; BC = OLD PC (PUSHED ON USER STACK BY
		                                ;   RST 0 OR INTERRUPT)
	        DCX     B               ; DECREMENT TO POINT AT TRAPPED CODE
	        SPHL                    ; SP NOW POINTS TO TOS (BASE OF MONITOR STACK)
        LHLD    MEMTOP
        MVI     L,TLOC & 0FFH ; HL NOW POINTS TO TLOC IN TOP PAGE OF RAM
		                                ;   I.E. LSB OF TRAP 1 ADDRESS
	        MOV     A,M             ; TEST IF THIS IS A PROGRAMMED RESTART OR A
	        SUB     C               ;   LOCAL CONSOLE INTERRUPT BY COMPARING THE
		                                ;   PC VALUE WITH TRAP 1 ADDRESS
		                                ;   A := LSB OF TRAP 1 ADDRESS
	        INX     H               ; HL POINTS TO MSB OF TRAP 1 ADDRESS
        JNZ     RSTA            ; PC DID NOT MATCH TRAP 1 ADDRESS
	        MOV     A,M             ; A := MSB OF TRAP 1 ADDRESS
	        SBB     B
        JZ      RST1            ; PC MATCHES TRAP 1 --- A PROGRAMMED RESTART
		RSTA:                           ; REPEAT SAME STEPS AS ABOVE BUT SEE IF PC
		                                ;   MATCHES 2ND BREAKPOINT (TRAP 2 ADDRESS)
	        INX     H               ; HL POINTS TO TRAP 1 OPCODE VALUE
	        INX     H               ; HL POINTS TO LSB OF TRAP 2 ADDRESS
	        MOV     A,M             ; A := LSB OF TRAP 2 ADDRESS
	        SUB     C
	        INX     H               ; HL POINTS TO MSB OF TRAP 2 ADDRESS
        JNZ     RSTB            ; PC DID NOT MATCH TRAP 2 ADDRESS
	        MOV     A,M             ; A := MSB OF TRAP 2 ADDRESS
	        SBB     B
        JZ      RST1            ; PC MATCHES TRAP 2 --- A PROGRAMMED RESTART
		RSTB:                           ; NOT A PROGRAMMED RESTART, BUT A
        MVI     A,EOI           ;   CONSOLE INTERRUPT SO SEND EOI TO 8259
        OUT     SOCP0
	        INX     B               ; ADJUST PC FOR LOCAL CONSOLE RESTART
		                                ;   I.E. GET READY TO POINT PC TO
		                                ;   RESUMPTION POINT IN CODE IT WAS
		                                ;   EXECUTING WHEN INTERRUPTED
		                                ;   BC POINTS TO NEXT INSTR TO BE EXECUTED
		                                ;   WHEN CONTROL IS RETURNED TO USER PROGRAM
		RST1:                           ; PROGRAMMED RESTART AT A BREAKPOINT (TRAP)
		                                ;   ALSO FALLTHROUGH FROM CONSOLE INTERRUPT
        LHLD    MEMTOP
        MVI     L,LLOC & 0FFH ; HL NOW POINTS TO LLOC IN EXIT CODE IN TOP OF RAM
	        MOV     M,E             ; USER'S L VALUE PRIOR TO RESTART IS STORED IN LLOC
	        INX     H
	        MOV     M,D             ; USER'S H VALUE PRIOR TO RESTART IS STORED IN HLOC
		;       ---------------------------------------------------------------------
        MVI     L,(PLOC-1) & 0FFH; HL POINTS TO LSB OF JMP INSTR IN EXIT CODE
	        MOV     M,C             ; SAVE LSB OF USER'S PC
	        INX     H
	        MOV     M,B             ; SAVE MSB OF USER'S PC. EFFECT IS TO LOAD THE
		                                ; PROPER ADDRESS INTO THE EXIT TEMPLATE FOR THE
		                                ; JUMP BACK TO THE USER'S PROGRAM.
		;       ---------------------------------------------------------------------
	        PUSH    B
        CALL    COMC
	        DB      '#'
	        POP     H               ; RETRIEVE OLD PC FOR DISPLAY
        CALL    LADR            ; DISPLAY PC
		;       ---------------------------------------------------------------------
		                                ; CLEAR TRAPS
        LHLD    MEMTOP
        MVI     L,TLOC & 0FFH ; HL NOW POINTS TO TLOC IN TOP PAGE OF RAM
        MVI     D,2             ; SET COUNT FOR TWO TRAPS
		RST2:
	        MOV     C,M             ; C := LSB OF TRAP ADDRESS
	        XRA     A
	        MOV     M,A             ; ZERO OUT LSB OF TRAP ADDRESS
	        INX     H
	        MOV     B,M             ; B := MSB OF TRAP ADDRESS
	        MOV     M,A             ; ZERO OUT MSB OF TRAP ADDRESS
	        INX     H               ; HL NOW POINTS TO TRAP VALUE
	        MOV     A,C             ; BC CONTAINS THE TRAP ADDRESS
	        ORA     B               ; TEST FOR VALID TRAP
        JZ      RST3            ; TRAP ADDRESS IS 0, SO NO TRAP TO RESTORE
	        MOV     A,M             ; GET OPCODE BYTE, I.E. TRAP VALUE
	        STAX    B               ; PUT IT BACK IN CORRECT PLACE IN USER PROGRAM,
		                                ;   I.E. REPLACE THE RST 0 INSTR WITH ORIGINAL
		                                ;   OPCODE.
		RST3:
	        INX     H               ; POINT TO TRAP 2 ADDRESS IF D=2
	        DCR     D
        JNZ     RST2            ; REPEAT FOR TRAP 2
        JMP     START           ; ENTER MONITOR (INTERRUPTS STILL DISABLED)
		;///////////////////////////////////////////////////////////////////////////////
		; 'RIX' - ENTERED VIA CALLS FROM 'R' COMMAND AND 'BYTE' ROUTINE
		; PROCESS: GET A CHARACTER FROM READER, MASK OFF P~RITY BIT
		; INPUT:
		; OUTPUT: CHARACTER IN A-REG, BIT 7 IS 0
		; MODIFIED: A,F
		; STACK USAGE:
		RIX:
        CALL    RI              ; GET CHARACTER FROM READER DEVICE
        JC      ERROR           ; READER TIMEOUT ERROR
        ANI     7FH             ; MASK OUT THE PARITY BIT
	        RET                     ; RETURN
		;/////////////////////////////////////I/////////////////////////////////////////
		; 'TI' - ENTERED VIA CALLS FROM 'A','N','Q' COMMANDS AND 'START','PARAM'
		;        'PA0','PCHK' ROUTINES
		;        ENTERED VIA JUMP FROM 'BREAK'
		; PROCESS: INPUT FROM LOCAL CONSOLE, ECHO, RETURN IN A-REG
		; INPUT:
		; OUTPUT: CHARACTER IN A-REG
		; MODIFIED: A,F
		; STACK USAGE:
		TI:
	        PUSH    B               ; SAVE STATE OF B- & C-REGS
        CALL    CI              ; GET A CHARACTER FROM THE CONSOLE
        ANI     7FH             ; MASK OFF PARITY BIT
        CALL    UC              ; CONVERT TO UPPER CASE
        CPI     ETX             ; TEST FOR BREAK
        JZ      ERROR           ; ABORT COMMAND
	        MOV     C,A             ; MOVE INPUT CHARACTER TO C-REG
        CALL    CO              ; ECHO IT
	        MOV     A,C
	        POP     B               ; RESTORE STATE OF B & C
	        RET                     ; RETURN
		;//////////////////////////////////////////////////////////////////////////////
		; 'UC' - ENTERED VIA CALL FROM 'TI' ROUTINE
		; PROCESS: CONVERT CHARACTER IN A-REG FROM LOWER CASE TO UPPER CASE
		; INPUT: LOWER OR UPPER CASE CHAR IN A-REG
		; OUTPUT: UPPER CASE CHARACTER IN A-REG
		; MODIFIED: A,F
		; STACK USAGE:
		UC:
        CPI     'A'+20H
	        RM                      ; CHAR < LC(A) , I.E. IF THE CHAR IN A-REG
		                                ;   IS NOT LOWER CASE, THEN IT HAS VALUE
		                                ;   < 61H, SO A - 61H WILL BE MINUS. IF
		                                ;   IT IS IN LOWER CASE, THE RESULT WILL
		                                ;   BE POSITIVE.
        CPI     'Z'+20H+1
	        RP                      ; CHAR > LC(Z) , I.E. WE KNOW THE A-REG IS
		                                ;   UPPER CASE OR SPECIAL CHAR. IF IT IS A
		                                ;   SPECIAL CHAR, A - 78H WILL BE 0 OR
		                                ;   GREATER SO RETURN.
        ANI     ~ 20H         ; FORCE UPPER CASE
	        RET
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;*                                                                     *
		;*      I/O CONTROLLER INTERFACE DRIVERS                               *
		;*                                                                     *
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		; 'IOCDR1' - ENTERED VIA CALLS FROM 'CI','CSTS' ROUTINES
		; PROCESS: GET DEVICE STATUS OR GET DATA FROM PERIPHERAL
		; INPUT: B CONTAINS THE COMMAND (STATUS REQUEST OR INPUT DATA REQUEST)
		; OUTPUT: A CONTAINS THE REQUESTED INFORMATION
		; MODIFIED: A,FLAGS,B
		; STACK USAGE:
		IOCDR1:
        CALL    IOCCOM          ; OUTPUT 'GET DEVICE STATUS COMMAND' OR
		                                ;   'INPUT DATA COMMAND' TO IOC CONTROL
		                                ;   PORT
		IOCXXX:
        IN      IOCS            ; INPUT DBB STATUS
        ANI     IBF | OBF | F0; MASK OFF STATUS FLAGS
        CPI     OBF             ; TEST FOR SLAVE DONE; SOMETHING FOR THE MASTER
        JNZ     IOCXXX          ; IF NOT, CONTINUE TO LOOP
        IN      IOCI            ; OTHERWISE, INPUT THE DATA FROM THE DBB
	        PUSH    PSW             ; SAVE A-REG
        MVI     A,ENABL         ; ENABLE INTERRUPTS
        OUT     CPUC
	        POP     PSW             ; RESTORE A-REG
	        RET
		;------------------------------------------------------------------------------
		; 'IOCDR2' - ENTERED VIA CALLS FROM 'BLK','COM','CO','CRTOUT' ROUTINES
		; PROCESS: OUTPUT DATA TO THE PERIPHERAL DEVICE
		; INPUT: B CONTAINS THE COMMAND TO OUTPUT THE DATA
		; C CONTAINS THE DATA TO BE OUTPUT
		; OUTPUT:
		; MODIFIED: A,FLAGS,B,C
		; STACK USAGE:
		IOCDR2:
        CALL    IOCCOM          ; OUTPUT 'OUTPUT DATA COMMAND' TO IOC
		                                ;   CONTROL PORT
		IOCYYY:
        IN      IOCS            ; INPUT DBB STATUS
        ANI     IBF | F0 | OBF; TEST FOR SLAVE PROCESSOR READY
        JNZ     IOCYYY          ; CONTINUE TO LOOP UNTIL IT IS READY
	        MOV     A,C             ; LOAD DATA TO BE WRITTEN
        OUT     IOCO            ; OUTPUT DATA TO THE DBB
        MVI     A,ENABL         ; ENABLE INTERRUPTS
        OUT     CPUC
	        RET
		;-------------------------------------------------------------------------
		; 'IOCCOM' - COMMON ROUTINE TO IOC DRIVERS
		;            ENTERED VIA CALLS FROM 'IOCDRl' AND 'IOCDR2'
		; PROCESS: OUTPUT COMMAND TO THE IOC
		; INPUT: B CONTAINS THE COMMAND
		; OUTPUT:
		; MODIFIED: A,FLAGS
		; STACK USAGE:
		IOCCOM:
        MVI     A,DISABL        ; BLOCK ALL INTERRUPTS
        OUT     CPUC
		IOCZZZ:
        IN      IOCS            ; INPUT DBB STATUS
        ANI     F0 | IBF | OBF; TEST FOR SLAVE PROCESSOR IDLE
        JNZ     IOCZZZ          ; LOOP UNTIL IT IS IDLE
	        MOV     A,B             ; LOAD COMMAND
        OUT     IOCC            ; OUTPUT COMMAND TO IOC CONTROL PORT
	        RET
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;*                                                                   *
		;*      PARALLEL I/O INTERFACE DRIVERS                               *
		;*                                                                   *
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		; 'PIODR1' - ENTERED VIA CALLS FROM 'RI','PO','POC','LO','UPPS'
		; 'PIODR2' - ENTERED VIA CALLS FROM 'ur','uPPS' ROUTINES
		; PROCESS: GET DEVICE STATUS OR GET DATA FROM A PERIPHERAL
		; INPUT: B CONTAINS THE COMMAND (STATUS REQUEST OR INPUT DATA REQUEST)
		; OUTPUT: A CONTAINS THE REQUESTED INFORMATION
		; MODIFIED: A, FLAGS, B
		; STACK USAGE:
		PIODR1:
        CALL    PIOCOM          ; OUTPUT 'GET DEVICE STATUS COMMAND' OR
		                                ;   'INPUT DATA COMMAND' OR OTHER SUCH
		                                ;   COMMAND TO THE PIO CONTROL PORT
		PIODR2:
        MVI     A,DISABL        ; BLOCK ALL INTERRUPTS
        OUT     CPUC
        IN      PIOS            ; INPUT DBB STATUS
        ANI     F0 | IBF | OBF; MASK OFF STATUS FLAGS
        CPI     OBF             ; TEST FOR SLAVE DONE; SOMETHING FOR THE MASTER
        JNZ     PIODR2          ; LOOP UNTIL SLAVE IS READY
        IN      PIOI            ; OTHERWISE INPUT THE DATA FROM THE DBB
	        PUSH    PSW             ; SAVE A-REG
        MVI     A,ENABL         ; ENABLE INTERRUPTS
        OUT     CPUC
	        POP     PSW             ; RESTORE A-REG
	        RET
		;-----------------------------------------------------------------------
		; 'PIODR3' - ENTERED VIA CALLS FROM 'POC','PO','LO','UI','UO J ROUTlNES
		; 'PIODR4' - ENTERED VIA CALLS FROM 'UI','UO'
		; PROCESS: OUTPUT DATA TO A PERIPHERAL DEVICE
		; INPUT: B CONTAINS THE COMMAND TO OUTPUT THE DATA
		;        C CONTAINS THE DATA TO BE OUTPUT
		; OUTPUT:
		; MODIFIED: A,FLAGS,B, C
		; STACK USAGE:
		PIODR3:
        CALL    PIOCOM          ; OUTPUT 'OUTPUT DATA COMMAND' TO PIO
		PIODR4:
        MVI     A,DISABL        ; BLOCK ALL INTERRUPTS
        OUT     CPUC
        IN      PIOS            ; INPUT DBB STATUS
        ANI     F0 | IBF | OBF; TEST FOR SLAVE PROCESSOR READY
        JNZ     PIODR4          ; LOOP UNTIL IT IS READY
	        MOV     A,C             ; LOAD DATA TO BE WRITTEN
        OUT     PIOO            ; OUTPUT DATA TO THE DBB
        MVI     A,ENABL         ; ENABLE INTERRUPTS
        OUT     CPUC
	        RET 
		;------------------------------------------------------------------- 
		; 'PIOCOM' - COMMON ROUTINE OF PIO DRIVERS
		;            ENTERED VIA CALLS FROM 'PIODR1', 'PIODR3', 'RI' ROUTINES
		; INPUT: B CONTAINS THE COMMAND
		; OUTPUT:
		; MODIFIED: A,FLAGS
		; STACK USAGE:
		PIOCOM:
        MVI     A,DISABL        ; BLOCK ALL INTERRUPTS
        OUT     CPUC
		PIOZZZ:
        IN      PIOS            ; INPUT DBB STATUS
        ANI     F0 | IBF | OBF; TEST FOR SLAVE PROCESSOR IDLE
        JNZ     PIOZZZ          ; LOOP UNTIL IT IS IDLE
	        MOV     A,B             ; LOAD THE COMMAND
        OUT     PIOO            ; OUTPUT THE COMMAND TO THE PIO CONTROL PORT
        MVI     A,ENABL         ; ENABLE INTERRUPTS
        OUT     CPUC
	        RET
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
        ORG     0FFFDH
	MNCKSM: DB      06CH            ; CHKSUM MONITOR TO 01EH
	        DB      00              ; UNUSED BYTE
	        DB      01              ; 0, IF SERIES I MONITOR
		                                ; 1, IF SERIES II MONITOR
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* *-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
		;
		; END OF PROGRAM
		;
		;*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	        END

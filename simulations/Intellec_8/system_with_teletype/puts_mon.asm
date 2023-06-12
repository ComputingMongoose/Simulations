CR        EQU       0DH                 ; ASCII VALUE OF CARRIAGE RETURN
LF        EQU       0AH                 ; ASCII VALUE OF LINE FEED

CO        EQU       3809H               ; Monitor provided routine
          
          ORG       100H

          LXI       H,S1
          CALL      PUTS
          LXI       H,S2
          CALL      PUTS
          HLT

S1:       DB        'STRING ONE',CR,LF,0
S2:       DB        'STRING TWO',CR,LF,0

; Input: HL=null terminated string
PUTS:
          MOV       A,M
          ORA       A
          JZ        PUTSE
          MOV       B,A
          MOV       D,H
          MOV       E,L
          CALL      CO
          MOV       H,D
          MOV       L,E
          INR       L
          JNC       PUTS
          INR       H
          JMP       PUTS
PUTSE:
          RET
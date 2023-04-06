; from https://www.retrotechnology.com/restore/4040_robson.lst
; requires constants.asm for defining register pseudonims

         	RPAIRS  "ZERO7"
         	ORG     0h
          INCL    "constants.asm"

START:
            fim r2r3,'E'                          
            jms PrintTTYR2
            fim r2r3,'C'                          
            jms PrintTTYR2
            fim r2r3,'H'                          
            jms PrintTTYR2
            fim r2r3,'O'                          
            jms PrintTTYR2
            jms PrintCRLF                         ; Print CR/LF

main:
            fim r2r3,'I'                          
            jms PrintTTYR2
            fim r2r3,'N'                          
            jms PrintTTYR2
            fim r2r3,'>'                          
            jms PrintTTYR2

            jms InputTTYR2
            jms PrintTTYR2
            jms PrintCRLF                         ; Print CR/LF
			jun main
			
            hlt

InputTTYR2:
            clb                                   ; Clear both carry and Accumulator. 0 selects TTY (1 from elsewhere selects Tape Reader ?)
InputAlternate:
            fim r6r7,40h                          ; Set SRC to 01:00:0000 e.g. RAM Chip 1,Register 0,Address 0
            src r6r7
            wmp                                   ; Write device select there.
            ldm 8                                 ; set the counter to -8, we want to read 8 bits.
            xch r4
            jms SetRAMUnit0_0                     ; Back to RAM Unit 0,0 
ReadTTYWait:
            rdr                                   ; Read the I/O port
            rar                                   ; Shift bit 0 into carry.
            jcn nc,ReadTTYWait                       ; If bit 0 was clear then wait for character to be received
            jms DelayBaudRateHalf                 ; wait half a pulse, so you are reading in the middle of the pulse.
            src r6r7                              ; write 1 into 01:00 I/O port bit 0.
            wmp
            src r0r1                              ; back to 00:00 
            wmp                                   ; write '1' there (e.g. the start bit of the echo)
ReadTTYLoop:
            jms DelayBaudRate                     ; wait till the middle of the next pulse
            rdr                                   ; read the I/O line
            cma                                   ; invert it (active low ?)
            wmp                                   ; and write it back for the echo
            rar                                   ; shift it into R2,R3
            ld r2                                 ; again the least significant bit will be first as it's
            rar
            xch r2
            ld r3
            rar
            xch r3
            isz r4,ReadTTYLoop                    ; do it 8 times
            jms DelayBaudRate                     ; wait middle of next pulse
            ldm 1                                 ; set o/p so echoing stop bit.
            wmp
            jms DelayBaudRate                     ; do the long stop bit, skip over receiving it as we don't need to
            jms DelayBaudRateHalf
            xch r2                                ; rotate a zero right into R2, e.g. clear the most significant bit
            ral
            clc
            rar
            xch r2
            bbl 0                                 ; and exit.


PrintCRLF:
            fim r2r3,0dh                          ; send CR to TTY and drop through.              
            jms PrintTTYR2
PrintLF:                                          ; send LF to TTY
            fim r2r3,0ah
            jun PrintTTYR2
            
PrintTTYR2:
            jms SetRAMUnit0_0                     ; back to RAM 0:0
            wmp                                   ; write to output bit. Not quite sure how they know what is being written - could be on WR pulse
            ldm 8                                 ; count 8 times in R4. Actually -8, but it's the same in 4 Bit.
            xch r4
_PrintLoop:
            jms DelayBaudRate                     ; delay to set the baud rate write
            clc                                   ; rotate R2:R3 pair right 
            xch r2
            rar                                   ; RAR is a rotate through carry.
            xch r2
            xch r3
            rar
            xch r3
            tcc                                   ; put the carry in the accumulator - the least significant bit shifted out.
            wmp                                   ; set the output bit to TTY
            isz r4,_PrintLoop                     ; do it 8 times
            jms DelayBaudRate                     ; do the last one (because the first was the start bit)
            ldm 1                                 ; set the output line to 1 (stop bit)
            wmp                                   
            jms DelayBaudRate                     ; double length stop bit.
            jms DelayBaudRate    
            bbl 0                                 ; and end.


delayCount equ 0f3h                               ; Frequency is loop x 2 x 2 / 10.8us    
DelayBaudRate:
            fim r0r1,delayCount                   ; number chosen to set effective BAUD rate
DBRLoop1:                                         
            isz r1,DBRLoop1                       ; this one is done 13 times (26 cycles)
            isz r0,DBRLoop1                       ; this one once, so that makes 28 cycles + 2 for FIM

DelayBaudRateHalf:
            fim r0r1,delayCount                   ; as above. 
DBRLoop2:                                         
            isz r1,DBRLoop2                       
            isz r0,DBRLoop2
            bbl 0

SetRAMUnit0_0:
            fim r0r1,00h                           ; Load 0 into R0,R1
            src r0r1                              ; Set as default output (chip 0, register 0, address 0)
            bbl 0                                 ; return.

          END START

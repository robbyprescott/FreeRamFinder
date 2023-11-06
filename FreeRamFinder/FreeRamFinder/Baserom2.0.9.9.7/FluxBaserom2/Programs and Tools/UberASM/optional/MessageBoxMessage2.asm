!FreeRAM = $0EAD  ;or whatever value you want
!FreeRAM2 = $0EAE
!Timer = #$10

!Message = $02		;01=Message1 02=Message2 03=Yoshi thanks message

init:
STZ !FreeRAM
STZ !FreeRAM2
;LDA $13BF|!addr
;STA $13E7|!addr
RTL

main:
;LDA $13E7|!addr
;STA $13BF|!addr

LDA !FreeRAM
BEQ Return ; if not activated, return
LDA !FreeRAM2
CMP !Timer
BEQ Code
INC !FreeRAM2
RTL

Code:
LDX #!Message
STX $1426
LDA #$22		; Message box SFX.
STA $1DFC|!addr		; Bank.

;LDA $03		; Load map16 number of block.
;CMP #$60		; Highest translevel value is $5F. Higher values aren't needed.
;BCS Return		;
;STA $13BF		; Store value to translevel number. This tells the game which level you're loading the message from.
;LDA $9A		; Low byte of X position.
;AND #$10		; Check every 16 pixels.
;LSR #4		;
;INC A 	; Convert X position to message trigger $01 or $02.
;STA $1426|!addr		; Message trigger.

STZ !FreeRAM
STZ !FreeRAM2

Return:
  RTL
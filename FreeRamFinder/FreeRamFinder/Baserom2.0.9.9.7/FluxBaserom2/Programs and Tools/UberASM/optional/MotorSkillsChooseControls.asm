; Slight modications by SJC.
; You can switch to L/R motor skills by pressing select (or again to go back to normal)
; You can also reenable the sound

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Spinjump<->Jump
;Allows to change jumping state mid-air.
;Pressing A while jumping causes player to spin
;and pressing B while spinjumping causes playet to stop spinning.
;By RussianMan. Credit is optional.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!SpinJumpSound = $00		; 04 normal, sound effect for spinjump
!SpinJumpBank = $1DFC

!JumpSound = $00		;35 is normal sound effect for normal jump
!JumpSoundBank = $1DFC		


main:
    LDA $16					; \ If the player has pressed the Select button...
    AND #$20				; |
    BNE StoreZero
    LDA $147B
    CMP #$01
    BNE CYA    ; SJC: I changed from BEQ to make A/B default and L/R secondary
    BRA Over
StoreZero:
LDA #$29 ; make sound
STA $1DFC 
LDA $147B
CMP #$01
BNE Reset
STZ $147B
BRA Over
Reset:
LDA #$01
STA $147B
    Over: 			
    LDA $17 : STA $00
    LDA $18 : STA $01
    
    LDA #$90    ; clear a/r bits
    TRB $17
    TRB $18
    
 ;   LDA $16     ; clear a+b bit if b is clear
 ;   AND #$80
 ;   EOR #$80
 ;   TRB $15
    
    LDA #$30    ; move a bit to r
    BIT $00	
    BPL +
    TSB $17
  + BIT $01
    BPL +
    TSB $18
  + 
    
    LDA $00     ; move r bit to a
    AND #$30
    BEQ +
    LDA #$80
    TSB $15
    TSB $17
  + LDA $01
    AND #$30
    BEQ +
    LDA #$80
    TSB $18
  + 
BRA KK
CYA:
    LDA #$0B
    STA $7FA042
    LDA #$0A	
    STA $7FA046	
    LDA #$FC
    STA $7FA048	
    BRA OH
KK:
JMP Next
Next:
    LDA $147B
    BNE OH
    LDA #$0B
    STA $7FA042
    LDA #$15	
    STA $7FA046
    LDA #$1B
    STA $7FA048
OH:	
LDA $9D				;don't do things when freeze flag is set
ORA $187A|!addr			;and not when riding yoshi also don't run
BNE .Re				;

LDA $72				;if not in air
BEQ .Re				;don't run code

LDA $140D|!addr			;check jump type
BNE .SpinJumping		;if non-0, spinjumping

BIT $18				;if pressing A
BPL .Re				;change jump to spinjump

.Change
LDA $140D|!addr			;spinjump into jump or vice versa
EOR #$01			;
STA $140D|!addr			;

.Re
RTL				;

.SpinJumping
BIT $16				;if pressing B
BPL .Re				;change spinjump to jump

BRA .Change			;
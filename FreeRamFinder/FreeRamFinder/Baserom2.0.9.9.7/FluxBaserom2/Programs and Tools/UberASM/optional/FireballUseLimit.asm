; Will only allow you to use a defined number of fireballs 
; in a level before disabling this ability.
; (Need to add cape stuff to this.)

; Use with D2 sprite gen.
; Can also use with three-digit HUD counter. Just set the counter to use $0E52
; Probably a better way to do it, but...

!NumberOfFireballsBeforeDisable = $03
!PlaySoundWhenOutOf = 1
!Counter = $0E52; Fireball or cape sound check. $0DBF is coin
!DisableWhenAboveOrBelowThisValue = $01 ; set to 01 


init:
LDA #!NumberOfFireballsBeforeDisable
STA !Counter
RTL

main:
LDA !Counter
CMP #!DisableWhenAboveOrBelowThisValue
BCS Return ; BCC when above, BCS when below
if !PlaySoundWhenOutOf
LDA #$01
STA $0DED ; FireballFlagStuff.asm patch
LDA $19
CMP #$03 ; fire flower check
BNE Return
LDA $16
CMP #$40 ; y press
BNE Return
LDA #$2A
STA $1DFC
endif
Return:
RTL
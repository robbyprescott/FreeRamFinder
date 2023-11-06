;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Charged fireballs by Ladida
;; UberASM version by KevinM, modified by SJC
;;
;; Can shoot with L or R if you have mushroom
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Powerup      = $01 ; $03 is flower
!XSpeed       = $38         ; X speed of the fireballs ($00-$7F)

!SFX         = $17         ; Sound effect you want to use when shooting the fireball, set to 00 for no sound
!SFXPort     = $1DFC 

init:
LDA #$01 ; prevent you from shooting normal fireballs if you have flower (if flag patch applied)
STA $0DED
lda #$01 ; start big
sta $19
RTL

main:
	lda $9D
	ora $13D4|!addr
	bne Return
	lda $19  ; prevent fire flower firing if use it as powerup check
	cmp #!Powerup
	bne Return
	lda $73
	ora $74
    ora $187A|!addr
    ora $1497|!addr
    bne Return
    jsr Fireballs
Return:
	rtl

Fireballs:
	LDA $18 : AND #$30 : BEQ .Return ; L or R press. LDA $16 : AND #$40, X and Y
    LDA $71
    CMP #$05
    BEQ .Return
    CMP #$06
    BEQ .Return
    CMP #$0D
    BEQ .Return
    CMP #$09
    BNE .omaewamoushindeiru
    STZ $149B|!addr
.Return
    RTS
	
.omaewamoushindeiru
    LDY #$07
-   
    LDA $170B|!addr,y
    BEQ +
    DEY
    BPL -
    RTS
+   
if !SFX != $00
    LDA #!SFX
    STA !SFXPort
endif
    LDA #$0A
    STA $149C|!addr ; fireball shooting pose (07)
    LDA #$11
    STA $170B|!addr,y
    LDA $94
    STA $171F|!addr,y
    LDA $95
    STA $1733|!addr,y
    LDA $96
    CLC : ADC #$08
    STA $1715|!addr,y
    LDA $97
    ADC #$00
    STA $1729|!addr,y
    LDA $13F9|!addr
    STA $1779|!addr,y
    LDA $76
    LSR
    LDA #!XSpeed
    BCS +
    EOR #$FF
    INC
+   
    STA $1747|!addr,y
    LDA #$00
    STA $173D|!addr,y
    LDA #$A0
    STA $176F|!addr,y
    RTS

; By SJandCharlieTheCat
; Need to STZ FreeRAM at load if $0DF3, or else reverse branches

!FreeRAM = $0DF3

org $00D081
autoclean JML ConditionalPowerupCheck ; When FreeRAM set, overwrite only allows fireballs if fire Mario

org $00FEBA
autoclean JSL SmallFirePose
NOP

freecode

;CODE_00D062:        A5 19         LDA RAM_MarioPowerUp      ;\
;CODE_00D064:        C9 02         CMP.B #$02                ;| if mario is not caped, 
;CODE_00D066:        D0 19         BNE CODE_00D081           ;/

ConditionalPowerupCheck:


LDA $19
CMP #$03 
BEQ NormalShoot  ; if fire Mario, can shoot fireball
LDA !FreeRAM 
BEQ + ; if RAM set, can shoot as small
NormalShoot:
JML $00D085 ; LDA RAM_IsDucking
+
JML $00D0AD

SmallFirePose:
LDA !FreeRAM
BNE Return ; if trigger, don't change pose (normally forces big Mario)
LDA #$0A
STA $149C ; FireballImgTimer
Return:
RTL

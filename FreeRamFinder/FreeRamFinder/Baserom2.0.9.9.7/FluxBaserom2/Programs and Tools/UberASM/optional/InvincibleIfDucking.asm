!Sparkles = 1

main:
LDA $73
CMP #$04 ; duck check
BNE Return
LDA #$01
STA $0EB7
if !Sparkles
JSL $02858F        ; sparkle
endif
BRA End
Return:
STZ $0EB7
End:
RTL

;LDA #$FF ; Mario won't be hurt by sprites
;STA $1497

;STZ $149B
;STZ 18D3
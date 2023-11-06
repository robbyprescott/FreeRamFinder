; By Runic

main:        ;PrideCape
    LDA $19 : CMP #$02 : BNE +        ; only with cape
    LDA $14A6|!addr : BNE .spin        ; always while spinning
    ;LDA $1407|!addr : BNE +            ; not while gliding
    LDA $13DF|!addr : AND #$01 : BEQ +    ; on odd cape frames
.spin:
    LDA $14 : AND #$03 : BNE +        ; only every 4 frames
.glitter:
    REP #$20
    LDA $94 : PHA
    LDA $76 : AND #$0001 : ASL : TAX
    LDA.l .offsets,x : CLC : ADC $94 : STA $94
    STA $0F34|!addr
    SEP #$20
    JSL $02858F        ; sparkle
    REP #$20
    PLA : STA $94
    SEP #$20
+
    RTL

.offsets:
    dw 16,-16